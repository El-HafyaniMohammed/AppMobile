// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
class UserModel {
  final String uid;
  final String email;
  String? displayName;
  String? photoURL;
  String? phoneNumber;
  String? firstName;
  String? lastName;
  final bool isEmailVerified;
  DateTime? createdAt;
  DateTime? lastLoginAt;
  String? address;
  String? city;
  String? country;
  String? postalCode;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    required this.isEmailVerified,
    this.createdAt,
    this.lastLoginAt,
    this.address,
    this.city,
    this.country,
    this.postalCode,
  });

  // Créer une instance de UserModel à partir d'un utilisateur Firebase
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  // Convertir les données de l'utilisateur en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
    };
  }

  // Créer une instance de UserModel à partir d'un document Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      lastLoginAt: data['lastLoginAt'] != null ? DateTime.parse(data['lastLoginAt']) : null,
      address: data['address'],
      city: data['city'],
      country: data['country'],
      postalCode: data['postalCode'],
    );
  }

  // Méthode pour sauvegarder l'utilisateur dans Firestore
  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set(toMap());
  }

  // Méthode pour mettre à jour les informations de l'utilisateur
  Future<void> updateUserInfo({
    String? newDisplayName,
    String? newPhotoURL,
    String? newPhoneNumber,
    String? newFirstName,
    String? newLastName,
    String? newAddress,
    String? newCity,
    String? newCountry,
    String? newPostalCode,
  }) async {
    Map<String, dynamic> updateData = {};
    
    if (newDisplayName != null) {
      displayName = newDisplayName;
      updateData['displayName'] = newDisplayName;
    }
    
    if (newPhotoURL != null) {
      photoURL = newPhotoURL;
      updateData['photoURL'] = newPhotoURL;
    }

    if (newPhoneNumber != null) {
      phoneNumber = newPhoneNumber;
      updateData['phoneNumber'] = newPhoneNumber;
    }

    if (newFirstName != null) {
      firstName = newFirstName;
      updateData['firstName'] = newFirstName;
    }

    if (newLastName != null) {
      lastName = newLastName;
      updateData['lastName'] = newLastName;
    }

    if (newAddress != null) {
      address = newAddress;
      updateData['address'] = newAddress;
    }

    if (newCity != null) {
      city = newCity;
      updateData['city'] = newCity;
    }

    if (newCountry != null) {
      country = newCountry;
      updateData['country'] = newCountry;
    }

    if (newPostalCode != null) {
      postalCode = newPostalCode;
      updateData['postalCode'] = newPostalCode;
    }

    if (updateData.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update(updateData);
      } catch (e) {
        throw Exception('Erreur lors de la mise à jour du profil : $e');
      }
    }
  }

  // Méthode statique pour récupérer un utilisateur depuis Firestore
  static Future<UserModel?> getUserFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur : $e');
    }
  }

  // Méthode pour mettre à jour la dernière connexion
  Future<void> updateLastLogin() async {
    lastLoginAt = DateTime.now();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'lastLoginAt': lastLoginAt?.toIso8601String()});
  }

  // Méthode pour obtenir le nom complet
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (displayName != null) {
      return displayName!;
    } else {
      return email.split('@').first;
    }
  }

  // Méthode pour vérifier si le profil est complet
  bool get isProfileComplete {
    return firstName != null && 
           lastName != null && 
           phoneNumber != null &&
           address != null &&
           city != null &&
           country != null &&
           postalCode != null;
  }

  // Méthode pour téléverser l'image
 Future<String?> uploadImage(dynamic imageFile) async {
  try {
    // Ensure the file is not null
    if (imageFile == null) {
      throw Exception('No image file was provided');
    }
    print('Starting image upload...');

    // Ensure UID is valid
    if (uid.isEmpty) {
      throw Exception('Invalid user ID provided.');
    }

    // Generate a valid file path
    String fileName = 'profile_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    print('Generated file name: $fileName');

    // Reference to Firebase Storage
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);

    UploadTask? uploadTask;

    // Handle web upload or mobile upload based on platform
    if (kIsWeb) {
      if (imageFile is PlatformFile) {
        // For web, use file bytes and metadata
        final Uint8List fileBytes = imageFile.bytes!;
        final metadata = SettableMetadata(contentType: 'image/jpeg');

        uploadTask = storageReference.putData(fileBytes, metadata);
      } else {
        throw Exception('Invalid file type for web upload');
      }
    } else {
      if (imageFile is File) {
        // For mobile, use a File instance
        uploadTask = storageReference.putFile(imageFile);
      } else {
        throw Exception('Invalid file type for mobile upload');
      }
    }

    // Wait for the upload to complete
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    print('Image successfully uploaded to: $downloadURL');
    return downloadURL;
  } catch (e) {
    // Log error and pass it back
    print('Error during image upload: $e');
    return null;
  }
}

}
