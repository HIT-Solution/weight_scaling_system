import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'device_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rxn<User> _firebaseUser = Rxn<User>();

  User? get user => _firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.authStateChanges());
  }

  var isLoading = false.obs;

  Future<void> createUser(String email, String password, BuildContext context) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Success", "Account created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      Navigator.pop(context); // still okay here
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      if (Get.isRegistered<DeviceController>()) {

      }


      final response = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      Get.find<DeviceController>().listenToScalesAndBuildProductList();

      print(response.user?.email);
      print(response.user?.uid);
      print(response.user?.displayName);



      // ❌ DO NOT manually navigate here
      // Get.offAll(() => HomePage()); <-- REMOVE THIS LINE

    } catch (e) {
      Get.snackbar("Error signing in", e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    print("✅ Signed out successfully");

    // 🔄 Clear user-specific data from DeviceController only
    if (Get.isRegistered<DeviceController>()) {
      Get.find<DeviceController>().clearData();
    }

    // ✅ Feedback to user
    Get.snackbar("Signed Out", "You have been logged out.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[900],
        colorText: Colors.white);
  }



}
