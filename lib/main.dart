// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/User/user_page.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/User/profile.dart';
import './screens/Home/home.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyC7IbWkaVJFqL90nL_ZTco1d9fuUSfMtXY", // Clé API de votre configuration Firebase
      appId: "1:354407730492:android:395e2880c44f6601732239", // ID de l'application Android
      messagingSenderId: "354407730492", // Numéro de projet
      projectId: "e-commerce-8e85a", // ID du projet Firebase
      storageBucket: "e-commerce-8e85a.firebasestorage.app", // Bucket de stockage
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainScreen(user: UserModel(uid: 'some-uid', email: 'user@example.com', isEmailVerified: true)),
      routes: {
        '/main': (context) => MainScreen(user: UserModel(uid: 'some-uid', email: 'user@example.com', isEmailVerified: true)),
        '/login': (context) => const LoginScreen(),
        '/Home': (context) => const HomeScreen(),
        '/profile': (context) => ProfilePage(user: UserModel(uid: 'some-uid', email: 'user@example.com', isEmailVerified: true)),
      },
    );
  }
}