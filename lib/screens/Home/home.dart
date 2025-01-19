import 'package:flutter/material.dart';
import '../../config/AppColors.dart' as config;
import 'discover_page.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: config.AppColors.primary,
        scaffoldBackgroundColor: config.AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: config.AppColors.background,
          elevation: 0,
        ),
      ),
      home: const DiscoverPage(),
    );
  }
}
