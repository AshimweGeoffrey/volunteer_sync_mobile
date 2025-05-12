import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:volunteer_sync/data/models/event_category.dart';
import 'package:volunteer_sync/data/models/event.dart';
import 'package:volunteer_sync/utils/app_theme.dart';
// other imports

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  bool _isMapLoaded = false;
  
  // Default position - will be updated to user's position
  static const LatLng _defaultPosition = LatLng(40.7128, -74.0060); // New York
  LatLng _currentPosition = _defaultPosition;
  
  bool _showList = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }
  
  void _createMarkers() {
    setState(() {
      _markers = DummyDataRepository.events.map((event) {
        return Marker(
          markerId: MarkerId(event.id),
          position: event.coordinates,
          infoWindow: InfoWindow(
            title: event.title,
            snippet: '${event.spotsAvailable}/${event.spotsTotal} spots available',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(event.category),
          ),
          onTap: () {
            _showEventDetails(event);
          },
        );
      }).toSet();
      
      // Add markers for volunteers too
      _markers.addAll(
        DummyDataRepository.nearbyVolunteers.map((volunteer) {
          return Marker(
            markerId: MarkerId('volunteer_${volunteer.id}'),
            position: LatLng(volunteer.latitude, volunteer.longitude),
            infoWindow: InfoWindow(
              title: volunteer.name,
              snippet: '${volunteer.hoursCompleted} hours volunteered',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          );
        }),
      );
      
      // Current user marker
      _markers.add(
        Marker(
          markerId: const MarkerId('current_user'),
          position: LatLng(
            DummyDataRepository.currentUser.latitude,
            DummyDataRepository.currentUser.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'You (${DummyDataRepository.currentUser.name})',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          zIndex: 2,
        ),
      );
    });
  }
  
  double _getMarkerHue(EventCategory category) {
    switch (category) {
      case EventCategory.environmental:
        return BitmapDescriptor.hueGreen;
      case EventCategory.humanitarian:
        return BitmapDescriptor.hueRed;
      case EventCategory.educational:
        return BitmapDescriptor.hueYellow;
      case EventCategory.animalWelfare:
        return BitmapDescriptor.hueViolet;
      case EventCategory.communityService:
        return BitmapDescriptor.hueOrange;
      case EventCategory.healthcareSupport:
        return BitmapDescriptor.hueCyan;
      case EventCategory.disasterRelief:
        return BitmapDescriptor.hueMagenta;
      default:
        return BitmapDescriptor.hueRose;
    }
  }
  
  Future<void> _goToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    
    // In a real app, you would get the real location
    setState(() {
      _currentPosition = LatLng(
        DummyDataRepository.currentUser.latitude,
        DummyDataRepository.currentUser.longitude,
      );
    });
    
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _currentPosition,
        zoom: 14.0,
      ),
    ));
  }
  
  void _showEventDetails(event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailBottomSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search events or locations',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(_showList ? Icons.map : Icons.list),
                onPressed: () {
                  setState(() {
                    _showList = !_showList;
                  });
                },
                tooltip: _showList ? 'Show Map' : 'Show List',
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // Show filter options
                  _showFilterDialog();
                },
                tooltip: 'Filter',
              ),
            ],
          ),
        ),
        Expanded(
          child: _showList
              ? _buildEventsList()
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        setState(() {
                          _isMapLoaded = true;
                        });
                      },
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition,
                        zoom: 13,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      compassEnabled: true,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                    if (!_isMapLoaded)
                      Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    // Category Chips
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip('All', Icons.all_inclusive, AppTheme.primaryColor),
                            _buildCategoryChip('Environmental', Icons.nature, Colors.green),
                            _buildCategoryChip('Humanitarian', Icons.volunteer_activism, Colors.red),
                            _buildCategoryChip('Educational', Icons.school, Colors.amber),
                            _buildCategoryChip('Animal Welfare', Icons.pets, Colors.purple),
                            _buildCategoryChip('Healthcare', Icons.local_hospital, Colors.blue),
                          ],
                        ),
                      ),
                    ),
                    // Floating panel with events near location
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Events Near You',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showList = true;
                                      });
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: DummyDataRepository.events.length,
                                itemBuilder: (context, index) {
                                  final event = DummyDataRepository.events[index];
                                  return _buildEventCard(
                                    event.title,
                                    '${event.formattedDate} • ${event.distanceFromUser} mi away',
                                    _getCategoryIcon(event.category),
                                    _getCategoryColor(event.category),
                                    () => _showEventDetails(event),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Location and zoom buttons
                    Positioned(
                      right: 16,
                      bottom: 224,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'btn1',
                            mini: true,
                            backgroundColor: Theme.of(context).cardColor,
                            foregroundColor: AppTheme.primaryColor,
                            elevation: 4,
                            child: const Icon(Icons.add),
                            onPressed: () async {
                              final GoogleMapController controller = await _controller.future;
                              controller.animateCamera(CameraUpdate.zoomIn());
                            },
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'btn2',
                            mini: true,
                            backgroundColor: Theme.of(context).cardColor,
                            foregroundColor: AppTheme.primaryColor,
                            elevation: 4,
                            child: const Icon(Icons.remove),
                            onPressed: () async {
                              final GoogleMapController controller = await _controller.future;
                              controller.animateCamera(CameraUpdate.zoomOut());
                            },
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'btn3',
                            mini: true,
                            backgroundColor: Theme.of(context).cardColor,
                            foregroundColor: AppTheme.primaryColor,
                            elevation: 4,
                            child: const Icon(Icons.my_location),
                            onPressed: _goToCurrentLocation,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
  
  Widget _buildCategoryChip(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        backgroundColor: Theme.of(context).cardColor,
        shadowColor: Colors.black54,
        elevation: 3,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (bool selected) {
          // Filter events by category
        },
      ),
    );
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.environmental:
        return Icons.nature;
      case EventCategory.humanitarian:
        return Icons.volunteer_activism;
      case EventCategory.educational:
        return Icons.school;
      case EventCategory.animalWelfare:
        return Icons.pets;
      case EventCategory.communityService:
        return Icons.people;
      case EventCategory.healthcareSupport:
        return Icons.local_hospital;
      case EventCategory.disasterRelief:
        return Icons.warning;
      case EventCategory.artsAndCulture:
        return Icons.color_lens;
      case EventCategory.sportsAndRecreation:
        return Icons.sports;
      case EventCategory.technology:
        return Icons.computer;
    }
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.environmental:
        return Colors.green;
      case EventCategory.humanitarian:
        return AppTheme.primaryColor;
      case EventCategory.educational:
        return Colors.amber;
      case EventCategory.animalWelfare:
        return Colors.purple;
      case EventCategory.communityService:
        return Colors.orange;
      case EventCategory.healthcareSupport:
        return Colors.blue;
      case EventCategory.disasterRelief:
        return Colors.red;
      case EventCategory.artsAndCulture:
        return Colors.pink;
      case EventCategory.sportsAndRecreation:
        return Colors.teal;
      case EventCategory.technology:
        return Colors.indigo;
    }
  }

  Widget _buildEventCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: DummyDataRepository.events.length,
      itemBuilder: (context, index) {
        final event = DummyDataRepository.events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: InkWell(
            onTap: () => _showEventDetails(event),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: _getCategoryColor(event.category).withOpacity(0.2),
                    image: event.imageUrl != null
                        ? DecorationImage(
                            image: AssetImage(event.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                      backgroundColor: Theme.of(context).cardColor.withOpacity(0.8),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(event.category),
                            size: 16,
                            color: _getCategoryColor(event.category),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.category.toString().split('.').last,
                            style: TextStyle(color: _getCategoryColor(event.category)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(event.formattedDate),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(event.formattedTime),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('${event.distanceFromUser} mi away'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${event.spotsAvailable}/${event.spotsTotal} spots available',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: event.spotsAvailable > 0
                                  ? Colors.green
                                  : AppTheme.primaryColor,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showEventDetails(event),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Details'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Events'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EventCategory.values.map((category) {
                  return FilterChip(
                    label: Text(category.toString().split('.').last),
                    selected: true,
                    onSelected: (selected) {
                      // Apply filter
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Slider(
                value: 10,
                min: 1,
                max: 50,
                divisions: 10,
                label: '10 miles',
                onChanged: (value) {
                  // Update distance filter
                },
              ),
              const SizedBox(height: 16),
              const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Show date picker
                      },
                      child: const Text('Start Date'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Show date picker
                      },
                      child: const Text('End Date'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Apply filters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
