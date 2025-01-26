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
  int quantity;
  final String description;
  double deliveryTime;
  final List<String> colors; // Tableau de couleurs disponibles
  final List<String> sizes;
  final Map<String, double> sizePrices; // Map of sizes to their prices
  final Map<String, double> colorPrices; // Map of colors to their prices // Tableau de tailles disponibles

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
    this.quantity = 1,
    required this.description,
    required this.deliveryTime,
    this.colors = const [], // Initialisation par défaut d'un tableau vide
    this.sizes = const [], // Initialisation par défaut d'un tableau vide
    this.sizePrices = const {}, // Initialisation par défaut d'une map vide
    this.colorPrices = const {}, // Initialisation par défaut d'une map vide
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      price: (map['price'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
      imagePath: map['imagePath'],
      isOnSale: map['isOnSale'],
      salePrice: (map['salePrice'] as num?)?.toDouble(),
      category: map['category'],
      quantity: map['quantity'],
      description: map['description'],
      deliveryTime: (map['deliveryTime'] as num).toDouble(),
      colors: List<String>.from(map['colors'] ?? []), // Charger les couleurs depuis Firestore
      sizes: List<String>.from(map['sizes'] ?? []), // Charger les tailles depuis Firestore
      sizePrices: Map<String, double>.from(map['sizePrices'] ?? {}), // Charger les prix des tailles depuis Firestore
      colorPrices: Map<String, double>.from(map['colorPrices'] ?? {}), // Charger les prix des couleurs depuis Firestore
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
      'category': category,
      'quantity': quantity,
      'description': description,
      'deliveryTime': deliveryTime,
      'colors': colors, // Sérialiser les couleurs
      'sizes': sizes, // Sérialiser les tailles
      'sizePrices': sizePrices, // Sérialiser les prix des tailles
      'colorPrices': colorPrices, // Sérialiser les prix des couleurs
    };
  }
  get displayPrice {
    return isOnSale ? (salePrice ?? price) : price;
  }
  Product copyWith({
    String? selectedSize,
    String? selectedColor,
  }){
    return Product(
      id: id,
      name: name,
      brand: brand,
      price: price,
      rating: rating,
      imagePath: imagePath,
      isOnSale: isOnSale,
      salePrice: salePrice,
      category: category,
      quantity: quantity,
      description: description,
      deliveryTime: deliveryTime,
      colors: colors,
      sizes: sizes,
      sizePrices: sizePrices,
      colorPrices: colorPrices,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'price': price,
    'rating': rating,
    'imagePath': imagePath,
    'isOnSale': isOnSale,
    'salePrice': salePrice,
    'category': category,
    'quantity': quantity,
    'description': description,
    'deliveryTime': deliveryTime,
    'colors': colors,
    'sizes': sizes,
    'sizePrices': sizePrices,
    'colorPrices': colorPrices,
  };
   factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    brand: json['brand'],
    price: json['price'],
    rating: json['rating'],
    imagePath: json['imagePath'],
    isOnSale: json['isOnSale'],
    salePrice: json['salePrice'],
    category: json['category'],
    quantity: json['quantity'],
    description: json['description'],
    deliveryTime: json['deliveryTime'],
    colors: json['colors'],
    sizes: json['sizes'],
    sizePrices: json['sizePrices'],
    colorPrices: json['colorPrices'],
   );
}