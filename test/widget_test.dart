import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/main.dart';

void main() {
  // Initialisation de Firebase pour les tests
  setupFirebase() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDPUMpNI11BCFvrnwrkrgj7SEZJTy2_2Vw",
        authDomain: "e-commerce-8e85a.firebaseapp.com",
        projectId: "e-commerce-8e85a",
        storageBucket: "e-commerce-8e85a.appspot.com",
        messagingSenderId: "354407730492",
        appId: "1:354407730492:web:40ab97e021526ed5732239",
      ),
    );
  }

  group('Widget Tests', () {
    setUpAll(() async {
      await setupFirebase();
    });

    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      // Construire l'application et déclencher un frame.
      await tester.pumpWidget(const MyApp());

      // Vérifiez que le compteur commence à 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Appuyer sur l'icône "+" et déclencher un frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Vérifiez que le compteur a été incrémenté.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
