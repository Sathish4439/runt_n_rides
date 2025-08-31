import 'dart:convert';
import 'package:flutter/services.dart';

class SheetId {
  static const enquiryForm = "12XL_f3KW3OAUsFB_RK0XEXHU6SjWOONDSAseNsglmSY";
  static const bookingSheet = "1pkKAf6YF4bMCX0x6oUAgbJnE4k8Sdlj2IxTPXZOR0nE";
  static const followBack = "1HAZj9461DiAJM3LKf4BnNGOCT-cUTn8Rr1pKuUaN1K8";

  static Future<Map<String, dynamic>> get credentials async {
    try {
      final String response = await rootBundle.loadString('assets/google_credentials.json');
      return jsonDecode(response);
    } catch (e) {
      print('Error loading Google credentials: $e');
      return {};
    }
  }
}