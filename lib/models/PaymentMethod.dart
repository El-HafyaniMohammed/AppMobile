class PaymentMethod {
  final String id; //* Identifiant de la carte
  final String type; //* Type de carte (ex: "Visa", "Mastercard")
  final String cardNumber; //* Numéro de la carte
  final String holderName; //* name of the card holder
  final String expiryDate; //* Date d'expiration
  final bool isDefault; //* Indique si c'est la carte par défaut

  PaymentMethod({
    required this.id,
    required this.type,
    required this.cardNumber,
    required this.holderName,
    required this.expiryDate,
    required this.isDefault,
  });
  //! factory constructor to create an instance of PayementCard from a Map.
  factory PaymentMethod.fromMap(Map<String, dynamic> data) {
    return PaymentMethod(
      id: data['id'] ?? '',
      type: data['type'] ?? '',
      cardNumber: data['cardNumber'] ?? '',
      holderName: data['holderName'] ?? '',
      expiryDate: data['expiryDate'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }
  //! Convert the instance of PayementCard to a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'cardNumber': cardNumber,
      'holderName': holderName,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
    };
  }
  @override
  String toString() {
    return 'PayementCard{id: $id, type: $type, cardNumber: $cardNumber, holderName: $holderName, expiryDate: $expiryDate, isDefault: $isDefault}';
  }
  //! Return a copy of the object with the modified fields.
  PaymentMethod copyWith({
    String? id,
    String? type,
    String? cardNumber,
    String? holderName,
    String? expiryDate,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      holderName: holderName ?? this.holderName,
      expiryDate: expiryDate ?? this.expiryDate,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
