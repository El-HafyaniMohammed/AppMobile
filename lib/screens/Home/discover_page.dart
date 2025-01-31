import 'package:flutter/material.dart';
import '../Notification/notification_page.dart';
import '../../models/product.dart';
import '../../config/AppStyles.dart' as config;
import '../../widgets/product_card.dart';
import '../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProductDetailPage.dart';

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
                      const SizedBox(height: 16),
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
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - Brand name and location
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ShopEase',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.verified,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  ' Morroco',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ],
        ),
        
        // Right side - Action buttons
        Row(
          children: [
            // Cart button
            Stack(
              children: [
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Notification button
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationPage()),
                    );
                  },
                  icon: const Icon(Icons.notifications_outlined),
                  color: Colors.grey[700],
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
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
                      children: List.generate(5, (index) => 
                        Icon(
                          Icons.star, 
                          color: index < 4 ? Colors.amber : Colors.white24,
                          size: 16,
                        )
                      ),
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
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: categories[index] == selectedCategory 
                    ? AppColors.primary 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: categories[index] == selectedCategory 
                      ? Colors.transparent 
                      : AppColors.primary.withOpacity(0.3),
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
                        vertical: 8
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: categories[index] == selectedCategory 
                            ? Colors.white 
                            : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
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
          return GestureDetector(
            onTap: () {
              // Naviguer vers la page de description du produit
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
            child: ProductCard(
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

  final product = products.firstWhere((p) => p.id == productId);

  // Vérifier si le produit a des tailles ou des couleurs
  if (product.sizes.isNotEmpty || product.colors.isNotEmpty) {
    // Afficher une boîte de dialogue pour sélectionner la taille ou la couleur
    await _showSizeColorDialog(context, product, userId);
  } else {
    // Ajouter directement au panier si aucune taille ou couleur n'est nécessaire
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
  }
},
            ),
          );
        },
        childCount: productsToDisplay.length,
      ),
    );
  }
  Future<void> _showSizeColorDialog(BuildContext context, Product product, String userId) async {
    String? selectedSize;
    String? selectedColor;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sélectionnez les options pour ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.sizes.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedSize,
                  hint: const Text('Sélectionnez une taille'),
                  items: product.sizes.map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text(size),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedSize = value;
                  },
                ),
              if (product.colors.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedColor,
                  hint: const Text('Sélectionnez une couleur'),
                  items: product.colors.map((color) {
                    return DropdownMenuItem(
                      value: color,
                      child: Text(color),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedColor = value;
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if ((product.sizes.isNotEmpty && selectedSize == null) ||
                    (product.colors.isNotEmpty && selectedColor == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner une taille et/ou une couleur'),
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseService().addToCart(
                    userId,
                    product.id,
                    size: selectedSize,
                    color: selectedColor,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} ajouté au panier'),
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de l\'ajout au panier: $e'),
                    ),
                  );
                }
              },
              child: const Text('Ajouter au panier'),
            ),
          ],
        );
      },
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