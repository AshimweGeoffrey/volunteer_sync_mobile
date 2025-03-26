import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmora/models/product.dart';
import 'package:farmora/services/database_helper.dart';
import 'package:farmora/services/image_picker_service.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  ProductFormScreen({this.product});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _imageUrl = '';
  bool _isLoading = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ImagePickerService _imagePickerService = ImagePickerService();

  // Updated colors
  final Color _primaryColor = Color(0xFF1E88E5);
  final Color _accentColor = Color(0xFF26A69A);

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrl = widget.product!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imagePath = await _imagePickerService.pickImage(source);
      if (imagePath != null) {
        setState(() {
          _imageUrl = imagePath;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image for the product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text;
      final description = _descriptionController.text;
      final price = double.parse(_priceController.text);

      if (widget.product == null) {
        // Create new product
        final product = Product(
          name: name,
          description: description,
          price: price,
          imageUrl: _imageUrl,
          createdAt: DateTime.now(),
        );
        await _databaseHelper.insertProduct(product);
      } else {
        // Update existing product
        final updatedProduct = Product(
          id: widget.product!.id,
          name: name,
          description: description,
          price: price,
          imageUrl: _imageUrl,
          createdAt: widget.product!.createdAt,
        );
        await _databaseHelper.updateProduct(updatedProduct);
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image picker
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _showImagePickerOptions();
                        },
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _imageUrl.isEmpty 
                                  ? _primaryColor 
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: _imageUrl.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: _primaryColor,
                                      size: 48,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: _imageUrl.startsWith('http')
                                      ? Image.network(
                                          _imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                              Icon(Icons.image_not_supported, 
                                                  color: Colors.grey, size: 48),
                                        )
                                      : Image.file(
                                          File(_imageUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                              Icon(Icons.image_not_supported, 
                                                  color: Colors.grey, size: 48),
                                        ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Name field
                    Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Enter product name',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Description field
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Enter product description',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    
                    // Price field
                    Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Enter product price',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor),
                        ),
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: Colors.black87),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        child: Text(
                          widget.product == null ? 'Add Product' : 'Update Product',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    context,
                    Icons.camera_alt,
                    'Camera',
                    () => _pickImage(ImageSource.camera),
                  ),
                  _buildImageSourceOption(
                    context,
                    Icons.photo_library,
                    'Gallery',
                    () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: _primaryColor,
              size: 36,
            ),
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
