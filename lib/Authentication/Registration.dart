import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_ams/Authentication/login.dart';
import 'package:insta_ams/screens/homescreen.dart';
import 'package:insta_ams/widgets/input_fields.dart';
import '../Database/fetch_details.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  bool isLoading = false;
  List<String> circleList = [];
  String? selectedCircle;
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchCircleList();
  }

  Future<void> fetchCircleList() async {
    List<String>? fetchedList = await FetchDetails.fetchCircleList();
    if (fetchedList != null) {
      setState(() {
        circleList = fetchedList;
      });
    } else {
      // Handle the case where the list is null
      Fluttertoast.showToast(msg: "Failed to fetch circle list.");
    }
  }

  Future<void> _getImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    InputFields(
                        inputController: nameController,
                        label: 'Enter Name',
                        isPassword: false),
                    SizedBox(
                      height: 20,
                    ),
                    InputFields(
                        inputController: emailController,
                        label: "Enter Email",
                        isPassword: false),
                    SizedBox(
                      height: 20,
                    ),
                    InputFields(
                        inputController: phoneController,
                        label: "Enter Phone number",
                        isPassword: false),
                    SizedBox(
                      height: 20,
                    ),
                    InputFields(
                        inputController: passwordController,
                        label: "Enter Password",
                        isPassword: true),
                    SizedBox(
                      height: 20,
                    ),
                    InputFields(
                        inputController: confirmPasswordController,
                        label: "Confirm Password",
                        isPassword: true),
                    SizedBox(
                      height: 20,
                    ),
                    circleList.isNotEmpty
                        ? CustomDropdown<String>(
                      hintText: 'Select Circle',
                      items: circleList,
                      onChanged: (value) {
                        setState(() {
                          selectedCircle = value;
                        });
                      },
                    )
                        : Text("No Circle to display"),
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
                        registerUser(emailController.text.trim(), nameController.text.trim(), phoneController.text.trim(),  passwordController.text.trim(), confirmPasswordController.text.trim());
                      },
                      child: Text("Register"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Login()));
                      },
                      child: Text("Already have account ?"),
                    ),
                  ],
                ),
                Positioned(
                  top: 20,
                  child: GestureDetector(
                    onTap: _getImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                      _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(
                        Icons.camera_alt,
                        size: 40,
                      )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerUser(String email, String name, String phone,
      String password, String confirmPassword) async {
    try {
      // Check if passwords match
      if (password != confirmPassword) {
        throw FirebaseAuthException(
          code: 'passwords-not-matching',
          message: 'Passwords do not match',
        );
      }
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String userId = userCredential.user!.uid;
      String? profilePictureUrl;
      if (_image != null) {
        String imageName = 'profilePictures/${userId}/${name}_profile_picture.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(imageName);
        UploadTask uploadTask = ref.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        profilePictureUrl = await taskSnapshot.ref.getDownloadURL();
      }
      String? department = selectedCircle;
      await FirebaseFirestore.instance.collection('employeeDetails').doc(userId).set({
        'username': name,
        'email': email,
        'phoneNumber': phone,
        'Circle': department,
        'geoFencing': false,
        'profilePicture': profilePictureUrl,
        'deletePermission': null,
        'isEnrolled': false,
      });
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (e is FirebaseAuthException) {
        String errorMessage = 'Registration failed';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email is already in use';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak';
        } else if (e.code == 'passwords-not-matching') {
          errorMessage = 'Passwords do not match';
        }
        Fluttertoast.showToast(msg: errorMessage);
      } else {
        Fluttertoast.showToast(msg: 'Registration failed');
      }
    }
  }

}
