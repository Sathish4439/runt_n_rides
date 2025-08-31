import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isLoading; // ✅ new parameter

  const CommonButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    this.isLoading = false, // default false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap, // disable when loading
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.white),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                    color: textColor, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri url = Uri(scheme: 'tel', path: phoneNumber);

  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}


String formatTimestamp(String timestamp) {
  try {
    final millis = int.parse(timestamp); // convert string → int
    final dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat("dd/MM/yyyy HH:mm:ss").format(dateTime);
  } catch (e) {
    print("❌ Error formatting timestamp: $e");
    return timestamp; // fallback
  }
}
