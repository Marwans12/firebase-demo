import "package:flutter/material.dart";
import "package:note_app/login_page.dart";

var routes = {
  "/login" : (context) => LoginPage(),
  "/home" : (context) => Scaffold(body: MaterialButton(onPressed: () {Navigator.of(context).pushReplacementNamed("/login");}),)
};