import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_location_code/open_location_code.dart';
import '../Database/fetch_details.dart';

class RecordAttendance {
  static Future<bool> checkIn() async {
    final String? circleName = await FetchDetails.fetchCircle();
    final String? employeeName = await FetchDetails.fetchUserName();

    final FirebaseFirestore db = FirebaseFirestore.instance;
    final String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String time = DateFormat('hh:mm a').format(DateTime.now());
    String? address;
    double? latitude;
    double? longitude;
    dynamic pluscode;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
    } else {
      Position currentPosition =
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      latitude = currentPosition.latitude;
      longitude = currentPosition.longitude;
      pluscode = PlusCode.encode(LatLng(latitude, longitude));
    }

    final HashMap<String, dynamic> attendanceRecord = HashMap<String, dynamic>();
    attendanceRecord.addAll({
      'Employee Name': employeeName,
      'Department': circleName,
      'Date': date,
      'CheckIn_Time': time,
    });
    try {
      await db.collection('attendance').add(attendanceRecord);
      Get.snackbar("Kudos!", "Checked In successfully!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue.withOpacity(0.4));
      return true;
    } catch (error) {
      print('Error recording attendance: $error');
      return false;
    }
  }
}
