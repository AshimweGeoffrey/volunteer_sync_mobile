import 'package:flutter/material.dart';
import 'package:farmora/screens/calculator_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Custom color palette
  static final Color _primaryColor = Color(0xFF6200EE); // Purple
  static final Color _secondaryColor = Color(0xFF03DAC6); // Teal
  static final Color _accentColor = Color(0xFFFFA000); // Amber
  static final Color _errorColor = Color(0xFFB00020); // Dark red
  static final Color _successColor = Color(0xFF4CAF50); // Green
  static final Color _warningColor = Color(0xFFFF9800); // Orange
  static final Color _infoColor = Color(0xFF2196F3); // Blue
  static final Color _neutralColor = Color(0xFF757575); // Gray

  int _selectedIndex = 0;
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.full;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool _isBluetoothOn = false;
  bool _isScanning = false;
  List<ScanResult> _bluetoothDevices = [];
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _initBatteryMonitoring();
    _initBluetoothMonitoring();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _scanResultsSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  // Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await Connectivity().checkConnectivity();
    } catch (e) {
      debugPrint('Failed to get connectivity status: $e');
      return;
    }

    if (!mounted) return;

    setState(() {
      _connectionStatus = result;
    });

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (!mounted) return;
      setState(() {
        _connectionStatus = result;
      });
    });
  }

  // Initialize battery monitoring
  Future<void> _initBatteryMonitoring() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;

      if (!mounted) return;

      setState(() {
        _batteryLevel = batteryLevel;
        _batteryState = batteryState;
      });

      _battery.onBatteryStateChanged.listen((BatteryState state) {
        if (!mounted) return;
        setState(() {
          _batteryState = state;
        });
        _updateBatteryLevel();
      });

      // Set up periodic battery level updates
      Timer.periodic(Duration(minutes: 1), (_) => _updateBatteryLevel());
    } catch (e) {
      debugPrint('Battery monitoring error: $e');
    }
  }

  Future<void> _updateBatteryLevel() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      if (!mounted) return;
      setState(() {
        _batteryLevel = batteryLevel;
      });
    } catch (e) {
      debugPrint('Battery level update error: $e');
    }
  }

  // Initialize Bluetooth monitoring
  Future<void> _initBluetoothMonitoring() async {
    // Initialize adapter state monitoring
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;
      setState(() {
        _isBluetoothOn = state == BluetoothAdapterState.on;
        // If Bluetooth was just turned on and we're not already scanning, start a scan
        if (_isBluetoothOn && !_isScanning) {
          _startBluetoothScan();
        }
      });
    });

    try {
      // Check initial Bluetooth state
      final adapterState = await FlutterBluePlus.adapterState.first;
      setState(() {
        _isBluetoothOn = adapterState == BluetoothAdapterState.on;
      });

      // Start scanning if Bluetooth is on
      if (_isBluetoothOn) {
        _startBluetoothScan();
      }
    } catch (e) {
      debugPrint('Bluetooth initialization error: $e');
    }
  }

  // Start Bluetooth scan
  Future<void> _startBluetoothScan() async {
    if (_isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
      _bluetoothDevices = [];
    });

    // Cancel previous subscription if exists
    await _scanResultsSubscription?.cancel();

    // Listen to scan results
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        if (!mounted) return;
        setState(() {
          _bluetoothDevices = results;
        });
      },
      onError: (e) {
        debugPrint('Scan error: $e');
        setState(() {
          _isScanning = false;
        });
      },
      onDone: () {
        setState(() {
          _isScanning = false;
        });
      },
    );

    try {
      // Start the scan with a timeout
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    } catch (e) {
      debugPrint('Start scan error: $e');
      setState(() {
        _isScanning = false;
      });
    }
  }

  // Toggle Bluetooth on/off
  Future<void> _toggleBluetooth() async {
    try {
      if (_isBluetoothOn) {
        // Android cannot programmatically disable Bluetooth, we can only prompt the user
        await FlutterBluePlus.turnOff();
      } else {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      debugPrint('Toggle Bluetooth error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Network connectivity status card
  Widget _buildNetworkStatusCard() {
    IconData icon;
    String status;
    Color color;

    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        icon = Icons.wifi;
        status = 'Wi-Fi Connected';
        color = _successColor;
        break;
      case ConnectivityResult.mobile:
        icon = Icons.signal_cellular_alt;
        status = 'Mobile Data Connected';
        color = _accentColor;
        break;
      case ConnectivityResult.ethernet:
        icon = Icons.settings_ethernet;
        status = 'Ethernet Connected';
        color = _secondaryColor;
        break;
      case ConnectivityResult.bluetooth:
        icon = Icons.bluetooth;
        status = 'Connected via Bluetooth';
        color = _primaryColor;
        break;
      case ConnectivityResult.none:
      default:
        icon = Icons.signal_wifi_off;
        status = 'No Internet Connection';
        color = _errorColor;
        break;
    }

    return _buildStatusCard(
      title: 'Network Status',
      icon: icon,
      content: status,
      color: color,
      onTap: _initConnectivity,
    );
  }

  // Battery status card
  Widget _buildBatteryStatusCard() {
    IconData icon;
    String status;
    Color color;

    // Determine battery icon and color based on level and state
    if (_batteryLevel >= 80) {
      icon = Icons.battery_full;
      color = _successColor;
    } else if (_batteryLevel >= 50) {
      icon = Icons.battery_6_bar;
      color = _secondaryColor;
    } else if (_batteryLevel >= 15) {
      icon = Icons.battery_3_bar;
      color = _warningColor;
    } else {
      icon = Icons.battery_alert;
      color = _errorColor;
    }

    // Handle charging state
    if (_batteryState == BatteryState.charging) {
      icon = Icons.battery_charging_full;
      status = 'Charging - $_batteryLevel%';
      color = _infoColor;
    } else {
      status = 'Battery - $_batteryLevel%';
    }

    return _buildStatusCard(
      title: 'Battery Status',
      icon: icon,
      content: status,
      color: color,
      onTap: _updateBatteryLevel,
      showProgress: false,
      extraWidget: LinearProgressIndicator(
        value: _batteryLevel / 100,
        backgroundColor: Colors.grey[800],
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  // Bluetooth status card
  Widget _buildBluetoothStatusCard() {
    IconData icon;
    String status;
    Color color;

    if (_isScanning) {
      icon = Icons.bluetooth_searching;
      status = 'Scanning for devices...';
      color = _accentColor;
    } else if (_isBluetoothOn) {
      icon = Icons.bluetooth_connected;
      status = 'Bluetooth On';
      color = _primaryColor;
    } else {
      icon = Icons.bluetooth_disabled;
      status = 'Bluetooth Off';
      color = _neutralColor;
    }

    return _buildStatusCard(
      title: 'Bluetooth Status',
      icon: icon,
      content: status,
      color: color,
      onTap: _isScanning
          ? () {}
          : (_isBluetoothOn ? _startBluetoothScan : _toggleBluetooth),
      showProgress: _isScanning,
      extraWidget: _isBluetoothOn && _bluetoothDevices.isNotEmpty
          ? Container(
              height: _bluetoothDevices.length > 3 ? 180 : 110,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    _bluetoothDevices.length > 3 ? 3 : _bluetoothDevices.length,
                itemBuilder: (context, index) {
                  final device = _bluetoothDevices[index].device;
                  return ListTile(
                    dense: true,
                    title: Text(
                      device.platformName.isNotEmpty
                          ? device.platformName
                          : device.remoteId.str.substring(0, 8),
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Signal: ${_bluetoothDevices[index].rssi} dBm',
                      style: TextStyle(color: Colors.white70),
                    ),
                    leading: Icon(
                        _bluetoothDevices[index].advertisementData.connectable
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth,
                        size: 20,
                        color: _bluetoothDevices[index]
                                .advertisementData
                                .connectable
                            ? _secondaryColor
                            : _neutralColor),
                  );
                },
              ),
            )
          : null,
    );
  }

  // Generic status card builder
  Widget _buildStatusCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
    required VoidCallback onTap,
    bool showProgress = false,
    Widget? extraWidget,
  }) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color(0xFF1E1E1E), // Dark card background
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(24), // Enlarged padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Larger font
                      color: Colors.white,
                    ),
                  ),
                  Icon(Icons.refresh, size: 20, color: _accentColor),
                ],
              ),
              SizedBox(height: 16), // More space
              Row(
                children: [
                  Icon(icon, color: color, size: 32), // Larger icon
                  SizedBox(width: 16), // More space
                  Expanded(
                    child: Text(
                      content,
                      style:
                          TextStyle(fontSize: 16, color: color), // Larger font
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showProgress)
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                      ),
                    ),
                ],
              ),
              if (extraWidget != null) ...[
                SizedBox(height: 12), // More space
                extraWidget,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Home screen content
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20), // Larger padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Status',
            style: TextStyle(
              fontSize: 24, // Larger font
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20), // More space
          _buildNetworkStatusCard(),
          SizedBox(height: 16), // More space
          _buildBatteryStatusCard(),
          SizedBox(height: 16), // More space
          _buildBluetoothStatusCard(),
          SizedBox(height: 28), // More space
          Text(
            'Dashboard Content',
            style: TextStyle(
              fontSize: 24, // Larger font
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20), // More space
          // Additional dashboard content would go here
          Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Color(0xFF1E1E1E), // Dark card background
            child: Container(
              padding: EdgeInsets.all(24), // Enlarged padding
              child: Center(
                child: Text(
                  'Your dashboard content',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: _primaryColor,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.black, // Black drawer background
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('User Name'),
                accountEmail: Text('user@example.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/profile_photo.png'),
                  backgroundColor: _accentColor,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: _primaryColor),
                title: Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.calculate, color: _accentColor),
                title:
                    Text('Calculator', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/calculator');
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: _secondaryColor),
                title: Text('About Us', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.verified_user, color: _infoColor),
                title: Text('Version 1.0.0',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _selectedIndex == 1
              ? CalculatorScreen()
              : Center(
                  child: Text('Economics Page',
                      style: TextStyle(color: Colors.white, fontSize: 18))),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Economics',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _neutralColor,
        backgroundColor: Colors.black, // Black bottom nav bar
        onTap: _onItemTapped,
      ),
    );
  }
}
