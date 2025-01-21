class CartItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final bool isOnSale;
  final double? salePrice;
  int quantity;
  String selectedColor;

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    this.isOnSale = false,
    this.salePrice,
    this.quantity = 1,
    this.selectedColor = 'Black',
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'isOnSale': isOnSale,
      'salePrice': salePrice,
      'quantity': quantity,
      'selectedColor': selectedColor,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      isOnSale: data['isOnSale'] as bool? ?? false,
      salePrice: (data['salePrice'] as num?)?.toDouble(),
      quantity: data['quantity'] as int? ?? 1,
      selectedColor: data['selectedColor'] as String? ?? 'Black',
    );
  }
}