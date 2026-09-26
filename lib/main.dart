import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleSignIn.instance.initialize();
  await Firebase.initializeApp();
  runApp( MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final primaryColor = Colors.orange;
  final foregroundColor = Colors.white;
  late final theme = ThemeData(
      colorScheme: ThemeData().colorScheme.copyWith(
        primary: primaryColor,
        onPrimary: Colors.white,
        surfaceContainer: Colors.white
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(foregroundColor: foregroundColor, backgroundColor: primaryColor),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: const Color.fromARGB(255, 255, 184, 78),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: primaryColor,
        foregroundColor: foregroundColor,
      ),
      dialogTheme: DialogThemeData(backgroundColor: Colors.white),
      textTheme: TextTheme(
        titleLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        bodySmall: TextStyle(color: Colors.grey[500]),
        labelMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey[200],
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(180),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(180)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      scrollbarTheme: ScrollbarThemeData(thumbVisibility: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        return true;
      })),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size.zero),
          padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
        ),
      ),
    );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: FirebaseAuth.instance.currentUser == null
          ? LoginPage()
          : HomePage(),
      routes: routes,
    );
  }
}
