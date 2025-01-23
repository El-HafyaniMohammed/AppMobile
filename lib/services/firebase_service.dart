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

  // Ajouter un produit au favorite
  Future<void> addToFavorites(String userId, String productId) async {
    try {
      // Récupérer les informations du produit à partir de la collection 'products'
      final productDoc = await _firestore.collection('products').doc(productId).get();

      if (productDoc.exists) {
        final productData = productDoc.data(); // Récupérer les données du produit

        // Ajouter le produit avec toutes ses informations dans la collection 'favorites'
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(productId)
            .set({
          ...productData!, // Spread operator pour inclure toutes les données du produit
          'addedAt': DateTime.now(), // Ajouter un timestamp pour la date d'ajout
        });
      } else {
        // ignore: avoid_print
        print('Produit non trouvé');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de l\'ajout aux favoris: $e');
      rethrow;
    }
  }
  // Supprimer un remove du favorite
  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la suppression des favoris: $e');
      rethrow;
    }
  }

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

      final favoriteProductIds =
          favoritesSnapshot.docs.map((doc) => doc.id).toList();

      final productsSnapshot = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: favoriteProductIds)
          .get();

      return productsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits favoris: $e');
      return [];
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
            .doc(productId) // Utilisez l'ID du produit comme ID du document
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

      return cartSnapshot.docs
          .where((doc) => doc.id != 'initial') // Filtre les documents avec l'ID 'initial'
          .map((doc) {
            final data = doc.data();
            // ignore: unnecessary_null_comparison
            if (data == null) throw Exception('Données du panier non valides');
            return CartItem.fromMap(data);
          })
          .toList();
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

  Future<void> cleanInitialCartDocuments(String userId) async {
    try {
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      for (final doc in cartSnapshot.docs) {
        if (doc.id == 'initial') {
          await doc.reference.delete(); // Supprime le document 'initial'
        }
      }
    } catch (e) {
      print('Erreur lors du nettoyage des documents "initial": $e');
    }
  }
}
