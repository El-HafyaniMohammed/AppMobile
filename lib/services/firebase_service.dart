import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromMap(
            data); // Assurez-vous que `fromMap` gère les nulls
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching products: $e');
      return []; // Retourne une liste vide en cas d'erreur
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  Future<List<Product>> getFavoriteProducts() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('isFavorite', isEqualTo: true)
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la récupération des produits favoris: $e');
      return [];
    }
  }

  Future<void> updateProductFavoriteStatus(
      String productId, bool isFavorite) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isFavorite': isFavorite,
      });
      // ignore: avoid_print
      print('Statut favori mis à jour pour le produit $productId: $isFavorite');
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la mise à jour du statut favori: $e');
    }
  }

  // Récupérer les informations d'un produit par son ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du produit: $e');
      return null;
    }
  }

   // Ajouter un produit au panier
  Future<void> addToCart(String userId, String productId) async {
    final productData = await getProductById(productId);

    if (productData != null) {
      final cartItem = CartItem(
        productId: productId,
        name: productData['name'] ?? '',
        image: productData['imagePath'] ?? '',
        price: productData['price']?.toDouble() ?? 0.0,
        isOnSale: productData['isOnSale'] as bool? ?? false,
        quantity: 1, // Quantité par défaut
        selectedColor: 'Black', // Couleur par défaut
      );

      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(productId)
            .set(cartItem.toMap());
      } catch (e) {
        print('Erreur lors de l\'ajout au panier: $e');
      }
    } else {
      print('Produit non trouvé');
    }
  }

  // Récupérer les articles du panier
  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      return cartSnapshot.docs.map((doc) {
        final data = doc.data();
        // ignore: unnecessary_null_comparison
        if (data == null) throw Exception('Données du panier non valides');
        return CartItem.fromMap(
            data); // Assurez-vous que CartItem a une méthode fromMap
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération du panier: $e');
      rethrow;
    }
  }

  // Supprimer un produit du panier
  Future<void> removeFromCart(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    } catch (e) {
      print('Erreur lors de la suppression du panier: $e');
      rethrow;
    }
  }

  // Vider le panier
  Future<void> clearCart(String userId) async {
    try {
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      for (final doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Erreur lors de la suppression du panier: $e');
      rethrow;
    }
  }

  Future<void> createCartForUser(String userId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Vérifier si l'utilisateur a déjà un panier
    final cartSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    // Si l'utilisateur n'a pas de panier, en créer un vide
    if (cartSnapshot.docs.isEmpty) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc('initial')
          .set({
        'createdAt': DateTime.now(), // Optionnel : date de création du panier
      });
    }
  }
}
