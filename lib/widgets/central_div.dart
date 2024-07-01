import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:insta_ams/API/camera_utils.dart';
import 'package:insta_ams/Model/attendance_entry.dart';
import 'package:insta_ams/widgets/circle_buttons.dart';
import 'package:insta_ams/widgets/digital_clock.dart';
import 'package:intl/intl.dart';

class CentralDiv extends StatefulWidget {
  const CentralDiv({super.key});

  @override
  State<CentralDiv> createState() => _CentralDivState();
}

class _CentralDivState extends State<CentralDiv> {
  DetectionStatus? _status;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
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
              markAttendance("Check-In");
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

  Future<void> markAttendance(String activity) async {
    if (activity == "Check-In") {
      try {
        int result = await authenticateUser();
        if (result == 0) {
          Get.snackbar("Oops!", "No Face Detected",
              backgroundColor: Colors.red.withOpacity(0.5));
        }
        else if (result == 1) {
          Get.snackbar("Oops!", "Face not recognized",
              backgroundColor: Colors.red.withOpacity(0.5));
        }
        else if (result == 2) {
          Get.snackbar("Kudos!", "Face recognition successful marking your attendance", backgroundColor: Colors.greenAccent.withOpacity(0.5));
          RecordAttendance.checkIn();
        }
      } catch (e) {
        print("Error in onTap: $e");
        Get.snackbar("Error", "Something went wrong while processing");
      } finally {
        EasyLoading.dismiss();
      }
    }
    else {
      //TODO Create function for check-out
    }
  }
}
