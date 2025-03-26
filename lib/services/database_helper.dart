import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:farmora/models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  bool _initialDataLoaded = false;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    
    if (!_initialDataLoaded) {
      await _loadInitialData();
      _initialDataLoaded = true;
    }
    
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'farmora_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _loadInitialData() async {
    List<Product> products = await getProducts();
    if (products.isEmpty) {
      List<Product> dummyProducts = [
        Product(
          name: 'Organic Tomatoes',
          description: 'Fresh organic tomatoes grown without pesticides. Perfect for salads and cooking.',
          price: 3.99,
          imageUrl: 'https://images.unsplash.com/photo-1524593166156-312f362cada0?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dG9tYXRvZXN8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
          createdAt: DateTime.now().subtract(Duration(days: 3)),
        ),
        Product(
          name: 'Fresh Carrots Bundle',
          description: 'A bundle of fresh farm carrots. Rich in vitamins and perfect for juicing or cooking.',
          price: 2.49,
          imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9f8a4d5be?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8Y2Fycm90c3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
        ),
        Product(
          name: 'Avocado Set',
          description: 'Premium avocados ready to eat. High in healthy fats and perfect for sandwiches and salads.',
          price: 5.99,
          imageUrl: 'https://images.unsplash.com/photo-1519162808019-7de1683fa2ad?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8YXZvY2Fkb3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
        ),
        Product(
          name: 'Farm Fresh Eggs',
          description: 'Free-range eggs from our local farm. Ethically sourced and perfect for breakfast.',
          price: 4.50,
          imageUrl: 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8ZWdnc3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        ),
        Product(
          name: 'Organic Spinach',
          description: 'Fresh organic spinach leaves. Rich in iron and perfect for smoothies and salads.',
          price: 2.99,
          imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8c3BpbmFjaHxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
          createdAt: DateTime.now().subtract(Duration(days: 4)),
        ),
      ];

      for (var product in dummyProducts) {
        await insertProduct(product);
      }
    }
  }

  Future<int> insertProduct(Product product) async {
    Database db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', orderBy: 'id DESC');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProduct(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? Product.fromMap(maps.first) : null;
  }

  Future<int> updateProduct(Product product) async {
    Database db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
