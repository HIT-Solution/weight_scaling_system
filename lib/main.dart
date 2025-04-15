import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale_v2/controller/auth_controller.dart';
import 'package:weight_scale_v2/view/home_page.dart';
import 'package:weight_scale_v2/view/login_page.dart';
import 'package:weight_scale_v2/controller/product_controller.dart';
import 'package:weight_scale_v2/view/products_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      // primarySwatch: Colors.blue,
      // colorScheme: ColorScheme.fromSwatch(
      //   primarySwatch: Colors.blue,
      // ).copyWith(
      //   secondary: Colors.blueAccent,
      // ),
      // scaffoldBackgroundColor: Colors.grey[100], // Light background color

      // textTheme: const TextTheme(
      //   bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      //   bodyMedium: TextStyle(fontSize: 16),
      // ),
      // inputDecorationTheme: InputDecorationTheme(
      //   filled: true,
      //   fillColor: Colors.white,
      //   contentPadding:
      //       const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      //   enabledBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      //   ),
      //   focusedBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      //   ),
      //   errorBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: const BorderSide(color: Colors.red, width: 1.5),
      //   ),
      //   focusedErrorBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      //   ),
      // ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    home: LandingPage(),
  ));
}

class LandingPage extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_authController.user != null) {
        return HomePage(); // Assuming you have a HomePage widget
      } else {
        return LoginPage();
      }
    });
  }
}
