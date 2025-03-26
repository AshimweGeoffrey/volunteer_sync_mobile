class Product {
  int? id;
  String name;
  String description;
  double price;
  String imageUrl;
  DateTime createdAt;
  String category;
  bool inStock;
  double rating;
  String origin;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.createdAt,
    this.category = 'general',
    this.inStock = true,
    this.rating = 4.0,
    this.origin = 'Local Farm',
  });

  // Convert product to map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'inStock': inStock ? 1 : 0,
      'rating': rating,
      'origin': origin,
    };
  }

  // Create product from map - optimized for performance
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'],
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      category: map['category'] ?? 'general',
      inStock: map['inStock'] == 1,
      rating: map['rating'] is int ? (map['rating'] as int).toDouble() : (map['rating'] ?? 4.0),
      origin: map['origin'] ?? 'Local Farm',
    );
  }

  // Create a copy of the product with updated fields
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    DateTime? createdAt,
    String? category,
    bool? inStock,
    double? rating,
    String? origin,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      inStock: inStock ?? this.inStock,
      rating: rating ?? this.rating,
      origin: origin ?? this.origin,
    );
  }
}
