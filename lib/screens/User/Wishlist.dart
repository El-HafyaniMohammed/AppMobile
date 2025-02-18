// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste de Souhaits'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWishlistItem(
            imageUrl: 'https://example.com/product1.jpg',
            name: 'Smartphone Pro X',
            price: 3999.00,
            originalPrice: 4499.00,
          ),
          const SizedBox(height: 16),
          _buildWishlistItem(
            imageUrl: 'https://example.com/product2.jpg',
            name: 'Écouteurs Bluetooth',
            price: 799.50,
            originalPrice: 999.00,
          ),
          const SizedBox(height: 16),
          _buildWishlistItem(
            imageUrl: 'https://example.com/product3.jpg',
            name: 'Montre Connectée',
            price: 1299.99,
            originalPrice: 1599.99,
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem({
    required String imageUrl,
    required String name,
    required double price,
    required double originalPrice,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${price.toStringAsFixed(2)} MAD',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${originalPrice.toStringAsFixed(2)} MAD',
                      style: TextStyle(
                        color: Colors.grey[600],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}