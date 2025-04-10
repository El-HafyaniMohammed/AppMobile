import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/User/ProfilePage.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/User/Login_and_Signin.dart';
import './screens/Home/home.dart';
import 'models/user_model.dart';
import 'screens/User/payment_page.dart';
import 'screens/User/addresses_page.dart';
import 'screens/User/orders_page.dart';
import 'screens/User/Wishlist.dart';
import 'screens/dashboard/AddProductPage.dart';
import 'screens/dashboard/MyProductsPage.dart';
import 'screens/User/support_page.dart';
import 'screens/dashboard/SalesAnalyticsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/chat_screen.dart'; // إضافة استيراد ChatScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyC7IbWkaVJFqL90nL_ZTco1d9fuUSfMtXY",
      appId: "1:354407730492:android:395e2880c44f6601732239",
      messagingSenderId: "354407730492",
      projectId: "e-commerce-8e85a",
      storageBucket: "e-commerce-8e85a.firebasestorage.app",
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
      // Always show OnboardingScreen as the initial screen
      home: const OnboardingScreen(),
      routes: {
        '/main': (context) => FutureBuilder(
          future: _getUserType(),
          builder: (context, snapshot) {
            final String userType = snapshot.data as String? ?? '';
            return MainScreen(user: _getCurrentUser());
          }
        ),
        '/login': (context) => const LoginScreen(),
        '/Home': (context) => const HomeScreen(),
        '/profile': (context) => ProfilePage(user: _getCurrentUser()),
        '/payment': (context) => const PaymentPage(),
        '/addresses': (context) => const AddressesPage(),
        '/orders': (context) => const OrdersPage(),
        '/wishlist': (context) => const WishlistPage(),
        '/add-product': (context) => const AddProductPage(),
        '/my-products': (context) => const MyProductsPage(),
        '/sales-analytics': (context) => const SalesAnalyticsPage(),
        '/support_page': (context) => const SupportPage(),
        '/chat': (context) =>  ChatScreen(), // إضافة مسار جديد لـ ChatScreen
      },
    );
  }

  Future<String> _getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType') ?? '';
  }

  Future<Map<String, dynamic>> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
    final userType = prefs.getString('userType') ?? '';

    print("Checking onboarding status: completed = $onboardingCompleted, userType = $userType");

    return {
      'onboardingCompleted': onboardingCompleted,
      'userType': userType,
    };
  }

  UserModel _getCurrentUser() {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? 'no-email',
        isEmailVerified: firebaseUser.emailVerified,
      );
    } else {
      return UserModel(
        uid: 'no-uid',
        email: 'no-email',
        isEmailVerified: false
      );
    }
  }
}