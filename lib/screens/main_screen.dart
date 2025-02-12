import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './Home/home.dart';
import 'Cart/cart.dart';
import 'Favorite/favorite.dart';
import 'User/Login_and_Signin.dart';
import 'User/ProfilePage.dart';
import '../models/user_model.dart';

class MainScreen extends StatefulWidget {
  final UserModel user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final PageController _pageController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  
  // Controllers pour les animations des icônes
  late final List<AnimationController> _iconControllers;
  late final List<Animation<double>> _iconScaleAnimations;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Configuration de l'animation de fondu
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Configuration de l'animation d'échelle
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Initialisation des animations des icônes
    _iconControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    
    _iconScaleAnimations = _iconControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
    
    _fadeController.forward();
    _scaleController.forward();
  }

  Future<void> _onItemTapped(int index) async {
    if (index == _selectedIndex) {
      // Animation de rebond si on tape sur l'icône déjà sélectionnée
      _iconControllers[index].forward().then((_) => _iconControllers[index].reverse());
      return;
    }

    if (index == 3 && _auth.currentUser == null) {
      setState(() => _selectedIndex = index);
      await _animateToPage(index);
      return;
    }

    // Démarrer les animations de transition
    await Future.wait([
      _fadeController.reverse(),
      _scaleController.reverse(),
    ]);

    setState(() => _selectedIndex = index);
    
    // Animer vers la nouvelle page
    await _animateToPage(index);
    
    // Animations de l'icône sélectionnée
    _iconControllers[index].forward().then((_) => _iconControllers[index].reverse());
    
    // Redémarrer les animations
    Future.wait([
      _fadeController.forward(),
      _scaleController.forward(),
    ]);
  }

  Future<void> _animateToPage(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const HomeScreen(),
                  const FavoriteScreen(),
                  const CartScreen(),
                  _auth.currentUser != null
                      ? ProfilePage(user: widget.user)
                      : const LoginScreen(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: List.generate(4, (index) {
            return BottomNavigationBarItem(
              icon: ScaleTransition(
                scale: _iconScaleAnimations[index],
                child: _buildIcon(index, false),
              ),
              activeIcon: ScaleTransition(
                scale: _iconScaleAnimations[index],
                child: _buildIcon(index, true),
              ),
              label: _getLabel(index),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildIcon(int index, bool isActive) {
    final IconData iconData = _getIcon(index, isActive);
    return Icon(
      iconData,
      size: isActive ? 28 : 24,
    );
  }

  IconData _getIcon(int index, bool isActive) {
    switch (index) {
      case 0:
        return isActive ? Icons.home : Icons.home_outlined;
      case 1:
        return isActive ? Icons.favorite : Icons.favorite_outline;
      case 2:
        return isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined;
      case 3:
        return isActive ? Icons.person : Icons.person_outline;
      default:
        return Icons.home_outlined;
    }
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Favorites';
      case 2:
        return 'Cart';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }
}