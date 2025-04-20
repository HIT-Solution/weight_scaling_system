import 'dart:convert';
import 'dart:async'; // For TimeoutException
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NetworkUtils {
  static const String espUrl = "http://192.168.4.1/connect"; // ESP AP endpoint

  static Future<void> sendCredentials(
      {required String ssid,
        required String password,
        required String userId,
      }
        // required String locationId,
        // required String deviceName
  ) async {
    try {
      final response = await http
          .post(
        Uri.parse(espUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ssid': ssid,
          'password': password,
          'userId': userId
          // 'locationId': locationId,
          // 'deviceName': deviceName,
        }),
      )
          .timeout(const Duration(seconds: 10)); // 10-second timeout
      print("response : ${response.body}");
      showSnackbar(
        title: "Success",
        message: "Credentials were successfully sent to your Weight Scale.",
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
      );
    } on TimeoutException {
      showPopup(
          title: "Connection Failed",
          message:
          "Unable to connect to your Weight Scale device. Please connect to your Weight Scale device via Wi-Fi.",
          icon: Icons.wifi_off);
      print("Please connect to your Weight Scale device via Wi-Fi.");
      throw Exception();
    } catch (e) {
      print("Error: $e");
      // showPopup(
      //     title: "Error",
      //     message: "An unexpected error occurred. Please try again.",
      //     icon: Icons.error_outline);
      // throw Exception(e);
    }
  }

  // Pop-up dialog notification
  static void showPopup({
    required String title,
    required String message,
    IconData? icon,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            if (icon != null) Icon(icon, size: 28, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  static void showSnackbar({
    required String title,
    required String message,
    IconData? icon,
    Color iconColor = Colors.white,
  }) {
    Get.snackbar(
      title,
      message,
      icon: icon != null ? Icon(icon, color: iconColor, size: 28) : null,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[900],
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
