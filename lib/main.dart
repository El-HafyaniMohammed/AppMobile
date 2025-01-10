// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/user_page.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/profile.dart';
import './screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey:
          "AIzaSyDPUMpNI11BCFvrnwrkrgj7SEZJTy2_2Vw", // Remplacez par vos valeurs
      authDomain: "e-commerce-8e85a.firebaseapp.com",
      projectId: "e-commerce-8e85a",
      storageBucket: "e-commerce-8e85a.firebasestorage.app",
      messagingSenderId: "354407730492",
      appId: "1:354407730492:web:40ab97e021526ed5732239",
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
      home: const MainScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/Home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
