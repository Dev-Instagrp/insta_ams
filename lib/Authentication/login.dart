import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_ams/Authentication/Registration.dart';
import 'package:insta_ams/screens/homescreen.dart';

import 'face_authentication.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? _profilePictureUrl; // Define _profilePictureUrl
  DetectionStatus? _status; // Define _status
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

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
                setState(() {
                  isLoading = true;
                });
                  await _showCameraPreviewDialog(context);
              },
              child: Text("Login"),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Registration()));
              },
              child: Text("Not registered yet ?"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loginUser(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = auth.currentUser!.uid;
      final documentSnapshot = await FirebaseFirestore.instance.collection('employeeDetails').doc(uid).get();
      if (documentSnapshot.exists) {
        final profilePictureUrl = documentSnapshot['profilePicture'];
        profilePictureUrl!=null ? print("Got image from database") : print("Not getting image from firebase");
        _profilePictureUrl = profilePictureUrl;
      }
      final bool faceRecognitionResult = await CameraScreen.recognizeFace(context);
      if(faceRecognitionResult){
        Fluttertoast.showToast(msg: "Login Successful");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homescreen()));
      }
      else{
        Fluttertoast.showToast(msg: "Face detection failed");
        FirebaseAuth auth = FirebaseAuth.instance;
        auth.signOut();
      }
      setState(() {
        isLoading = false;
        emailController.clear();
        passwordController.clear();
      });
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _showCameraPreviewDialog(BuildContext context) async {
    try {
      // Ensure the controller is initialized before showing the preview
      await _initializeControllerFuture;

      // Login user and show camera preview
      await loginUser(emailController.text.trim(), passwordController.text.trim());

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              height: 300,
              child: CameraPreview(_controller),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Dispose of the controller and close the dialog
                  _controller.dispose();
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to show camera preview. Please try again.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
    _controller.dispose();
  }

}
