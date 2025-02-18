// ignore_for_file: avoid_types_as_parameter_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/cart_item.dart';
import 'CheckoutPage.dart';
import '../../services/firebase_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<CartItem> cartItems = []; // Liste des articles du panier
  double deliveryFee = 50.0;
  double discountPercentage = 10;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();
  String? userId; // ID de l'utilisateur
  bool isLoading = false; // Indicateur de chargement

  double get subtotal =>
    cartItems.fold(0, (sum, item) => sum + (item.displayPrice * item.quantity));
  double get discount => subtotal * (discountPercentage / 100);
  double get total => subtotal + deliveryFee - discount;

  @override
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _loadCartItems(); // Charger les articles du panier
    } else {
      // Gérer le cas où l'utilisateur n'est pas connecté
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vous devez être connecté pour voir votre panier.")),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Charger les articles du panier depuis Firebase
  Future<void> _loadCartItems() async {
    if (userId == null) return;

    setState(() {
      isLoading = true;
    });
    try {
      final items = await _firebaseService.getCartItems(userId!); // Utiliser le ! ici car userId est vérifié
      setState(() {
        cartItems = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement du panier: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  // Mettre à jour la quantité d'un article dans Firebase
  void updateQuantity(int index, bool increase) async {
    final cartItem = cartItems[index];
    final newQuantity = increase ? cartItem.quantity + 1 : cartItem.quantity - 1;

    if (newQuantity < 1 || newQuantity > 99) return;

    setState(() {
      isLoading = true;
    });
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItem.product.id)
          .update({'quantity': newQuantity});
      setState(() {
        cartItems[index].quantity = newQuantity;
      });
      _controller.forward(from: 0);
    } catch (e) {
      // ignore: use_build_context_synchronously
      
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Supprimer un article du panier dans Firebase
  void removeItem(int index) async {
    final cartItem = cartItems[index];
    setState(() {
      isLoading = true;
    });
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItem.product.id)
          .delete();
      setState(() {
        cartItems.removeAt(index);
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de l\'article: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Vider le panier dans Firebase
  void clearCart() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              try {
                final cartSnapshot = await _firestore
                    .collection('users')
                    .doc(userId)
                    .collection('cart')
                    .get();
                for (final doc in cartSnapshot.docs) {
                  await doc.reference.delete();
                }
                setState(() {
                  cartItems.clear();
                });
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur lors de la suppression du panier: $e')),
                );
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _updateItemSize(int index, String newSize) async {
    final cartItem = cartItems[index];
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItem.product.id)
          .update({'size': newSize});
      
      setState(() {
        cartItems[index].selectedSize = newSize;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating size: $e')),
      );
    }
  }

  void _updateItemColor(int index, String newColor) async {
    final cartItem = cartItems[index];
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItem.product.id)
          .update({'color': newColor});
      
      setState(() {
        cartItems[index].selectedColor = newColor;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating color: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shopping_cart_outlined, 
                color: Colors.grey[800], 
                size: 24
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Shopping Cart',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          if (cartItems.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline, 
                  color: Colors.red.shade600
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  clearCart();
                },
                tooltip: 'Clear cart',
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        child: Lottie.asset(
                          'assets/animation/empty_cart.json',
                          repeat: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    item.product.imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image_not_supported);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 20),
                                            onPressed: () => removeItem(index),
                                            padding: EdgeInsets.zero,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if(item.product.specifications.isNotEmpty) 
                                        DropdownButton<String>(
                                          value: item.selectedSize,
                                          items: item.product.specifications.map((size) => 
                                            DropdownMenuItem(
                                              value: size,
                                              child: Text(size)
                                            )
                                          ).toList(),
                                          onChanged: (newSize) {
                                            if (newSize != null) {
                                              _updateItemSize(index, newSize);
                                            }
                                          },
                                        ),

                                      if(item.product.colors.isNotEmpty) 
                                        DropdownButton<String>(
                                          value: item.selectedColor,
                                          items: item.product.colors.map((color) => 
                                            DropdownMenuItem(
                                              value: color,
                                              child: Text(color)
                                            )
                                          ).toList(),
                                          onChanged: (newColor) {
                                            if (newColor != null) {
                                              _updateItemColor(index, newColor);
                                            }
                                          },
                                        ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${item.displayPrice.toStringAsFixed(2)} Dh',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                _QuantityButton(
                                                  icon: Icons.remove,
                                                  onPressed: () => updateQuantity(index, false),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  child: Text(
                                                    item.quantity.toString(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                _QuantityButton(
                                                  icon: Icons.add,
                                                  onPressed: () => updateQuantity(index, true),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    _buildCheckoutSection(),
                  ],
                ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(2)} Dh',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Subtotal', subtotal),
                      _buildSummaryRow('Delivery Fee', deliveryFee),
                      _buildSummaryRow(
                        'Discount',
                        -discount,
                        detailText: '$discountPercentage% OFF',
                        detailStyle: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Promo Code',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${total.toStringAsFixed(2)} Dh',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(cartItems: cartItems, userId: userId ?? ''), // Passer les articles du panier
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {String? detailText, TextStyle? detailStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              if (detailText != null) ...[
                Text(detailText, style: detailStyle),
                const SizedBox(width: 8),
              ],
              Text(
                '${amount.abs().toStringAsFixed(2)} Dh',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    // ignore: unused_element
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.grey[700] : Colors.grey[400],
        ),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}