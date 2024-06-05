import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';

enum DetectionStatus { noFace, fail, success }

class CameraScreen {
  static late CameraController _controller;
  static DetectionStatus? _status;
  static String? _profilePictureUrl;

  static Future<bool> recognizeFace(BuildContext context) async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller.initialize();

      final image = await _controller.takePicture();
      final compressedImageBytes = await _compressImage(image.path);
      await _fetchProfilePictureUrl();
      await _sendImageToFlaskServer(compressedImageBytes);

      if (_status == DetectionStatus.success) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    } finally {
      _controller.dispose();
    }
  }

  static Future<void> _fetchProfilePictureUrl() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    final documentSnapshot = await FirebaseFirestore.instance.collection('employeeDetails').doc(uid).get();
    if (documentSnapshot.exists) {
      final profilePictureUrl = documentSnapshot['profilePicture'];
      _profilePictureUrl = profilePictureUrl;
    }
  }

  static Future<Uint8List> _compressImage(String imagePath) async {
    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();
    return imageBytes;
  }

  static Future<void> _sendImageToFlaskServer(Uint8List compressedImageBytes) async {
    if (_profilePictureUrl == null) {
      print('Profile picture URL is null');
      return;
    }

    final profilePictureResponse = await http.get(Uri.parse(_profilePictureUrl!));
    if (profilePictureResponse.statusCode != 200) {
      print('Failed to fetch profile picture');
      return;
    }

    final profilePictureBytes = profilePictureResponse.bodyBytes;
    final uri = Uri.parse('http://192.168.1.27:5000/recognize');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'reference_image',
          profilePictureBytes,
          filename: 'profile_picture.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      )
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          compressedImageBytes,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      try {
        final data = jsonDecode(responseBody);

        if (data['data'] == null) {
          print('Server error occurred in recognizing face');
          return;
        }
        switch (data['data']) {
          case 0:
            _status = DetectionStatus.noFace;
            break;
          case 1:
            _status = DetectionStatus.fail;
            break;
          case 2:
            _status = DetectionStatus.success;
            break;
          default:
            _status = DetectionStatus.noFace;
            break;
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: $responseBody');
      }
    } else {
      print('Server returned an error: ${response.statusCode}');
      print('Response body: ${await response.stream.bytesToString()}');
    }
  }

  static Future<void> showCameraPreview(BuildContext context) async {
    final bool success = await recognizeFace(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Camera Preview'),
          content: _status == null
              ? Text('Initializing...')
              : _status == DetectionStatus.noFace
              ? Text('No Face Detected')
              : _status == DetectionStatus.fail
              ? Text('Unrecognized Face Detected')
              : Text('Face Recognized'),
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
}
