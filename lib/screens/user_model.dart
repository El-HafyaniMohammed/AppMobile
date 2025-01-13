
// user_model.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  DateTime? createdAt;
  DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.isEmailVerified,
    this.createdAt,
    this.lastLoginAt,
  });

  // Créer une instance de UserModel à partir d'un utilisateur Firebase
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
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
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
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
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      lastLoginAt: data['lastLoginAt'] != null ? DateTime.parse(data['lastLoginAt']) : null,
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
  }) async {
    if (newDisplayName != null || newPhotoURL != null) {
      Map<String, dynamic> updateData = {};
      
      if (newDisplayName != null) {
        updateData['displayName'] = newDisplayName;
      }
      
      if (newPhotoURL != null) {
        updateData['photoURL'] = newPhotoURL;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updateData);
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
      // ignore: avoid_print
      print('Error getting user from Firestore: $e');
      return null;
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
}