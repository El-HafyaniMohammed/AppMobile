import 'package:project/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedColor = 'Black',
  });

  Map<String, dynamic> toMap() {
    return {
      "productId": product.id,
      'quantity': quantity,
      'selectedColor': selectedColor,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      product: Product.fromMap(data),
      quantity: data['quantity'] as int? ?? 1,
      selectedColor: data['selectedColor'] as String? ?? 'Black',
    );
  }

  get displayPrice {
    return product.isOnSale ? product.salePrice : product.price;
  }
}