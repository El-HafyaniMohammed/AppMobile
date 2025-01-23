class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double rating;
  final String imagePath;
  final bool isOnSale;
  final double? salePrice;
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
    required this.category,
    this.quantity = 1, // Initialisation de la quantité à 1
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ,
      name: map['name'] ,
      brand: map['brand'] ,
      price: (map['price'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble() ,
      imagePath: map['imagePath'],
      isOnSale: map['isOnSale'] ,
      salePrice: (map['salePrice'] as num?)?.toDouble(),
      category: map['category'] as String,
      quantity: map['quantity'] as int, // Charger la quantité depuis Firestore
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
      'quantity': quantity, // Sauvegarder la quantité dans Firestore
    };
  }
}