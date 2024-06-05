import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      print('Can check biometrics: $canCheck');
      return canCheck;
    } on PlatformException catch (e) {
      print("Error checking biometrics: $e");
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async {
    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      print('Available biometrics: $availableBiometrics');
      return availableBiometrics;
    } on PlatformException catch (e) {
      print("Error getting biometrics: $e");
      return <BiometricType>[];
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) {
      return false;
    }

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Scan Fingerprint to Authenticate',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true
        ),
      );
      return authenticated;
    } on PlatformException catch (e) {
      return false;
    }
  }
}
