import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rutsnrides_admin/feature/auth/view/auth_screen.dart';
import 'package:rutsnrides_admin/feature/main_screen.dart';

class AuthController extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Controllers
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  // UI state
  var showPassword = true.obs;
  var loginLoad = false.obs;

  // Hardcoded credentials
  final String _validUsername = "@Sales123";
  final String _validPassword = "Ruts@3067";

  // Observable state
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus(); // UNCOMMENT THIS to check if already logged in
  }

  Future<void> login() async {
    loginLoad.value = true;

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    await Future.delayed(const Duration(seconds: 1)); // fake loading

    if (username == _validUsername && password == _validPassword) {
      // Store login info securely
      await _secureStorage.write(key: "username", value: username);
      await _secureStorage.write(key: "isLoggedIn", value: "true");

      isLoggedIn.value = true;
      loginLoad.value = false;
      
      Get.snackbar(
        "Login Successful ✅",
        "Welcome $username",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      // Navigate to MainScreen
      Get.offAll(() => const MainScreen());
    } else {
      loginLoad.value = false;
      Get.snackbar(
        "Login Failed ❌",
        "Invalid username or password",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    isLoggedIn.value = false;

    Get.snackbar(
      "Logged Out",
      "You have been successfully logged out",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );

    // Navigate to AuthScreen after logout
    Get.offAll(() => const AuthScreen());
  }

  Future<void> checkLoginStatus() async {
    try {
      debugPrint("🔍 Checking login status...");
      
      final status = await _secureStorage.read(key: "isLoggedIn");
      debugPrint("📊 Login status from storage: '$status'");
      
      final currentRoute = Get.currentRoute;
      debugPrint("📍 Current route: $currentRoute");

      final bool shouldNavigateToMain = status == "true" && currentRoute != '/main';
      final bool shouldNavigateToAuth = status != "true" && currentRoute != '/auth';

      debugPrint("🚦 Should navigate to Main: $shouldNavigateToMain");
      debugPrint("🚦 Should navigate to Auth: $shouldNavigateToAuth");

      if (shouldNavigateToMain) {
        debugPrint("✅ User is logged in, navigating to MainScreen");
        isLoggedIn.value = true;
        Get.offAll(() => const MainScreen());
      } else if (shouldNavigateToAuth) {
        debugPrint("🔐 User is not logged in, navigating to AuthScreen");
        isLoggedIn.value = false;
        Get.offAll(() => const AuthScreen());
      } else {
        // Just update the status without navigation
        isLoggedIn.value = status == "true";
        debugPrint("📌 Already on correct screen, status updated to: ${isLoggedIn.value}");
      }
      
    } catch (e) {
      debugPrint("❌ Error checking login status: $e");
      isLoggedIn.value = false;
      
      final currentRoute = Get.currentRoute;
      debugPrint("📍 Current route during error: $currentRoute");
      
      // Only navigate to auth if not already there
      if (currentRoute != '/auth') {
        debugPrint("⚠️ Fallback navigation to AuthScreen due to error");
        Get.offAll(() => const AuthScreen());
      } else {
        debugPrint("📌 Already on AuthScreen, no navigation needed");
      }
    } finally {
      debugPrint("🏁 Login status check completed");
    }
  }

  // Helper method to clear text controllers
  void clearControllers() {
    usernameController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}