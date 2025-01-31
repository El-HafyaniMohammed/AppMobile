import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:project/models/product.dart';
import 'package:project/services/firebase_service.dart'; // Adjust the path as necessary
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Home/ProductDetailPage.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoriteScreen> {
  List<Product> favoriteProducts = [];
  // ignore: unused_field
  final FirebaseService _firebaseService = FirebaseService();
  bool _isGridView = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _sortBy = 'name'; // 'name', 'price', 'brand'
  bool _isLoading = false;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts(); // Charger les produits favoris au démarrage
  }

  Future<void> _loadFavoriteProducts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      setState(() => _isLoading = true);
      try {
        final products = await _firebaseService.getFavoriteProducts(userId);
        setState(() {
          favoriteProducts = products;
          _isLoading = false;
        });
      } catch (e) {
        print('Erreur lors du chargement des favoris: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> updateProductFavoriteStatus(
      String productId, bool isFavorite) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isFavorite': isFavorite,
      });
      print('Statut favori mis à jour pour le produit $productId: $isFavorite');
    } catch (e) {
      print('Erreur lors de la mise à jour du statut favori: $e');
    }
  }

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
                _firebaseService.clearFavorites(userId);
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: _buildAppBarButton(
        icon: Icons.arrow_back_ios_new,
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        ),
      ),
      title: Text(
        'Favorites',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        _buildAppBarButton(
          icon: _isGridView ? Icons.view_list : Icons.grid_view,
          onPressed: _toggleViewMode,
        ),
        _buildAppBarButton(
          icon: Icons.sort,
          onPressed: () => _showEnhancedSortingBottomSheet(),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: onPressed != null ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: onPressed != null 
            ? Colors.grey.shade200 
            : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon, 
          color: onPressed != null 
            ? (color ?? Colors.black) 
            : Colors.grey,
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _showEnhancedSortingBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.75,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Sort Favorites',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _buildSortOption('Name', 'name'),
            _buildSortOption('Price', 'price'),
            _buildSortOption('Brand', 'brand'),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSortOption(String title, String value) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
    leading: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: value == _sortBy 
          ? Colors.green.shade50 
          : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: value == _sortBy 
            ? Colors.green 
            : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          value == _sortBy 
            ? Icons.check_circle 
            : Icons.circle_outlined,
          color: value == _sortBy 
            ? Colors.green 
            : Colors.grey.shade300,
          size: 20,
        ),
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        color: Colors.black87,
        fontWeight: value == _sortBy ? FontWeight.w700 : FontWeight.w500,
      ),
    ),
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
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade100.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.green.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 22,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore and add items you love to your favorites',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              shadowColor: Colors.green.withOpacity(0.4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Discover Products', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Icon(Icons.shopping_bag_outlined, size: 20 ,color: Colors.white,),
              ],
            ),
          ),
        ],
      ),
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
      itemBuilder: (context, index) =>
          _buildProductCard(favoriteProducts[index]),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _buildProductListItem(favoriteProducts[index]),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
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
                        _buildAddToCartButton(product),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        onPressed: () async {
          // Mettre à jour le statut favori dans Firestore
          await updateProductFavoriteStatus(product.id, false);

          // Mettre à jour la liste locale des favoris
          setState(() {
            removeFromFavorites(
                FirebaseAuth.instance.currentUser!.uid, product.id);
          });

          // Afficher un message à l'utilisateur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} removed from favorites')),
          );
        },
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
        _buildAddToCartButton(product),
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
              color: Colors.grey[600],
            ),
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

  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();
      setState(() {
        favoriteProducts.removeWhere((product) => product.id == productId);
      });
      print('Produit $productId supprimé des favoris');
    } catch (e) {
      print('Erreur lors de la suppression du produit des favoris: $e');
    }
  }

  Widget _buildAddToCartButton(Product product) {
    return ElevatedButton(
      onPressed: () async {
        if (product.sizes.isNotEmpty || product.colors.isNotEmpty) {
          await _showSizeAndColorDialog(product);
        } else {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to add to cart')),
            );
            return;
          }

          try {
            await _firebaseService.addToCart(
              userId,
              product.id,
              quantity: 1,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} added to cart')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding to cart: $e')),
            );
          }
        }
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

  Future<void> _showSizeAndColorDialog(Product product) async {
    String? selectedSize;
    String? selectedColor;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Options'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (product.sizes.isNotEmpty) ...[
                    const Text('Select Size'),
                    DropdownButton<String>(
                      value: selectedSize,
                      onChanged: (value) {
                        setState(() {
                          selectedSize =
                              value; // Mettre à jour la taille sélectionnée
                        });
                      },
                      items: product.sizes.map((size) {
                        return DropdownMenuItem(
                          value: size,
                          child: Text(size),
                        );
                      }).toList(),
                    ),
                  ],
                  if (product.colors.isNotEmpty) ...[
                    const Text('Select Color'),
                    DropdownButton<String>(
                      value: selectedColor,
                      onChanged: (value) {
                        setState(() {
                          selectedColor =
                              value; // Mettre à jour la couleur sélectionnée
                        });
                      },
                      items: product.colors.map((color) {
                        return DropdownMenuItem(
                          value: color,
                          child: Text(color),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId != null) {
                      try {
                        await _firebaseService.addToCart(
                          userId,
                          product.id,
                          quantity: 1,
                          size: selectedSize,
                          color: selectedColor,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${product.name} added to cart')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding to cart: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}