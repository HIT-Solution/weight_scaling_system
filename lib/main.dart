import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale_v2/auth_controller.dart';
import 'package:weight_scale_v2/home_page.dart';
import 'package:weight_scale_v2/login_page.dart';
import 'package:weight_scale_v2/product_controller.dart';
import 'package:weight_scale_v2/product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
       GetMaterialApp(debugShowCheckedModeBanner: false, home: LandingPage()));
}



class LandingPage extends StatelessWidget {
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_authController.user != null) {
        return HomePage();  // Assuming you have a HomePage widget
      } else {
        return LoginPage();
      }
    });
  }
}
