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
  final double deliveryTime;
  final List<String> colors;
  final List<String> sizes;
  final Map<String, double> sizePrices;
  final Map<String, double> colorPrices;

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
    this.colors = const [],
    this.sizes = const [],
    this.sizePrices = const {},
    this.colorPrices = const {},
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      price: (map['price'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
      imagePath: map['imagePath'] as String,
      isOnSale: map['isOnSale'] as bool? ?? false,
      salePrice: (map['salePrice'] as num?)?.toDouble(),
      category: map['category'] as String,
      quantity: map['quantity'] as int? ?? 1,
      description: map['description'] as String,
      deliveryTime: (map['deliveryTime'] as num).toDouble(),
      colors: List<String>.from(map['colors'] ?? []),
      sizes: List<String>.from(map['sizes'] ?? []),
      sizePrices: Map<String, double>.from(map['sizePrices'] ?? {}),
      colorPrices: Map<String, double>.from(map['colorPrices'] ?? {}),
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
      'colors': colors,
      'sizes': sizes,
      'sizePrices': sizePrices,
      'colorPrices': colorPrices,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      imagePath: json['imagePath'] as String,
      isOnSale: json['isOnSale'] as bool? ?? false,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      category: json['category'] as String,
      quantity: json['quantity'] as int? ?? 1,
      description: json['description'] as String,
      deliveryTime: (json['deliveryTime'] as num).toDouble(),
      colors: List<String>.from(json['colors'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      sizePrices: Map<String, double>.from(json['sizePrices'] ?? {}),
      colorPrices: Map<String, double>.from(json['colorPrices'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
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
      'colors': colors,
      'sizes': sizes,
      'sizePrices': sizePrices,
      'colorPrices': colorPrices,
    };
  }

  double get displayPrice => isOnSale ? (salePrice ?? price) : price;

  Product copyWith({
    String? selectedSize,
    String? selectedColor,
  }) {
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
}
