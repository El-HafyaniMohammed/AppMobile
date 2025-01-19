class CartItem {
  final String name;
  final String image;
  final double price;
  int quantity;
  String selectedColor;

  CartItem({
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
    this.selectedColor = 'Black',
  });
}
