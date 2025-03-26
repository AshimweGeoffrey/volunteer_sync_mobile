import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmora/models/product.dart';
import 'package:farmora/screens/product_form_screen.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: Color(0xFF6200EE),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(product: product),
                ),
              );
              if (result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with hero animation
            GestureDetector(
              onTap: () {
                _showFullSizeImage(context);
              },
              child: Hero(
                tag: 'product-image-${product.id}',
                child: Container(
                  width: double.infinity,
                  height: 300,
                  child: product.imageUrl.startsWith('http')
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(product.imageUrl),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Price
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF03DAC6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Added on ${DateFormat('MMM d, yyyy').format(product.createdAt)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullSizeImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Hero(
              tag: 'product-image-${product.id}',
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: product.imageUrl.startsWith('http')
                    ? Image.network(product.imageUrl)
                    : Image.file(File(product.imageUrl)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
