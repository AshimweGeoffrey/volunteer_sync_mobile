import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmora/models/product.dart';
import 'package:farmora/services/database_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:farmora/screens/product_detail_screen.dart';
import 'package:farmora/screens/product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Product> _products = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final products = await _databaseHelper.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: Color(0xFF6200EE),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshProducts,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductFormScreen()),
              );
              if (result == true) {
                _refreshProducts();
              }
            },
          ),
        ],
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? _buildEmptyState()
              : _buildProductList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Color(0xFF6200EE).withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No products available',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductFormScreen()),
              );
              if (result == true) {
                _refreshProducts();
              }
            },
            icon: Icon(Icons.add),
            label: Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6200EE),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Slidable(
          key: Key(product.id.toString()),
          startActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductFormScreen(product: product),
                    ),
                  );
                  if (result == true) {
                    _refreshProducts();
                  }
                },
                backgroundColor: Color(0xFF03DAC6),
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  _showDeleteConfirmationDialog(product);
                },
                backgroundColor: Color(0xFFB00020),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Color(0xFF1E1E1E),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
                if (result == true) {
                  _refreshProducts();
                }
              },
              onDoubleTap: () {
                _showFullSizeImage(context, product.imageUrl);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () {
                          _showFullSizeImage(context, product.imageUrl);
                        },
                        child: Hero(
                          tag: 'product-image-${product.id}',
                          child: Container(
                            width: 80,
                            height: 80,
                            child: product.imageUrl.startsWith('http')
                                ? Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                        Icon(Icons.image_not_supported, color: Colors.grey),
                                  )
                                : Image.file(
                                    File(product.imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                        Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            product.description.length > 60
                                ? '${product.description.substring(0, 60)}...'
                                : product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF03DAC6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullSizeImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                    )
                  : Image.file(
                      File(imageUrl),
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text('Delete Product', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete ${product.name}?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Color(0xFF03DAC6))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Color(0xFFB00020))),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _databaseHelper.deleteProduct(product.id!);
                  _refreshProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} deleted'),
                      backgroundColor: Color(0xFFB00020),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
