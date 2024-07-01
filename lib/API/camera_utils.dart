import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:get/get.dart';

enum DetectionStatus { noFace, fail, success }

class AuthenticationController extends GetxController {
  CameraController? controller;
  WebSocketChannel? channel;
  var status = DetectionStatus.noFace.obs;

  Future<void> initializeResources() async {
    try {
      await requestCameraPermission();
      await initializeCamera();
      await initializeWebSocket();
    } catch (e) {
      print("Error initializing resources: $e");
      rethrow;
    }
  }

  Future<void> requestCameraPermission() async {
    if (await Permission.camera.isDenied) {
      await Permission.camera.request();
    }
    if (await Permission.camera.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception("No cameras available");
    }
    final firstCamera = cameras[1];
    controller = CameraController(firstCamera, ResolutionPreset.medium, enableAudio: false);
    await controller!.initialize();
  }

  Future<void> initializeWebSocket() async {
    channel = IOWebSocketChannel.connect('ws://192.168.1.32:8765');
    channel!.stream.listen((dynamic data) {
      data = jsonDecode(data);
      if (data['data'] == null) {
        debugPrint("Server Error occurred in recognizing face");
        return;
      }
      _updateDetectionStatus(data['data']);
    });
  }

  void _updateDetectionStatus(int statusData) {
    switch (statusData) {
      case 0:
        status.value = DetectionStatus.noFace;
        break;
      case 1:
        status.value = DetectionStatus.fail;
        break;
      case 2:
        status.value = DetectionStatus.success;
        break;
    }
  }

  Future<int> getResponse() async {
    EasyLoading.show(status: "Scanning Your face");
    try {
      await initializeResources();
      Timer.periodic(Duration(seconds: 3), (timer) async {
        final image = await controller!.takePicture();
        final compressedImageBytes = _compressedImage(image.path);
        channel!.sink.add(compressedImageBytes);
      });

      await Future.delayed(Duration(seconds: 5));

      EasyLoading.dismiss();
      if (status.value == DetectionStatus.noFace) {
        return 0;
      } else if (status.value == DetectionStatus.fail) {
        return 1;
      } else if (status.value == DetectionStatus.success) {
        return 2;
      } else {
        return 404;
      }
    } catch (e) {
      print("Error in getResponse: $e");
      return 404;
    } finally {
      await cleanupResources();
    }
  }

  Uint8List _compressedImage(String imagePath, {int quality = 85}) {
    final image = img.decodeImage(Uint8List.fromList(File(imagePath).readAsBytesSync()))!;
    return img.encodeJpg(image, quality: quality);
  }

  Future<void> cleanupResources() async {
    await controller?.dispose();
    await channel?.sink.close();
  }
}

Future<int> authenticateUser() async {
  final authController = Get.put(AuthenticationController());
  return await authController.getResponse();
}
