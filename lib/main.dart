import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RUTSNRIDES/core/dependancy_injection.dart/depandancey_injection.dart';
import 'package:RUTSNRIDES/core/theme/app_theme.dart';
import 'package:RUTSNRIDES/feature/auth/view/auth_screen.dart';
import 'package:RUTSNRIDES/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DependencyInjection.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
