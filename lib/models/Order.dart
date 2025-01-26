import 'Cart_Item.dart';
import 'OrderStatus.dart';
import 'product.dart';
class Order {
  final String id; // Identifiant unique de la commande
  final List<CartItem> items; // Liste des articles commandés
  final String deliveryAddress; // Adresse de livraison
  final String city; // Ville de livraison
  final String phoneNumber; // Numéro de téléphone du client
  final String paymentMethod; // Méthode de paiement (ex: carte, cash, etc.)
  final double subtotal; // Sous-total de la commande
  final double deliveryFee; // Frais de livraison
  final double discount; // Réduction appliquée
  final double total; // Montant total de la commande
  final DateTime orderDate; // Date de la commande
  final List<OrderStatus> statuses; // Statuts de la commande

  Order({
    required this.id,
    required this.items,
    required this.deliveryAddress,
    required this.city,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.orderDate,
    this.statuses = const [], // Par défaut, une liste vide de statuts
  });

  // Méthode pour convertir un objet Order en Map (utile pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'deliveryAddress': deliveryAddress,
      'city': city,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'orderDate': orderDate.toIso8601String(),
      'statuses': statuses.map((status) => status.toMap()).toList(),
    };
  }

  // Méthode pour créer un objet Order à partir d'un Map (utile pour Firestore)
 static Future<Order> fromMap(Map<String, dynamic> map, Future<Product> Function(String) fetchProduct) async {
  // Récupérer les produits correspondants
  final List<CartItem> items = [];
    for (final itemMap in map['items']) {
      final productId = itemMap['productId'];
      final product = await fetchProduct(productId); // Récupérer le produit par son ID
      items.add(CartItem.fromMap(itemMap, product));
    }

    return Order(
      id: map['id'],
      items: items,
      deliveryAddress: map['deliveryAddress'],
      city: map['city'],
      phoneNumber: map['phoneNumber'],
      paymentMethod: map['paymentMethod'],
      subtotal: map['subtotal'],
      deliveryFee: map['deliveryFee'],
      discount: map['discount'],
      total: map['total'],
      orderDate: DateTime.parse(map['orderDate']),
      statuses: (map['statuses'] as List).map((status) => OrderStatus.fromMap(status)).toList(),
    );
  }

  
}