import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/home_page.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rxn<User> _firebaseUser = Rxn<User>();

  User? get user => _firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.authStateChanges());
  }

  var isLoading = false.obs;

  Future<void> createUser(
      String email, String password, BuildContext context) async {
    try {
      isLoading.value = true;
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar("Success", "Account created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      Navigator.pop(context);
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

      final response = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      print(response.user?.email);
      print(response.user?.uid);
      print(response.user?.displayName);

      // ✅ After successful login, move to HomePage
      Get.offAll(() => HomePage()); // <-- Add this line

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error signing in", e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }
}
