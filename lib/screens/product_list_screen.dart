import 'package:flutter/material.dart';
import 'package:farmora/models/product.dart';
import 'package:farmora/services/database_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:farmora/screens/product_detail_screen.dart';
import 'package:farmora/screens/product_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Product> _products = [];
  bool _isLoading = true;
  final Color _primaryColor = Color(0xFF1E88E5);
  final Color _accentColor = Color(0xFF26A69A);
  
  // Pagination variables
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _hasMoreItems = true;
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  
  // Categories for filtering
  final List<String> _categories = [
    'All',
    'vegetables',
    'fruits',
    'dairy',
    'herbs',
    'grains'
  ];
  
  @override
  bool get wantKeepAlive => true; // Keep alive for better performance when navigating
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadProducts();
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMoreItems) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _products = [];
    });
    
    try {
      final products = await _databaseHelper.getProducts(
        limit: _itemsPerPage,
        offset: 0,
        category: _selectedCategory != 'All' ? _selectedCategory : null,
      );
      
      setState(() {
        _products = products;
        _hasMoreItems = products.length == _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading products: $e');
    }
  }
  
  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMoreItems) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final nextPage = _currentPage + 1;
      final moreProducts = await _databaseHelper.getProducts(
        limit: _itemsPerPage,
        offset: nextPage * _itemsPerPage,
        category: _selectedCategory != 'All' ? _selectedCategory : null,
      );
      
      setState(() {
        if (moreProducts.isNotEmpty) {
          _products.addAll(moreProducts);
          _currentPage = nextPage;
        }
        _hasMoreItems = moreProducts.length == _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading more products: $e');
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category == 'All' ? null : category;
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToProductForm,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading && _products.isEmpty
                ? Center(child: CircularProgressIndicator(color: _primaryColor))
                : _products.isEmpty
                    ? _buildEmptyState()
                    : _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToProductForm,
        backgroundColor: _primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = 
              (category == 'All' && _selectedCategory == null) ||
              category == _selectedCategory;
          
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: _primaryColor,
              onSelected: (selected) {
                if (selected) {
                  _filterByCategory(category == 'All' ? null : category);
                }
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: _primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(8),
        itemCount: _products.length + (_hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return _buildLoadingIndicator();
          }
          
          return _buildProductCard(_products[index]);
        },
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
  
  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Slidable(
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _editProduct(product),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) => _deleteProduct(product.id!),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Hero(
                  tag: 'product_image_${product.id}',
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 120,
                    height: 120,
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
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Chip(
                            label: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: _accentColor,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Origin: ${product.origin}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: 2),
                              Text(
                                product.rating.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Spacer(),
                          Text(
                            DateFormat('MMM d').format(product.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
            color: _primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No products available',
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _navigateToProductForm,
            icon: Icon(Icons.add),
            label: Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
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

  Future<void> _navigateToProductForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductFormScreen()),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await _databaseHelper.deleteProduct(id);
      _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      _showErrorSnackBar('Error deleting product: $e');
    }
  }
}
