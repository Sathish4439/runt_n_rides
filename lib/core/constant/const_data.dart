import 'dart:convert';
import 'package:flutter/services.dart';

class SheetId {
  // static const enquiryForm = "12XL_f3KW3OAUsFB_RK0XEXHU6SjWOONDSAseNsglmSY";
  // static const bookingSheet = "1pkKAf6YF4bMCX0x6oUAgbJnE4k8Sdlj2IxTPXZOR0nE";
  // static const followBack = "1HAZj9461DiAJM3LKf4BnNGOCT-cUTn8Rr1pKuUaN1K8";
  static const enquiryForm = "11ktjxa1FA8QixSUoUtlDCln9TqXLaZbN8s3zvqbaR6w";
  static const bookingSheet = "1Du8XbpMNM7wEJNVX52sJUniGSum99e0XsiHWYTnQ5Zs";
  static const followBack = "1OLdGHGbhzvKlUxGhE-8m2kNpuSBSGuhi3oMClzbKyEE";

  static Future<Map<String, dynamic>> get credentials async {
    try {
      final String response = await rootBundle.loadString(
        'assets/google_credentials.json',
      );
      return jsonDecode(response);
    } catch (e) {
      print('Error loading Google credentials: $e');
      return {};
    }
  }
}

class CosntString {
  static final userName = "userName";
  static final password = "password";
  static final islogin = "islogin";
}
