import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/Address_User.dart';

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
      final productDoc =
          await _firestore.collection('products').doc(productId).get();

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

      final favoriteProductIds =
          favoritesSnapshot.docs.map((doc) => doc.id).toList();

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
  Future<void> addToCart(String userId, String productId,
      {int quantity = 1, String? size, String? color}) async {
    try {
      final cartDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .get();

      if (cartDoc.exists) {
        // Si le produit existe déjà dans le panier, mettre à jour la quantité
        final currentQuantity = cartDoc.data()?['quantity'] ?? 0;
        await cartDoc.reference.update({
          'quantity': currentQuantity + quantity,
        });
      } else {
        // Si le produit n'existe pas encore dans le panier, créer un nouveau document
        final cartData = {
          'productId': productId,
          'quantity': quantity,
          if (size != null)
            'size': size, // Ajouter la taille si elle est fournie
          if (color != null)
            'color': color, // Ajouter la couleur si elle est fournie
        };

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(productId)
            .set(cartData);
      }
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
      rethrow; // Propager l'erreur pour la gérer dans l'interface utilisateur
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
              selectedColor: cartData['color'] as String? ?? 'Black',
              selectedSize: cartData['size'] as String? ??
                  '', // Charger la taille sélectionnée
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

/// Fetch all addresses for the current user
  Future<List<AddressUser>> fetchAddresses(String userId) async {
    try {
      final addressesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();

      return addressesSnapshot.docs.map((doc) {
        return AddressUser.fromMap({
          'addressId': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error fetching addresses: $e');
      throw Exception('Failed to fetch addresses');
    }
  }

  /// Add a new address for the current user
  Future<String?> addAddress({
    required AddressUser address,
    required String userId,
  }) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add(address.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding address: $e');
      throw Exception('Failed to add address');
    }
  }

  /// Update an existing address for the current user
  Future<void> updateAddress({
    required AddressUser address,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(address.addressId)
          .update(address.toMap());
    } catch (e) {
      print('Error updating address: $e');
      throw Exception('Failed to update address');
    }
  }

  /// Delete an address for the current user
  Future<void> deleteAddress({
    required String addressId,
    required String userId,
  }) async {
    try {
      print('Deleting address: $addressId for user: $userId');

      // Rechercher le document qui correspond à l'addressId
      final addressesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .where('addressId', isEqualTo: addressId)
          .get();

      if (addressesSnapshot.docs.isEmpty) {
        throw Exception('Address not found');
      }

      final addressDoc = addressesSnapshot.docs.first;

      // Supprimer le document trouvé
      await addressDoc.reference.delete();

      print('Address deleted successfully');
    } catch (e) {
      print('Error deleting address: $e');
      throw Exception('Failed to delete address');
    }
  }

  /// Set an address as default for the current user
  Future<void> setDefaultAddress({
    required String addressId,
    required String userId,
  }) async {
    try {
      print('Setting default address: $addressId for user: $userId');

      // Rechercher le document qui correspond à l'addressId
      final addressesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .where('addressId', isEqualTo: addressId)
          .get();

      if (addressesSnapshot.docs.isEmpty) {
        throw Exception('Address not found');
      }

      final addressDoc = addressesSnapshot.docs.first;

      await _firestore.runTransaction((transaction) async {
        // Reset all addresses to not default
        final allAddressesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .get();

        print('Found ${allAddressesSnapshot.docs.length} addresses');

        for (final doc in allAddressesSnapshot.docs) {
          print('Resetting address: ${doc.id} to not default');
          transaction.update(doc.reference, {'isDefault': false});
        }

        // Set the selected address as default
        print('Setting address: $addressId as default');
        transaction.update(addressDoc.reference, {'isDefault': true});
      });

      print('Default address set successfully');
    } catch (e) {
      print('Error setting default address: $e');
      throw Exception('Failed to set default address');
    }
  }
  
}
