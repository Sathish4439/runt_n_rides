import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/api_service.dart';
import 'package:rutsnrides_admin/core/services/endpoint.dart';
import 'package:rutsnrides_admin/core/storage/local_storage.dart';
import 'package:rutsnrides_admin/core/utils/utils.dart';
import 'package:rutsnrides_admin/feature/auth/view/auth_screen.dart';
import 'package:rutsnrides_admin/feature/main_screen.dart';
import 'package:rutsnrides_admin/main.dart';

class AuthController extends GetxController {
  final api = ApiService();

  // Controllers
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var emailController = TextEditingController();

  // UI state
  var showPassword = true.obs;
  var loginLoad = false.obs;

  // Observable state
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus(); // UNCOMMENT THIS to check if already logged in
  }

  Future<void> login() async {
    try {
      loginLoad.value = true;

      final username = usernameController.text.trim();
      final password = passwordController.text.trim();

      var bodyJson = {"email": username, "password": password};

      var res = await api.post(EndPoints.login, data: bodyJson);

      if (res.data['success']) {
        final user = res.data['user'];

        // Save details securely
        await SecureStorageService.writeData(CosntString.id, user['id']);
        await SecureStorageService.writeData(CosntString.email, user['email']);
        await SecureStorageService.writeData(CosntString.islogin, "true");
        await SecureStorageService.writeData(
          CosntString.userName,
          user['fullName'],
        );
        await SecureStorageService.writeData(CosntString.role, user['role']);
        await SecureStorageService.writeData(
          CosntString.token,
          res.data['accessToken'],
        );
      }
    } catch (e) {
      printData(e);
    } finally {
      loginLoad.value = false; // Stop loader

      checkLoginStatus();

      usernameController.clear();
      passwordController.clear();
    }
  }

  Future<void> logout(BuildContext context) async {
    await SecureStorageService.deleteAllData();
    isLoggedIn.value = false;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
      (route) => false, // clears all previous routes
    );

    showSuccess("You have been successfully logged out");

    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      debugPrint("🔍 Checking login status...");

      final status = await SecureStorageService.readData(CosntString.islogin);
      debugPrint("📊 Login status from storage: '$status'");

      final currentRoute = Get.currentRoute;
      debugPrint("📍 Current route: $currentRoute");

      final bool shouldNavigateToMain =
          status == "true" && currentRoute != '/main';
      final bool shouldNavigateToAuth =
          status != "true" && currentRoute != '/auth';

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
        debugPrint(
          "📌 Already on correct screen, status updated to: ${isLoggedIn.value}",
        );
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
