import 'package:firebase_demo_1/home_page.dart';
import 'package:firebase_demo_1/login.dart';
import 'package:firebase_demo_1/password_recovery.dart';
import 'package:firebase_demo_1/register.dart';

final routes = {
  "/homepage": (_) => HomePage(),
  "/login": (_) => LoginPage(),
  "/register": (_) => RegisterPage(),
  "/passwordrecovery": (_) => PasswordRecoveryPage(),
};
