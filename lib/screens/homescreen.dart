import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:insta_ams/Authentication/login.dart';
import 'package:insta_ams/Database/fetch_details.dart';
import 'package:insta_ams/screens/announcements.dart';
import 'package:insta_ams/screens/my_details.dart';
import 'package:insta_ams/widgets/bottom_navigation.dart';
import 'package:insta_ams/widgets/central_div.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String? _username;
  String? _circle;
  String? _profileImagePath;
  String? _profilePictureUrl;
  int selectedIndex = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<Widget> _screens = [
    CentralDiv(),
    MyDetails(),
    Announcements()
  ];

  @override
  void initState() {
    super.initState();
    Geolocator.requestPermission();
    _fetchUsername();
    _fetchCircle();
    _fetchAndDownloadProfilePicture();
    _requestPermissions();
  }

  Future<void> _fetchUsername() async {
    final username = await FetchDetails.fetchUserName();
    setState(() {
      _username = username;
    });
  }

  Future<void> _fetchCircle() async {
    final circle = await FetchDetails.fetchCircle();
    setState(() {
      _circle = circle;
    });
  }

  Future<void> _fetchAndDownloadProfilePicture() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('employeeDetails')
          .doc(uid)
          .get();
      if (docSnapshot.exists) {
        final profilePictureUrl = docSnapshot.data()?['profilePicture'] as String?;
        setState(() {
          _profilePictureUrl = profilePictureUrl;
        });
        if (profilePictureUrl != null) {
          final directory = await getApplicationDocumentsDirectory();
          final filePath = path.join(directory.path, 'profile_picture.jpg');
          final response = await http.get(Uri.parse(profilePictureUrl));
          if (response.statusCode == 200) {
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            setState(() {
              _profileImagePath = filePath;
            });
          }
        }
      }
    }
  }

  Future<void> _requestPermissions() async {
    // Request camera permission
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      await Permission.camera.request();
    }

    // Request location permission
    var locationStatus = await Permission.location.status;
    if (locationStatus.isDenied) {
      await Permission.location.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/back.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: BottomNavigationWidget(
            homeTap: () {
              setState(() {
                selectedIndex = 0;
              });
            },
            announceTap: () {
              setState(() {
                selectedIndex = 2;
              });
            },
            logOutTap: () async{
              await auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
            },
            detailTap: () {
              setState(() {
                selectedIndex = 1;
              });
            },
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 28,
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: _profileImagePath != null
                      ? FileImage(File(_profileImagePath!))
                      : AssetImage("assets/images/profile.png") as ImageProvider,
                ),
                title: Text(
                  _username ?? "Loading...",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                subtitle: Text(
                  _circle ?? "Loading...",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 70,
              ),
              _screens[selectedIndex],
            ],
          ),
        ),
      ),
    );
  }
}
