// ignore_for_file: unused_field, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../Notification/notification_page.dart';
import '../../models/product.dart';
import '../../config/AppStyles.dart' as config;
import '../../widgets/product_card.dart';
import '../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProductDetailPage.dart';
import '../dashboard/AddProductPage.dart';
import '../dashboard/MyProductsPage.dart';
import '../dashboard/SalesAnalyticsPage.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with TickerProviderStateMixin {
  String selectedCategory = 'All';
  final searchController = TextEditingController();
  bool isLoading = false;
  String searchQuery = '';
  final FirebaseService _firebaseService = FirebaseService();
  List<Product> products = [];
  List<String> categories = [];
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final List<GlobalKey> _productKeys = [];
  bool _isMenuOpen = false;
  bool _isSearchVisible = false;
  late AnimationController _menuAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchWidthAnimation;
  @override
  void initState() {
    super.initState();
    // Initialisation des animations pour le champ de recherche
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _searchWidthAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Initialisation des animations pour le menu utilisateur
    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Initialize fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

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
    _fadeController.dispose();
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
        categories = [
          'All',
          ...fetchedCategories
        ]; // Ajoute 'All' aux catégories
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
        // Create animation keys for each product
        _productKeys.clear();
        for (var i = 0; i < products.length; i++) {
          _productKeys.add(GlobalKey());
        }
      });
      _fadeController.forward(from: 0.0);
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filterProducts();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => await _loadProducts(),
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
                          child: Center(child: CircularProgressIndicator()))
                      : filteredProducts.isEmpty
                          ? const SliverFillRemaining(
                              child:
                                  Center(child: Text('Aucun produit trouvé')))
                          : SliverPadding(
                              padding: const EdgeInsets.all(16),
                              sliver: _buildProductsGrid(filteredProducts),
                            ),
                ],
              ),
            ),
          ),
          if (_isMenuOpen) _buildUserMenu(),
        ],
      ),
    );
  }

  Widget _buildUserMenu() {
    return Positioned(
      top: 120,
      right: 20,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _menuAnimationController,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: _menuAnimationController,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête du menu vendeur
                _buildSellerMenuHeader(),

                const Divider(height: 1),

                // Options de gestion des produits
                _buildSellerMenuItem(
                  icon: Icons.add_box_outlined,
                  label: 'Add New Product',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddProductPage()),
                  ),
                ),
                _buildSellerMenuItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'My Products',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MyProductsPage()),
                  ),
                ),
                _buildSellerMenuItem(
                  icon: Icons.analytics_outlined,
                  label: 'Sales Analytics',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SalesAnalyticsPage()),
                  ),
                ),
                _buildSellerMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Orders Management',
                  badge: '3',
                  onTap: () =>
                      Navigator.pushNamed(context, '/orders-management'),
                ),

                const Divider(height: 1),

                // Paramètres boutique
                _buildSellerMenuItem(
                  icon: Icons.storefront_outlined,
                  label: 'Shop Settings',
                  onTap: () => Navigator.pushNamed(context, '/shop-settings'),
                ),
                _buildSellerMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Payment Settings',
                  onTap: () =>
                      Navigator.pushNamed(context, '/payment-settings'),
                ),

                const Divider(height: 1),

                // Switch to buyer mode
                _buildSwitchToBuyerMode(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSellerMenuHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.store, color: Colors.green[700], size: 24),
          const SizedBox(width: 12),
          const Text(
            'Seller Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerMenuItem({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Colors.grey[700]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchToBuyerMode() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Logique pour basculer en mode acheteur
          _toggleMenu();
          // Ajouter ici la navigation ou le changement d'état
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 20,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Switch to Buyer Mode',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour l'en-tête de la page
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Title and subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Discover',
                          style: config.AppStyles.headerText.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore our latest collection',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // Right side - Actions
                Row(
                  children: [
                    _buildSearchButton(),
                    const SizedBox(width: 12),
                    _buildEnhancedNotificationButton(),
                    const SizedBox(width: 12),
                    _buildEnhancedProfileButton(),
                  ],
                ),
              ],
            ),
            if (_isSearchVisible) ...[
              const SizedBox(height: 16),
              _buildExpandedSearchBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _isSearchVisible = !_isSearchVisible;
            if (_isSearchVisible) {
              _searchAnimationController.forward();
            } else {
              _searchAnimationController.reverse();
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isSearchVisible ? Icons.close : Icons.search,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedNotificationButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: Colors.grey[700],
                size: 20,
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 8,
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedProfileButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _menuAnimationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _menuAnimationController.value * 0.5,
                    child: Icon(
                      _isMenuOpen ? Icons.close : Icons.menu,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedSearchBar() {
    return AnimatedBuilder(
      animation: _searchAnimationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _searchAnimationController,
          child: FadeTransition(
            opacity: _searchAnimationController,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      _isMenuOpen
          ? _menuAnimationController.forward()
          : _menuAnimationController.reverse();
    });
  }

  // Widget pour la bannière de vente
  Widget _buildSalesBanner() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          // Main container with gradient
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: GridPatternPainter(),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timer badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(
                          Icons.timer_outlined,
                          color: Color(0xFF4CAF50),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Limited time offer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Main text
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Colors.white, Color(0xFFE8F5E9)],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Up to 50% OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  'on selected items',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Review section
                Row(
                  children: [
                    // Star rating
                    Row(
                      children: List.generate(
                          5,
                          (index) => Icon(
                                Icons.star,
                                color:
                                    index < 4 ? Colors.amber : Colors.white24,
                                size: 16,
                              )),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '4.8 (256 reviews)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Action button
                Row(
                  children: [
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop Now',
                            style: TextStyle(
                              color: const Color(0xFF4CAF50),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF4CAF50),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
            ),
          ),
          Positioned(
            right: -45,
            top: -45,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
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
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(
                  begin: 0.0,
                  end: categories[index] == selectedCategory ? 1.0 : 0.0,
                ),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (0.05 * value),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          Colors.transparent,
                          AppColors.primary,
                          value,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color.lerp(
                            AppColors.primary.withOpacity(0.3),
                            Colors.transparent,
                            value,
                          )!,
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            setState(() {
                              selectedCategory = categories[index];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                color: Color.lerp(
                                  AppColors.primary,
                                  Colors.white,
                                  value,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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
          // Add staggered animation delay based on index
          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              final delay = (index * 100).clamp(0, 500).toDouble();
              final slideAnimation = CurvedAnimation(
                parent: _fadeAnimation,
                curve: Interval(
                  delay / 1000,
                  (delay + 500) / 1000,
                  curve: Curves.easeOutQuart,
                ),
              );

              return Transform.translate(
                offset: Offset(
                  0,
                  20 * (1 - slideAnimation.value),
                ),
                child: Opacity(
                  opacity: slideAnimation.value,
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                // Naviguer vers la page de description du produit
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(product: product),
                  ),
                );
              },
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween<double>(begin: 1, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: ProductCard(
                  product: product,
                  onFavoriteChanged: (productId, isFavorite) async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId == null) {
                      _showAnimatedSnackBar(
                        context,
                        'Veuillez vous connecter pour ajouter aux favoris',
                        isError: true,
                      );
                      return;
                    }

                    try {
                      if (isFavorite) {
                        await FirebaseService()
                            .addToFavorites(userId, productId);
                        _showAnimatedSnackBar(
                          context,
                          'Produit ajouté aux favoris',
                          isError: false,
                        );
                      } else {
                        await FirebaseService()
                            .removeFromFavorites(userId, productId);
                        _showAnimatedSnackBar(
                          context,
                          'Produit retiré des favoris',
                          isError: false,
                        );
                      }
                    } catch (e) {
                      _showAnimatedSnackBar(
                        context,
                        'Erreur lors de la mise à jour des favoris: $e',
                        isError: true,
                      );
                    }
                  },
                  onAddToCart: (productId) async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId == null) {
                      _showAnimatedSnackBar(
                        context,
                        'Veuillez vous connecter pour ajouter des articles au panier',
                        isError: true,
                      );
                      return;
                    }

                    final product =
                        products.firstWhere((p) => p.id == productId);

                    if (product.specifications.isNotEmpty || product.colors.isNotEmpty) {
                      await _showEnhancedSizeColorDialog(
                          context, product, userId);
                    } else {
                      try {
                        await FirebaseService().addToCart(userId, productId);
                        _showAnimatedSnackBar(
                          context,
                          '${product.name} ajouté au panier',
                          isError: false,
                        );
                      } catch (e) {
                        _showAnimatedSnackBar(
                          context,
                          'Erreur lors de l\'ajout au panier: $e',
                          isError: true,
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          );
        },
        childCount: productsToDisplay.length,
      ),
    );
  }

  void _showAnimatedSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Row(
                  children: [
                    Icon(
                      isError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(message)),
                  ],
                ),
              ),
            );
          },
        ),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showEnhancedSizeColorDialog(
      BuildContext context, Product product, String userId) async {
    String? selectedSize;
    String? selectedColor;

    await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuart,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Column(
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sélectionnez vos options',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (product.specifications.isNotEmpty) ...[
                        const Text(
                          'Taille',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.specifications.map((size) {
                            final isSelected = selectedSize == size;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedSize = size;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      if (product.colors.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Couleur',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.colors.map((color) {
                            final isSelected = selectedColor == color;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    color,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Annuler',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed:
                          ((product.specifications.isNotEmpty && selectedSize == null) ||
                                  (product.colors.isNotEmpty &&
                                      selectedColor == null))
                              ? null
                              : () async {
                                  try {
                                    await FirebaseService().addToCart(
                                      userId,
                                      product.id,
                                      size: selectedSize,
                                      color: selectedColor,
                                    );
                                    Navigator.pop(context);
                                    _showAnimatedSnackBar(
                                      context,
                                      '${product.name} ajouté au panier',
                                      isError: false,
                                    );
                                  } catch (e) {
                                    _showAnimatedSnackBar(
                                      context,
                                      'Erreur lors de l\'ajout au panier: $e',
                                      isError: true,
                                    );
                                  }
                                },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Ajouter au panier'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
    );
  }
}

// Custom painter for grid pattern (remains unchanged)
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 15.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
