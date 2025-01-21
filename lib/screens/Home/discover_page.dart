import 'package:flutter/material.dart';
import '../Notification/notification_page.dart';
import '../../models/product.dart';
import '../../config/AppStyles.dart' as config;
import '../../widgets/product_card.dart';
import '../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String selectedCategory = 'All';
  final searchController = TextEditingController();
  bool isLoading = false;
  String searchQuery = '';
  final FirebaseService _firebaseService = FirebaseService();
  List<Product> products = [];
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fonction pour charger les catégories
  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedCategories = await _firebaseService.getCategories();
      setState(() {
        categories = ['All', ...fetchedCategories]; // Ajoute 'All' aux catégories
      });
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors du chargement des catégories: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fonction pour charger les produits
  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedProducts = await _firebaseService.getProducts();
      setState(() {
        products = fetchedProducts;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors du chargement des produits: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fonction pour filtrer les produits en fonction de la catégorie et de la recherche
  List<Product> _filterProducts() {
    List<Product> filteredProducts = products;

    // Filtrage par catégorie
    if (selectedCategory != 'All') {
      filteredProducts = filteredProducts.where((product) {
        return product.category == selectedCategory;
      }).toList();
    }

    // Filtrage par recherche
    if (searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.brand.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filteredProducts;
  }

  // Fonction pour gérer le changement de catégorie
  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filterProducts();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadProducts();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildSalesBanner(),
                      const SizedBox(height: 24),
                      _buildCategoriesSection(),
                    ],
                  ),
                ),
              ),
              isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : filteredProducts.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(child: Text('Aucun produit trouvé')),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: _buildProductsGrid(filteredProducts),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour l'en-tête de la page
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Discover', style: config.AppStyles.headerText),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget pour la barre de recherche
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          icon: const Icon(Icons.search),
          hintText: 'Search products...',
          border: InputBorder.none,
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  // Widget pour la bannière de vente
  Widget _buildSalesBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: 0,
            child: Image.asset(
              'assets/img/product_6.png',
              height: 160,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flash Sale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Up to 50% off on\nselected items',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Shop Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour la section des catégories
  Widget _buildCategoriesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Categories', style: config.AppStyles.titleText),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryChip(
                categories[index],
                isSelected: categories[index] == selectedCategory,
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget pour un chip de catégorie
  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _onCategorySelected(label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Chip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: isSelected ? AppColors.primary : AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  // Widget pour la grille des produits
  Widget _buildProductsGrid(List<Product> productsToDisplay) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = productsToDisplay[index];
          return ProductCard(
            product: product,
            onFavoriteChanged: (productId, isFavorite) async {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez vous connecter pour ajouter aux favoris'),
                  ),
                );
                return;
              }

              try {
                if (isFavorite) {
                  await FirebaseService().addToFavorites(userId, productId);
                } else {
                  await FirebaseService().removeFromFavorites(userId, productId);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de la mise à jour des favoris: $e'),
                  ),
                );
              }
            },
            onAddToCart: (productId) async {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez vous connecter pour ajouter des articles au panier'),
                  ),
                );
                return;
              }

              try {
                await FirebaseService().addToCart(userId, productId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} ajouté au panier'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de l\'ajout au panier: $e'),
                  ),
                );
              }
            },
          );
        },
        childCount: productsToDisplay.length,
      ),
    );
  }
}