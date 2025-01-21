import 'package:flutter/material.dart';
import '../screens/Notification/Notification_Page.dart';
import '../services/firebase_service.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../config/AppStyles.dart' as config;

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(String productId, bool isFavorite) onFavoriteChanged;
  final Function(String productId)
      onAddToCart; // Nouvelle fonction pour ajouter au panier

  const ProductCard({
    super.key,
    required this.product,
    required this.onFavoriteChanged,
    required this.onAddToCart, // Ajout du paramètre
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // Fonction pour construire les étoiles du rating
  Widget _buildRatingStars(double rating) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return const Icon(Icons.star, size: 16, color: Colors.amber);
            } else if (index == rating.floor() && rating % 1 != 0) {
              return const Icon(Icons.star_half, size: 16, color: Colors.amber);
            }
            return const Icon(Icons.star_border, size: 16, color: Colors.amber);
          }),
        ),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Hero(
                      tag: 'product-${widget.product.id}',
                      child: Image.asset(
                        widget.product.imagePath,
                        height: 120,
                      ),
                    ),
                  ),
                ),
                if (widget.product.isOnSale)
                  Positioned(
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
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      widget.product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          widget.product.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () async {
                      final newFavoriteStatus = !widget.product.isFavorite;
                      await widget.onFavoriteChanged(
                          widget.product.id, newFavoriteStatus);
                      setState(() {
                        widget.product.isFavorite = newFavoriteStatus;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: config.AppStyles.productTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.product.brand,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                _buildRatingStars(widget.product.rating),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.product.isOnSale) ...[
                      Text(
                        '${widget.product.salePrice?.toStringAsFixed(2)} Dh',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.product.price.toStringAsFixed(2)} Dh',
                        style: const TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ] else
                      Text(
                        '${widget.product.price.toStringAsFixed(2)} Dh',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                  onPressed: () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Veuillez vous connecter pour ajouter des articles au panier')),
                      );
                      return;
                    }

                    try {
                      await FirebaseService()
                          .addToCart(userId, widget.product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${widget.product.name} ajouté au panier')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Erreur lors de l\'ajout au panier: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
