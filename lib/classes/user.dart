class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String profileImage;
  final bool isVerified;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;
  final UserPreferences preferences;
  final UserStats stats;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.isVerified,
    required this.addresses,
    required this.paymentMethods,
    required this.preferences,
    required this.stats,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profileImage'],
      isVerified: json['isVerified'],
      addresses: (json['addresses'] as List)
          .map((addr) => Address.fromJson(addr))
          .toList(),
      paymentMethods: (json['paymentMethods'] as List)
          .map((pm) => PaymentMethod.fromJson(pm))
          .toList(),
      preferences: UserPreferences.fromJson(json['preferences']),
      stats: UserStats.fromJson(json['stats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'isVerified': isVerified,
      'addresses': addresses.map((addr) => addr.toJson()).toList(),
      'paymentMethods': paymentMethods.map((pm) => pm.toJson()).toList(),
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
    };
  }
}

class Address {
  final String id;
  final String street;
  final String city;
  final String postalCode;
  final String country;
  final bool isDefault;

  Address({
    required this.id,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      street: json['street'],
      city: json['city'],
      postalCode: json['postalCode'],
      country: json['country'],
      isDefault: json['isDefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
    };
  }
}

class PaymentMethod {
  final String id;
  final String type;
  final String lastFourDigits;
  final String expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.expiryDate,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      lastFourDigits: json['lastFourDigits'],
      expiryDate: json['expiryDate'],
      isDefault: json['isDefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'lastFourDigits': lastFourDigits,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
    };
  }
}

class UserPreferences {
  final bool notificationsEnabled;
  final String language;
  final bool darkModeEnabled;
  final List<String> interests;

  UserPreferences({
    required this.notificationsEnabled,
    required this.language,
    required this.darkModeEnabled,
    required this.interests,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notificationsEnabled'],
      language: json['language'],
      darkModeEnabled: json['darkModeEnabled'],
      interests: List<String>.from(json['interests']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'language': language,
      'darkModeEnabled': darkModeEnabled,
      'interests': interests,
    };
  }
}

class UserStats {
  final int totalOrders;
  final int pendingOrders;
  final int wishlistItems;
  final int reviews;

  UserStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.wishlistItems,
    required this.reviews,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalOrders: json['totalOrders'],
      pendingOrders: json['pendingOrders'],
      wishlistItems: json['wishlistItems'],
      reviews: json['reviews'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'wishlistItems': wishlistItems,
      'reviews': reviews,
    };
  }
}
