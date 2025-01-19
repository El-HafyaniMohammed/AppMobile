import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:project/models/product.dart';
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoriteScreen> {
  final List<Product> favoriteProducts = [
    Product(
      id: '1',
      name: 'AirPods',
      brand: 'Apple',
      price: 132.00,
      rating: 4.8,
      imagePath: 'assets/img/product_4.png',
      isOnSale: true,
      salePrice: 119.99,
      isFavorite: true,
    ),
    Product(
      id: '2',
      name: 'MacBook Air M1',
      brand: 'Apple',
      price: 1100.00,
      rating: 4.9,
      imagePath: 'assets/img/product_5.png',
      isFavorite: true,
    ),
    Product(
      id: '3',
      name: 'Galaxy Watch 5',
      brand: 'Samsung',
      price: 299.00,
      rating: 4.7,
      imagePath: 'assets/img/product_6.png',
      isOnSale: true,
      salePrice: 399.99,
    ),
  ];

  bool _isGridView = true;
  String _sortBy = 'name'; // 'name', 'price', 'brand'
  bool _isLoading = false;

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _sortProducts(String criteria) {
    setState(() {
      _sortBy = criteria;
      switch (criteria) {
        case 'name':
          favoriteProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'price':
          favoriteProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'brand':
          favoriteProducts.sort((a, b) => a.brand.compareTo(b.brand));
          break;
      }
    });
  }

  Future<void> _refreshProducts() async {
    setState(() => _isLoading = true);
    // Simuler un chargement
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void removeFromFavorites(String productId) {
    setState(() {
      favoriteProducts.removeWhere((product) => product.id == productId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from favorites'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              favoriteProducts.add(
                favoriteProducts.firstWhere((product) => product.id == productId),
              );
            });
          },
        ),
      ),
    );
  }

  void clearFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites'),
        content: const Text('Remove all items from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                favoriteProducts.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All favorites cleared')),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildAppBarButton(
        icon: Icons.arrow_back_ios_new,
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        ),
      ),
      title: const Text(
        'Favorites',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      actions: [
        _buildAppBarButton(
          icon: _isGridView ? Icons.view_list : Icons.grid_view,
          onPressed: _toggleViewMode,
        ),
        _buildAppBarButton(
          icon: Icons.sort,
          onPressed: () => _showSortingBottomSheet(),
        ),
        _buildAppBarButton(
          icon: Icons.delete_outline,
          color: Colors.red,
          onPressed: favoriteProducts.isEmpty ? null : clearFavorites,
        ),
      ],
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.black, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  void _showSortingBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption('Name', 'name'),
            _buildSortOption('Price', 'price'),
            _buildSortOption('Brand', 'brand'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value) {
    return ListTile(
      leading: Icon(
        value == _sortBy ? Icons.radio_button_checked : Icons.radio_button_off,
        color: Colors.green,
      ),
      title: Text(title),
      onTap: () {
        _sortProducts(value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favoriteProducts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: _isGridView ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your favorites',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Discover Products', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) => _buildProductCard(favoriteProducts[index]),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildProductListItem(favoriteProducts[index]),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildProductImage(product),
                _buildFavoriteButton(product),
                if (product.isOnSale) _buildSaleTag(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.brand,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPriceRow(product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    product.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                if (product.isOnSale) _buildSaleTag(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _buildFavoriteButton(product),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceColumn(product),
                      _buildAddToCartButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      width: double.infinity,
      child: Image.asset(
        product.imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildFavoriteButton(Product product) {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton(
        icon: const Icon(
          Icons.favorite,
          color: Colors.red,
        ),
        onPressed: () => removeFromFavorites(product.id),
      ),
    );
  }

  Widget _buildSaleTag() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Sale',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPriceColumn(product),
        _buildAddToCartButton(),
      ],
    );
  }

  Widget _buildPriceColumn(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.isOnSale) ...[
          Text(
            '${product.salePrice?.toStringAsFixed(2)} Dh',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            '${product.price.toStringAsFixed(2)} Dh',
            style: TextStyle(
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[600],            ),
          ),
        ] else
          Text(
            '${product.price.toStringAsFixed(2)} Dh',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to cart'),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Add to Cart',
        style: TextStyle(fontSize: 12, color: Colors.white),
        
      ),
    );
  }
}
