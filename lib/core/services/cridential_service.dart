import 'dart:convert';
import 'package:flutter/services.dart';

class CredentialsService {
  static final CredentialsService _instance = CredentialsService._internal();
  factory CredentialsService() => _instance;
  CredentialsService._internal();

  Map<String, dynamic>? _credentials;

  Future<Map<String, dynamic>> getCredentials() async {
    if (_credentials != null) return _credentials!;

    try {
      final String response = await rootBundle.loadString(
        'assets/google_credentials.json',
      );
      _credentials = jsonDecode(response);
      return _credentials!;
    } catch (e) {
      print('Error loading Google credentials: $e');
      throw Exception('Failed to load Google credentials');
    }
  }
}
