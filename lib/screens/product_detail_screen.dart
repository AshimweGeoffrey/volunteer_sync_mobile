import 'package:flutter/material.dart';
import 'package:farmora/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF1E88E5);
    final Color accentColor = Color(0xFF26A69A);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with optimization
            Hero(
              tag: 'product_image_${product.id}',
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.error),
                ),
              ),
            ),
            
            // Product details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < product.rating.floor()
                              ? Icons.star
                              : (index == product.rating.floor() && 
                                 product.rating % 1 > 0)
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                      SizedBox(width: 8),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Category and origin
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey[700]),
                      SizedBox(width: 4),
                      Text(
                        product.category,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                      SizedBox(width: 4),
                      Text(
                        product.origin,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // Date
                  Text(
                    'Added on ${DateFormat('MMMM d, yyyy').format(product.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  
                  Divider(height: 32),
                  
                  // Description title
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Description
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added to cart!'),
                            backgroundColor: accentColor,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
}
