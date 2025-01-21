class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double rating;
  final String imagePath;
  final bool isOnSale;
  final double? salePrice;
  bool isFavorite;
  final String category;
  int quantity; // Ajout de la quantité

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.imagePath,
    this.isOnSale = false,
    this.salePrice,
    this.isFavorite = false,
    required this.category,
    this.quantity = 1, // Initialisation de la quantité à 1
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? 'Unknown ID',
      name: map['name'] ?? 'Unknown Product',
      brand: map['brand'] ?? 'Unknown Brand',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['imagePath'] ?? 'assets/img/default.jpg',
      isOnSale: map['isOnSale'] as bool? ?? true,
      salePrice: (map['salePrice'] as num?)?.toDouble(),
      isFavorite: map['isFavorite'] as bool? ?? false,
      category: map['category'] as String,
      quantity: map['quantity'] as int? ?? 1, // Charger la quantité depuis Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'rating': rating,
      'imagePath': imagePath,
      'isOnSale': isOnSale,
      'salePrice': salePrice,
      'isFavorite': isFavorite,
      'quantity': quantity, // Sauvegarder la quantité dans Firestore
    };
  }
}