import "package:note_app/home_page.dart";
import "package:note_app/login_page.dart";
import "package:note_app/register_page.dart";

var routes = {
  "/login" : (context) => LoginPage(),
  "/register" : (context) => RegisterPage(),
  "/home" : (context) => HomePage(),
};