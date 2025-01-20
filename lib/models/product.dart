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
  });
  factory Product.fromMap(Map<String, dynamic> map) {
  return Product(
    id: map['id'] ?? 'Unknown ID', // Valeur par défaut
    name: map['name'] ?? 'Unknown Product', // Valeur par défaut
    brand: map['brand'] ?? 'Unknown Brand', // Valeur par défaut
    price: (map['price'] as num?)?.toDouble() ?? 0.0, // Valeur par défaut
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0, // Valeur par défaut
    imagePath: map['imagePath'] ?? 'assets/img/default.jpg', // Valeur par défaut
    isOnSale: map['isOnSale'] as bool? ?? true, // Valeur par défaut
    salePrice: (map['salePrice'] as num?)?.toDouble(), // Nullable
    isFavorite: map['isFavorite'] as bool? ?? false, //value par défaut
    category: map['category'] as String,
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
    };
  }
}