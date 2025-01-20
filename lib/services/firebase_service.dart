import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromMap(data); // Assurez-vous que `fromMap` gère les nulls
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching products: $e');
      return []; // Retourne une liste vide en cas d'erreur
    }
  }
  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('categories').get();
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

  Future<void> updateProductFavoriteStatus(String productId, bool isFavorite) async {
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
}