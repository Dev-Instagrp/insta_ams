import 'package:flutter/material.dart';
import 'package:insta_ams/API/local_auth_api.dart';
import 'package:insta_ams/widgets/circle_buttons.dart';
import 'package:intl/intl.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CentralDiv extends StatelessWidget {
  const CentralDiv({super.key});

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
          DigitalClock(
            digitAnimationStyle: Curves.elasticOut,
            areaDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            hourMinuteDigitTextStyle: const TextStyle(
              fontSize: 30,
              color: Colors.black,
            ),
            is24HourTimeFormat: false,
            showSecondsDigit: false,
            colon: const Center(
              child: Text(
                ":",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          Text(
            currentDate,
            style: const TextStyle(fontSize: 20, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 10),
          CircularButtons(
            title: "Check-In",
            icon: Icons.login_rounded,
            onTap: () async {
              final isAuthenticated = await LocalAuthApi.authenticate();
              isAuthenticated
                  ? Fluttertoast.showToast(msg: "Authentication Successful")
                  : Fluttertoast.showToast(msg: "Authentication Failed");
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
