import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'cart.dart';
import 'favorite.dart';
import 'profile.dart';
import 'user_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get _isUserLoggedIn => _auth.currentUser != null;

  Widget _getProfileScreen() {
  return StreamBuilder<User?>(
    stream: _auth.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasData) {
        return const ProfilePage();
      }
      return const LoginScreen();
    },
  );
}


  List<Widget> get _screens => [
        const HomeScreen(),
        const FavoriteScreen(),
        const CartScreen(),
        _getProfileScreen(),
      ];

  @override
  void initState() {
  super.initState();
  _auth.authStateChanges().listen((User? user) {
    if (mounted) {
      setState(() {
        if (user == null) {
          // Si l'utilisateur est déconnecté, aller à la page de login
          _selectedIndex = 3; // Index de la page profil/login
          _pageController.jumpToPage(3);
        }
      });
    }
  });
}

  void _onItemTapped(int index) {
  if (index == 3 && !_isUserLoggedIn) {
    // Rediriger vers l'écran de connexion
    _pageController.jumpToPage(3);
    return;
  }
  if (_selectedIndex != index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
