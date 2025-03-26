import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:farmora/models/product.dart';
import 'dart:io';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const String DB_NAME = 'farmora_database.db';
  static const int DB_VERSION = 1;
  
  // Using a Completer to ensure concurrent access doesn't cause issues
  final Completer<Database> _dbCompleter = Completer<Database>();
  bool _isInitializing = false;
  
  // Singleton constructor
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database getter with thread-safe initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    if (!_isInitializing) {
      _isInitializing = true;
      _initDatabase().then((db) {
        _database = db;
        _dbCompleter.complete(db);
      });
    }
    
    return _dbCompleter.future;
  }

  // Database initialization with optimizations
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DB_NAME);
    
    return await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
      onOpen: (db) async {
        await _onConfigure(db);
        await _insertDummyData(db);
      },
    );
  }
  
  // Enable optimizations for database performance
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys for referential integrity
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Use Write-Ahead Logging for better concurrency and crash recovery
    await db.execute('PRAGMA journal_mode = WAL');
    
    // Reduce disk I/O by controlling sync behavior
    await db.execute('PRAGMA synchronous = NORMAL');
    
    // Increase cache size for better performance
    await db.execute('PRAGMA cache_size = 2000');
    
    // Store temporary tables and indices in memory
    await db.execute('PRAGMA temp_store = MEMORY');
    
    // Optimize memory usage for database pages
    await db.execute('PRAGMA page_size = 4096');
    
    // Optimize database layout by defragmenting
    await db.execute('PRAGMA optimize');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create products table with new fields
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        category TEXT DEFAULT 'general',
        inStock INTEGER DEFAULT 1,
        rating REAL DEFAULT 4.0,
        origin TEXT DEFAULT 'Local Farm'
      )
    ''');
    
    // Create indices for frequently queried columns
    await db.execute('CREATE INDEX idx_products_category ON products(category)');
    await db.execute('CREATE INDEX idx_products_inStock ON products(inStock)');
    await db.execute('CREATE INDEX idx_products_price ON products(price)');
    await db.execute('CREATE INDEX idx_products_rating ON products(rating)');
  }

  Future<void> _insertDummyData(Database db) async {
    // Check if data already exists
    var count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
    if (count != null && count > 0) return;

    // Expanded dummy data with diverse categories
    List<Map<String, dynamic>> dummyProducts = [
      // Vegetables
      {
        'name': 'Organic Tomatoes',
        'description': 'Fresh organic tomatoes grown without pesticides. Perfect for salads and cooking.',
        'price': 3.99,
        'imageUrl': 'https://images.unsplash.com/photo-1524593166156-312f362cada0?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.5,
        'origin': 'Organic Valley Farms'
      },
      {
        'name': 'Fresh Carrots Bundle',
        'description': 'A bundle of fresh farm carrots. Rich in vitamins and perfect for juicing or cooking.',
        'price': 2.49,
        'imageUrl': 'https://images.unsplash.com/photo-1598170845058-32b9f8a4d5be?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.2,
        'origin': 'Green Acres Farm'
      },
      {
        'name': 'Organic Spinach',
        'description': 'Fresh organic spinach leaves. Rich in iron and perfect for smoothies and salads.',
        'price': 2.99,
        'imageUrl': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.7,
        'origin': 'Sunrise Organic Gardens'
      },
      {
        'name': 'Sweet Potatoes',
        'description': 'Delicious and nutritious sweet potatoes, perfect for baking, roasting, or mashing.',
        'price': 3.25,
        'imageUrl': 'https://images.unsplash.com/photo-1577389280673-1dffb1c6ee2f?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 6)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.3,
        'origin': 'Harvest Fields'
      },
      {
        'name': 'Organic Kale',
        'description': 'Nutritious and versatile organic kale, perfect for salads, smoothies, and cooking.',
        'price': 3.49,
        'imageUrl': 'https://images.unsplash.com/photo-1582515073493-ffef4e9d1b4a?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.8,
        'origin': 'Pure Greens Farm'
      },
      {
        'name': 'Broccoli Head',
        'description': 'Fresh broccoli with firm stalks and tight florets. Excellent source of vitamins.',
        'price': 2.79,
        'imageUrl': 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.1,
        'origin': 'Valley Vista Gardens'
      },
      {
        'name': 'Red Bell Peppers',
        'description': 'Sweet and crunchy red bell peppers. Great for roasting, stuffing, or eating raw.',
        'price': 1.99,
        'imageUrl': 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.4,
        'origin': 'Sunset Fields'
      },
      {
        'name': 'Cucumber Pack',
        'description': 'Crisp and refreshing cucumbers. Perfect for salads, sandwiches, or infused water.',
        'price': 2.29,
        'imageUrl': 'https://images.unsplash.com/photo-1567375698348-5d9d5a9f6c1c?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.0,
        'origin': 'Fresh Fields Farm'
      },
      {
        'name': 'Zucchini',
        'description': 'Fresh zucchini. Versatile for grilling, sautéing, or using in baked goods.',
        'price': 1.79,
        'imageUrl': 'https://images.unsplash.com/photo-1596451190630-186aff535bf2?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.2,
        'origin': 'Garden Valley'
      },
      {
        'name': 'Fresh Lettuce',
        'description': 'Crisp, fresh lettuce for salads and sandwiches. Hydroponically grown.',
        'price': 2.49,
        'imageUrl': 'https://images.unsplash.com/photo-1622206151601-6e157ce9d0b5?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'category': 'vegetables',
        'inStock': 1,
        'rating': 4.6,
        'origin': 'Hydro Farms'
      },
      
      // Fruits
      {
        'name': 'Avocado Set',
        'description': 'Premium avocados ready to eat. High in healthy fats and perfect for sandwiches and salads.',
        'price': 5.99,
        'imageUrl': 'https://images.unsplash.com/photo-1519162808019-7de1683fa2ad?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.9,
        'origin': 'Tropical Hills Farm'
      },
      {
        'name': 'Fresh Strawberries',
        'description': 'Sweet and juicy strawberries, perfect for snacking or adding to desserts.',
        'price': 4.99,
        'imageUrl': 'https://images.unsplash.com/photo-1556228722-0317997e9c8d?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.6,
        'origin': 'Berry Good Farm'
      },
      {
        'name': 'Organic Apples',
        'description': 'Crisp and delicious organic apples, perfect for snacking and baking.',
        'price': 2.99,
        'imageUrl': 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.4,
        'origin': 'Apple Valley Orchards'
      },
      {
        'name': 'Fresh Blueberries',
        'description': 'Plump and sweet blueberries, perfect for smoothies, baking, or snacking.',
        'price': 5.99,
        'imageUrl': 'https://images.unsplash.com/photo-1519183071298-a2962b2e8e04?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.7,
        'origin': 'Blue Mountain Berry Farm'
      },
      {
        'name': 'Fresh Bananas',
        'description': 'Perfectly ripened bananas. Rich in potassium and perfect for smoothies or snacking.',
        'price': 1.99,
        'imageUrl': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.3,
        'origin': 'Tropical Paradise Farm'
      },
      {
        'name': 'Juicy Oranges',
        'description': 'Sweet and tangy oranges packed with vitamin C. Perfect for juicing or eating.',
        'price': 3.49,
        'imageUrl': 'https://images.unsplash.com/photo-1547514701-42782101795e?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.5,
        'origin': 'Citrus Grove Farm'
      },
      {
        'name': 'Watermelon',
        'description': 'Refreshing watermelon with sweet, juicy flesh. Perfect for hot summer days.',
        'price': 5.99,
        'imageUrl': 'https://images.unsplash.com/photo-1563114773-84221bd62daa?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.6,
        'origin': 'Sun Valley Melons'
      },
      {
        'name': 'Ripe Mangoes',
        'description': 'Sweet and fragrant mangoes. Perfect for smoothies, desserts, or enjoying fresh.',
        'price': 6.99,
        'imageUrl': 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.8,
        'origin': 'Tropical Treasures'
      },
      {
        'name': 'Fresh Pineapple',
        'description': 'Sweet and juicy pineapple. Rich in vitamins and perfect for fruit salads or grilling.',
        'price': 4.49,
        'imageUrl': 'https://images.unsplash.com/photo-1589820296156-2454bb8a6ad1?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.5,
        'origin': 'Tropical Farms'
      },
      {
        'name': 'Organic Grapes',
        'description': 'Sweet and juicy organic grapes. Perfect for snacking or cheese pairings.',
        'price': 3.99,
        'imageUrl': 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 6)).toIso8601String(),
        'category': 'fruits',
        'inStock': 1,
        'rating': 4.4,
        'origin': 'Vineyard Hills'
      },
      
      // Dairy & Eggs
      {
        'name': 'Farm Fresh Eggs',
        'description': 'Free-range eggs from our local farm. Ethically sourced and perfect for breakfast.',
        'price': 4.50,
        'imageUrl': 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'category': 'dairy',
        'inStock': 1,
        'rating': 4.8,
        'origin': 'Happy Hen Farm'
      },
      {
        'name': 'Organic Whole Milk',
        'description': 'Fresh organic whole milk from grass-fed cows. Creamy and nutritious.',
        'price': 3.99,
        'imageUrl': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'category': 'dairy',
        'inStock': 1,
        'rating': 4.5,
        'origin': 'Green Pastures Dairy'
      },
      {
        'name': 'Artisan Cheese Selection',
        'description': 'Assortment of handcrafted artisan cheeses. Perfect for cheese boards and cooking.',
        'price': 12.99,
        'imageUrl': 'https://images.unsplash.com/photo-1559561853-08451507cbe7?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 6)).toIso8601String(),
        'category': 'dairy',
        'inStock': 1,
        'rating': 4.9,
        'origin': 'Heritage Creamery'
      },
      {
        'name': 'Greek Yogurt',
        'description': 'Creamy and protein-rich Greek yogurt. Perfect for breakfast or healthy snacking.',
        'price': 3.49,
        'imageUrl': 'https://images.unsplash.com/photo-1620153868488-87582d4e3eee?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
        'category': 'dairy',
        'inStock': 1,
        'rating': 4.7,
        'origin': 'Mediterranean Dairy'
      },
      {
        'name': 'Organic Butter',
        'description': 'Creamy organic butter made from grass-fed cow\'s milk. Perfect for cooking and baking.',
        'price': 4.99,
        'imageUrl': 'https://images.unsplash.com/photo-1589985270958-a664865d792e?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
        'category': 'dairy',
        'inStock': 1,
        'rating': 4.6,
        'origin': 'Green Meadows Farm'
      },
      
      // Herbs
      {
        'name': 'Fresh Basil Bundle',
        'description': 'Fragrant fresh basil leaves. Perfect for Italian dishes and homemade pesto.',
        'price': 2.29,
        'imageUrl': 'https://images.unsplash.com/photo-1601133269386-97e224ba2bc8?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
        'category': 'herbs',
        'inStock': 1,
        'rating': 4.7,
        'origin': 'Herbaceous Gardens'
      },
      {
        'name': 'Organic Rosemary',
        'description': 'Aromatic fresh rosemary sprigs. Perfect for roasts, potatoes, and Mediterranean dishes.',
        'price': 2.49,
        'imageUrl': 'https://images.unsplash.com/photo-1515586000433-45406d8e6662?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
        'category': 'herbs',
        'inStock': 1,
        'rating': 4.6,
        'origin': 'Fragrant Herb Farm'
      },
      {
        'name': 'Fresh Mint',
        'description': 'Refreshing mint leaves. Perfect for teas, cocktails, and Mediterranean dishes.',
        'price': 1.99,
        'imageUrl': 'https://images.unsplash.com/photo-1628157588553-5eeea00af15c?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'category': 'herbs',
        'inStock': 1,
        'rating': 4.5,
        'origin': 'Mint Valley Farm'
      },
      {
        'name': 'Cilantro Bunch',
        'description': 'Fresh cilantro. Essential for Mexican, Indian, and Thai cuisines.',
        'price': 1.79,
        'imageUrl': 'https://images.unsplash.com/photo-1592544756231-a20fea1c7137?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'category': 'herbs',
        'inStock': 1,
        'rating': 4.3,
        'origin': 'Fresh Herb Garden'
      },
      
      // Grains
      {
        'name': 'Organic Quinoa',
        'description': 'Protein-rich organic quinoa. Perfect for salads, bowls, and sides.',
        'price': 5.99,
        'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e8ac?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 9)).toIso8601String(),
        'category': 'grains',
        'inStock': 1,
        'rating': 4.5,
        'origin': 'Ancient Grains Farm'
      },
      {
        'name': 'Brown Rice',
        'description': 'Wholesome brown rice. High in fiber and perfect for various dishes.',
        'price': 3.49,
        'imageUrl': 'https://images.unsplash.com/photo-1594489573280-5c5c481ca2d2?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
        'category': 'grains',
        'inStock': 1,
        'rating': 4.2,
        'origin': 'Golden Fields Farm'
      },
      {
        'name': 'Organic Oats',
        'description': 'Hearty organic rolled oats. Perfect for breakfast porridge, baking, or granola.',
        'price': 4.29,
        'imageUrl': 'https://images.unsplash.com/photo-1616046759323-433641f21931?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
        'category': 'grains',
        'inStock': 1,
        'rating': 4.4,
        'origin': 'Morning Harvest Farm'
      },
      {
        'name': 'Wild Rice Blend',
        'description': 'Nutritious blend of wild and whole grain rice. Nutty flavor for gourmet side dishes.',
        'price': 6.49,
        'imageUrl': 'https://images.unsplash.com/photo-1552963944-5f0b27f0a4e8?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
        'category': 'grains',
        'inStock': 1,
        'rating': 4.6,
        'origin': 'Wildlands Farm'
      },
    ];

    // Use transaction and batch for faster insertion
    await db.transaction((txn) async {
      Batch batch = txn.batch();
      for (var product in dummyProducts) {
        batch.insert('products', product);
      }
      await batch.commit(noResult: true);
    });
  }

  // Optimized CRUD operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  // Get products with pagination and category filtering
  Future<List<Product>> getProducts({int limit = 20, int offset = 0, String? category}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    
    if (category != null && category.isNotEmpty) {
      maps = await db.query(
        'products',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'id DESC',
        limit: limit,
        offset: offset,
      );
    } else {
      maps = await db.query(
        'products',
        orderBy: 'id DESC',
        limit: limit,
        offset: offset,
      );
    }
    
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // Get a single product by ID with caching
  Future<Product?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? Product.fromMap(maps.first) : null;
  }

  // Update an existing product
  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete a product by ID
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Get featured products (highest rated)
  Future<List<Product>> getFeaturedProducts({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'rating DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }
  
  // Get recently added products
  Future<List<Product>> getRecentProducts({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }
  
  // Method to optimize database performance
  Future<void> optimize() async {
    final db = await database;
    await db.execute('VACUUM');
    await db.execute('ANALYZE');
  }
}
