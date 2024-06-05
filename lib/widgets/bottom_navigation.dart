import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final VoidCallback homeTap;
  final VoidCallback detailTap;
  final VoidCallback announceTap;
  final VoidCallback logOutTap;
  const BottomNavigationWidget({super.key, required this.homeTap, required this.announceTap, required this.logOutTap, required this.detailTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(onPressed: homeTap, icon: Image.asset("assets/images/home.png", width: 34,height: 34,)),
          IconButton(onPressed: detailTap, icon: Image.asset("assets/images/details.png", width: 34,height: 34,)),
          IconButton(onPressed: announceTap, icon: Image.asset("assets/images/announcement.png", width: 34,height: 34,)),
          IconButton(onPressed: logOutTap, icon: Image.asset("assets/images/logout.png", width: 34,height: 34,)),
        ],
      ),
    );
  }
}
