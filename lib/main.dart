import 'package:flutter/material.dart';
import 'package:firebase_demo_1/login.dart';
import 'package:firebase_demo_1/routes.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginPage(), routes: routes, );
  }
}
