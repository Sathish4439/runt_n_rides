import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void showSuccess(String message, {String title = "Success"}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.green.shade600,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
}

// Show error message
void showError(String message, {String title = "Error"}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.red.shade600,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
}

// Show info message
void showInfo(String message, {String title = "Info"}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.blue.shade600,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
}

void printData(dynamic data) {
  if (kDebugMode) {
    print(data);
  }
}
