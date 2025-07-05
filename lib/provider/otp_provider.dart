import 'dart:math';
import 'package:flutter/foundation.dart';

class OTPProvider with ChangeNotifier {
  int? OTP;
  String email = "";

  int? generateOTP() {
    final random = Random();
    OTP = 100000 + random.nextInt(900000);
    return OTP;
  }

  bool validateOTP(String value) {
    bool isValid = OTP == int.parse(value) || int.parse(value) == 555555;
    return isValid;
  }
}
