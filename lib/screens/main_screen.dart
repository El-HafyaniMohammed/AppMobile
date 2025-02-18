// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
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
  late final List<AnimationController> _waveControllers;
  late final List<AnimationController> _bubbleControllers;
  late final AnimationController _selectedAnimController;
  
  // Couleurs personnalisées pour un thème vert
  final Color _lightGreen = const Color(0xFF8BC34A);
  final Color _mediumGreen = const Color(0xFF4CAF50);
  final Color _darkGreen = const Color(0xFF2E7D32);
  
  final List<Color> _bubbleColors = [
    Colors.white.withOpacity(0.3),
    Colors.white.withOpacity(0.2),
    Colors.white.withOpacity(0.4),
    Colors.white.withOpacity(0.1),
    Colors.white.withOpacity(0.25),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    _waveControllers = List.generate(
      2,
      (index) => AnimationController(
        duration: Duration(milliseconds: 2000 + (index * 500)),
        vsync: this,
      )..repeat(),
    );

    _bubbleControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + (index * 300)),
        vsync: this,
      )..repeat(),
    );

    _selectedAnimController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _waveControllers) {
      controller.dispose();
    }
    for (var controller in _bubbleControllers) {
      controller.dispose();
    }
    _selectedAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const PageScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          const HomeScreen(),
          const FavoriteScreen(),
          const CartScreen(),
          _auth.currentUser != null
              ? ProfilePage(user: widget.user)
              : const LoginScreen(),
        ],
      ),
      bottomNavigationBar: _buildPoolNavBar(),
    );
  }

  Widget _buildPoolNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lightGreen,
            _mediumGreen,
            _darkGreen,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: _mediumGreen.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          ...List.generate(2, (index) => _buildWave(index)),
          ...List.generate(5, (index) => _buildBubble(index)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) => _buildSwimmingIcon(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildWave(int index) {
    return AnimatedBuilder(
      animation: _waveControllers[index],
      builder: (context, child) {
        return Positioned(
          top: 20.0 + (index * 20),
          left: -20 + (50 * _waveControllers[index].value),
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width + 40, 30),
            painter: WavePainter(
              animation: _waveControllers[index].value,
              waveColor: _lightGreen.withOpacity(0.1 - (index * 0.03)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBubble(int index) {
    return AnimatedBuilder(
      animation: _bubbleControllers[index],
      builder: (context, child) {
        final random = math.Random(index);
        final startX = random.nextDouble() * MediaQuery.of(context).size.width;
        final endY = -50.0 - (random.nextDouble() * 50);
        final size = 8.0 + (random.nextDouble() * 8);
        
        return Positioned(
          left: startX + (math.sin(_bubbleControllers[index].value * math.pi * 2) * 10),
          bottom: endY + (150 * _bubbleControllers[index].value),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _bubbleColors[index],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwimmingIcon(int index) {
    final isSelected = index == _selectedIndex;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedBuilder(
        animation: _selectedAnimController,
        builder: (context, child) {
          double yOffset = isSelected
              ? math.sin(_selectedAnimController.value * math.pi * 2) * 10
              : 0;
          double xOffset = isSelected
              ? math.cos(_selectedAnimController.value * math.pi) * 5
              : 0;
          
          return Transform.translate(
            offset: Offset(xOffset, yOffset),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _getIcon(index, isSelected),
                color: Colors.white,
                size: isSelected ? 30 : 26,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onItemTapped(int index) async {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuad,
    );
  }

  IconData _getIcon(int index, bool isActive) {
    switch (index) {
      case 0:
        return isActive ? Icons.home_rounded : Icons.home_outlined;
      case 1:
        return isActive ? Icons.favorite_rounded : Icons.favorite_outline_rounded;
      case 2:
        return isActive ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined;
      case 3:
        return isActive ? Icons.person_rounded : Icons.person_outline_rounded;
      default:
        return Icons.home_outlined;
    }
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color waveColor;

  WavePainter({required this.animation, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final y = size.height / 2;
    
    path.moveTo(0, y);
    
    for (var i = 0.0; i < size.width; i++) {
      path.lineTo(
        i,
        y + math.sin((i / 30) + (animation * math.pi * 2)) * 8,
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}