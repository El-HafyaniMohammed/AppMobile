import 'package:project/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String selectedColor;
  String selectedSize; // Taille sélectionnée

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedColor = 'Black', 
    required this.selectedSize // Couleur par défaut
  });

  // Convertir l'objet en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      "productId": product.id,
      'quantity': quantity,
      'selectedColor': selectedColor, 
      'selectedSize': selectedSize // Ajouter la taille sélectionnée
    };
  }

  // Créer un objet CartItem à partir d'une Map (depuis Firestore)
  factory CartItem.fromMap(Map<String, dynamic> data, Product product) {
    return CartItem(
      product: product,
      quantity: data['quantity'] as int? ?? 1,
      selectedColor: data['selectedColor'] as String? ?? 'Black', 
      selectedSize: data['selectedSize'] as String? ?? '' // Charger la taille sélectionnée
    );
  }

  // Mettre à jour la couleur sélectionnée
  void updateSelectedColor(String newColor) {
    selectedColor = newColor;
  }

  // Calculer le prix affiché (en tenant compte des promotions)
  double get displayPrice {
    return product.isOnSale ? (product.salePrice ?? product.price) : product.price;
  }
}