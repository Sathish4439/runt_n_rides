import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:get/get.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/gsheet_services.dart';
import 'package:rutsnrides_admin/core/theme/app_theme.dart';
import 'package:rutsnrides_admin/feature/auth/view/auth_screen.dart';
import 'package:rutsnrides_admin/feature/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Google Sheets Service with credentials
    final googleSheetsService = GoogleSheetsService();
    await googleSheetsService.initializeCredentials();
    
    print('✅ Google Sheets credentials loaded successfully');
    
    // Register with GetX for dependency injection
    Get.put<GoogleSheetsService>(googleSheetsService);

  } catch (e, st) {
    print('❌ Failed to initialize Google Sheets credentials: $e');
    print(st);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: AuthScreen(),
    );
  }
}