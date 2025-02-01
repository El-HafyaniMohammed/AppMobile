class AddressUser {
  final String addressId; // Identifiant unique de l'adresse
  final String title; // Titre de l'adresse (ex: "Maison", "Travail")
  final String name; // Nom complet de l'utilisateur
  final String street; // Rue et numéro
  final String city; // Ville
  final String postalCode; // Code postal
  final bool isDefault; // Indique si c'est l'adresse par défaut
  final String phoneNumber; // Numéro de téléphone

  /// Constructeur pour créer une instance d'AddressUser.
  AddressUser({
    required this.addressId,
    required this.title,
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    this.isDefault = false, // Par défaut, l'adresse n'est pas principale
    required this.phoneNumber,
  });

  /// Factory constructor pour créer une instance d'AddressUser à partir d'une Map.
  factory AddressUser.fromMap(Map<String, dynamic> data) {
    return AddressUser(
      addressId: data['addressId'] ?? '', // Valeur par défaut si la clé est manquante
      title: data['title'] ?? '',
      name: data['name'] ?? '',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      postalCode: data['postalCode'] ?? '',
      isDefault: data['isDefault'] ?? false,
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  /// Convertit l'instance d'AddressUser en une Map.
  Map<String, dynamic> toMap() {
    return {
      'addressId': addressId,
      'title': title,
      'name': name,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'phoneNumber': phoneNumber,
    };
  }

  /// Retourne une copie de l'objet avec les champs modifiés.
  AddressUser copyWith({
    String? addressId,
    String? title,
    String? name,
    String? street,
    String? city,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressUser(
      addressId: addressId ?? this.addressId,
      title: title ?? this.title,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      phoneNumber: phoneNumber,
    );
  }

  @override
  String toString() {
    return 'AddressUser('
        'addressId: $addressId, '
        'title: $title, '
        'name: $name, '
        'street: $street, '
        'city: $city, '
        'postalCode: $postalCode, '
        'isDefault: $isDefault, '
        'phoneNumber: $phoneNumber'
    ')';
  }
}