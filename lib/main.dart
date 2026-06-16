import 'package:firebase_demo_1/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_demo_1/login.dart';
import 'package:firebase_demo_1/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GoogleSignIn.instance.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: MaterialApp(home: FirebaseAuth.instance.currentUser == null ? LoginPage() : HomePage(), routes: routes));
  }
}

