class OrderStatus {
  final String title; // Titre de l'étape (ex: "Commande confirmée")
  final String description; // Description de l'étape
  final bool isCompleted; // Indique si l'étape est terminée
  final String icon; // Nom de l'icône (ex: "check_circle")
  final String? timestamp; // Horodatage de l'étape

  OrderStatus({
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.icon,
    this.timestamp,
  });

  // Convertir un OrderStatus en Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'icon': icon,
      'timestamp': timestamp,
    };
  }

  // Créer un OrderStatus à partir d'un Map
  static OrderStatus fromMap(Map<String, dynamic> map) {
    return OrderStatus(
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
      icon: map['icon'],
      timestamp: map['timestamp'],
    );
  }
}