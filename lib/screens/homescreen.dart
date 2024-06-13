import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:insta_ams/Authentication/login.dart';
import 'package:insta_ams/Database/fetch_details.dart';
import 'package:insta_ams/screens/announcements.dart';
import 'package:insta_ams/screens/my_details.dart';
import 'package:insta_ams/widgets/bottom_navigation.dart';
import 'package:insta_ams/widgets/central_div.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String? _username;
  String? _circle;
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
                  backgroundImage: AssetImage("assets/images/profile.png"),
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
