import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SimplePage(),
    );
  }
}

class SimplePage extends StatelessWidget {
  const SimplePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My cart",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
            wordSpacing: 3,
            decoration: TextDecoration.underline,
            color: Colors.black,
            fontFamily: 'Raleway',
            backgroundColor: const Color.fromARGB(255, 245, 245, 245)
            ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            )),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz))],
      ),
    );
  }
}
