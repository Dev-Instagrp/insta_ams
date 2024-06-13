import 'package:clock_widget/clock_widget.dart';
import 'package:clock_widget/digital_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:insta_ams/API/local_auth_api.dart';
import 'package:insta_ams/Model/attendance_entry.dart';
import 'package:insta_ams/widgets/circle_buttons.dart';
import 'package:insta_ams/widgets/digital_clock.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CentralDiv extends StatefulWidget {
  const CentralDiv({super.key});

  @override
  State<CentralDiv> createState() => _CentralDivState();
}

class _CentralDivState extends State<CentralDiv> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    bool isLoading = false;
    final dateFormatter = DateFormat('MMMM dd, yyyy - EEEE');
    final currentDate = dateFormatter.format(now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: 370,
      height: 450,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Clock(),
          Text(
            currentDate,
            style: const TextStyle(fontSize: 20, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 10),
          CircularButtons(
            title: "Check-In",
            icon: Icons.login_rounded,
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              bool response = await RecordAttendance.checkIn();
            },
          ),
          const SizedBox(height: 25),
          CircularButtons(
            title: "Check-Out",
            icon: Icons.logout_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
