import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching products: $e');
      return [];
    }
  }
}