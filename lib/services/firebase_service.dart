import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer tous les produits
  Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        // ignore: unnecessary_null_comparison
        if (data != null) {
          return Product.fromMap(data);
        } else {
          throw Exception('Product data is null');
        }
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }

  // Récupérer les catégories
  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      return querySnapshot.docs.map((doc) {
        final name = doc['name'] as String?;
        return name ?? 'Unnamed Category';
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  // Ajouter un produit aux favoris
  Future<void> addToFavorites(String userId, String productId) async {
    try {
      final productDoc = await _firestore.collection('products').doc(productId).get();

      if (productDoc.exists) {
        final productData = productDoc.data();
        if (productData != null) {
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorites')
              .doc(productId)
              .set({
            ...productData,
            'addedAt': DateTime.now(),
          });
        } else {
          print('Product data is null');
        }
      } else {
        print('Produit non trouvé');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
      rethrow;
    }
  }

  // Supprimer un produit des favoris
  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();
    } catch (e) {
      print('Erreur lors de la suppression des favoris: $e');
      rethrow;
    }
  }

  // Vérifier si un produit est dans les favoris
  Future<bool> isProductInFavorites(String userId, String productId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }

  // Récupérer les produits favoris
  Future<List<Product>> getFavoriteProducts(String userId) async {
    try {
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      final favoriteProductIds = favoritesSnapshot.docs.map((doc) => doc.id).toList();

      if (favoriteProductIds.isNotEmpty) {
        final productsSnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: favoriteProductIds)
            .get();

        return productsSnapshot.docs.map((doc) {
          final data = doc.data();
          // ignore: unnecessary_null_comparison
          if (data != null) {
            return Product.fromMap(data);
          } else {
            throw Exception('Product data is null');
          }
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des produits favoris: $e');
      return [];
    }
  }

  // Récupérer les informations d'un produit par son ID
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return Product.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du produit: $e');
      return null;
    }
  }

  // Ajouter un produit au panier
  Future<void> addToCart(String userId, String productId) async {
    try {
      final cartDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .get();

      if (cartDoc.exists) {
        final currentQuantity = cartDoc.data()?['quantity'] ?? 0;
        await cartDoc.reference.update({
          'quantity': currentQuantity + 1,
        });
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(productId)
            .set({
          'productId': productId,
          'quantity': 1,
          'selectedColor': 'Black',
        });
      }
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
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

      final cartItems = <CartItem>[];

      for (final doc in cartSnapshot.docs) {
        final cartData = doc.data();
        final productId = cartData['productId'] as String?;

        if (productId != null) {
          final product = await getProductById(productId);

          if (product != null) {
            final cartItem = CartItem(
              product: product,
              quantity: cartData['quantity'] as int? ?? 1,
              selectedColor: cartData['selectedColor'] as String? ?? 'Black',
            );
            cartItems.add(cartItem);
          }
        }
      }

      return cartItems;
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
}