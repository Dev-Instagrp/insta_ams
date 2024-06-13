import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:insta_ams/Authentication/Registration.dart';
import 'package:insta_ams/screens/homescreen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: "Email",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                labelText: "Password",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                loginUser(emailController.text.trim(), passwordController.text.trim());
                setState(() {
                  isLoading = true;
                });
              },
              child: Text("Login"),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                Get.to(Registration(), transition: Transition.zoom, curve: Curves.easeInOut);
              },
              child: Text("Not registered yet ?"),
            ),
          ],
        ),
      ),
    );
  }

  void loginUser(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signInWithEmailAndPassword(
          email: email, password: password);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Login Successful");
      emailController.clear();
      passwordController.clear();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Homescreen()));
    }
    catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }
}
