import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:insta_ams/Authentication/login.dart';
import 'package:insta_ams/firebase_options.dart';
import 'package:insta_ams/screens/homescreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Manrope"
      ),
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
