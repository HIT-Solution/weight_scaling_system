import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controller/auth_controller.dart';
import '../controller/device_controller.dart';
import '../controller/product_controller.dart';
import '../view/products_view.dart';
import 'network_password_screen.dart';

enum BleState { initial, scanning, connecting, connected, disconnected }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DeviceController deviceController = Get.put(DeviceController());
  final AuthController authController = Get.find<AuthController>();
  BleState bleState = BleState.initial;

  @override
  void initState() {
    super.initState();

    // Delay Firebase-dependent logic until user is fully available
    Future.delayed(Duration(milliseconds: 300), () {
      if (authController.user != null) {
        // Optionally load something here
        print("User UID: ${authController.user?.uid}");
      }
    });
  }

  void _logout() async {
    await authController.signOut();
  }

  @override
  Widget build(BuildContext context) {
    String state = bleState == BleState.connected
        ? "Weight Scale Connected"
        : bleState == BleState.connecting
        ? "Weight Scale Connecting..."
        : bleState == BleState.scanning
        ? "Weight Scale Scanning..."
        : "Tap on scan button";

    return Obx(() {
      final user = authController.user;
      if (user == null) {
        return const Center(child: CircularProgressIndicator()); // Wait for auth
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Weight Scale"),
          backgroundColor: const Color(0xFFE3EAEF),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NetworkPasswordScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFE3EAEF),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, size: 28, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                color: Colors.blue.shade300,
                padding: const EdgeInsets.symmetric(vertical: 40),
                width: double.infinity,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.tenantId ?? "Tenant Name",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? "Email not available",
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text("Logout", style: TextStyle(color: Colors.red)),
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) => deviceController.searchQuery.value = value,
                        decoration: InputDecoration(
                          labelText: 'Search Products',
                          suffixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blueAccent),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                        backgroundColor: Color(0xFF0079D8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Search",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: ProductView()),
            ],
          ),
        ),
      );
    });
  }
}

class ProductModel {
  final String product1;
  final String product2;
  final String product3;
  final String product4;

  ProductModel({
    required this.product1,
    required this.product2,
    required this.product3,
    required this.product4,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      product1: json['product1'].toString(),
      product2: json['product2'].toString(),
      product3: json['product3'].toString(),
      product4: json['product4'].toString(),
    );
  }
}
