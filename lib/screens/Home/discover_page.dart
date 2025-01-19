import 'package:flutter/material.dart';
import '../Notification/notification_page.dart';
import '../../models/product.dart';
import '../../config/AppStyles.dart' as config;
import '../../widgets/product_card.dart';

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

  final List<String> categories = [
    'All',
    'Smartphones',
    'Headphones',
    'Laptops',
    'Smart Watches',
    'Tablets',
    'Speakers',
  ];

  final List<Product> products = [
    Product(
      id: '1',
      name: 'AirPods',
      brand: 'Apple',
      price: 132.00,
      rating: 4.8,
      imagePath: 'assets/img/product_4.png',
      isOnSale: true,
      salePrice: 119.99,
    ),
    Product(
      id: '2',
      name: 'MacBook Air M1',
      brand: 'Apple',
      price: 1100.00,
      rating: 4.9,
      imagePath: 'assets/img/product_5.png',
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
    Product(
      id: '4',
      name: 'iPad Pro',
      brand: 'Apple',
      price: 799.00,
      rating: 4.9,
      imagePath: 'assets/img/product_7.png',
    ),
    Product(
      id: '5',
      name: 'Xbox Series X',
      brand: 'Microsoft',
      price: 3990.00,
      rating: 4.5,
      imagePath: 'assets/img/product_8.png',
    ),
  ];

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  // Fonction pour filtrer les produits en fonction de la recherche
  List<Product> _filterProducts() {
    if (searchQuery.isEmpty) {
      return products;
    } else {
      return products.where((product) {
        return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.brand.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filterProducts();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
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
          return ProductCard(product: product);
        },
        childCount: productsToDisplay.length,
      ),
    );
  }
}
