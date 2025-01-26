import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/screens/User/user_page.dart';
import 'screens/main_screen.dart';
import 'screens/User/profile.dart';
import './screens/Home/home.dart';
import 'models/user_model.dart';
import 'screens/User/payment_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/User/addresses_page.dart';
import 'screens/User/orders_page.dart';
import 'screens/User/Wishlist.dart';
import 'providers/LocaleProvider.dart'; // Import your LocaleProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyC7IbWkaVJFqL90nL_ZTco1d9fuUSfMtXY", // Firebase API key
      appId: "1:354407730492:android:395e2880c44f6601732239", // App ID
      messagingSenderId: "354407730492", // Project number
      projectId: "e-commerce-8e85a", // Project ID
      storageBucket: "e-commerce-8e85a.firebasestorage.app", // Storage bucket
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(), // Provide LocaleProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        scaffoldBackgroundColor: Colors.white,
      ),
      locale: localeProvider.locale, // Use the selected locale
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      home: MainScreen(user: _getCurrentUser()),
      routes: {
        '/main': (context) => MainScreen(user: _getCurrentUser()),
        '/login': (context) => const LoginScreen(),
        '/Home': (context) => const HomeScreen(),
        '/profile': (context) => ProfilePage(user: _getCurrentUser()),
        '/payment': (context) => const PaymentPage(),
        '/addresses': (context) => const AddressesPage(),
        '/orders': (context) => const OrdersPage(),
        '/wishlist': (context) => const WishlistPage(),
      },
    );
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
      // Return a default user or handle the case where the user is not logged in
      return UserModel(uid: 'no-uid', email: 'no-email', isEmailVerified: false);
    }
  }
}