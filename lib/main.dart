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
            color: Colors.black,
            fontFamily: 'Raleway',
            backgroundColor: const Color.fromARGB(255, 245, 245, 245)
            ),
        ),
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.fromLTRB(3,1,2,1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle ,
          ),
          width: 40,
          height: 40,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Colors.black, // Contraste avec le fond
              ),
            ),
          ),
        actions: [
          Container(
            margin: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle ,
              ),
            width: 40,
            height: 40,
            padding: EdgeInsets.fromLTRB(2,0,3,2),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz, size: 20,))
          )
          ],
      ),
    );
  }
}
