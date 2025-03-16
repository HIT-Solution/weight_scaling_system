import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale_v2/controller/product_controller.dart';
import 'package:weight_scale_v2/view/product_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weight_scale_v2/controller/product_controller.dart';
import 'package:weight_scale_v2/view/product_screen.dart';

enum BleState { initial, scanning, connecting, connected, disconnected }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController productController = Get.put(ProductController());
  BleState bleState = BleState.initial;
  final User? user = FirebaseAuth.instance.currentUser;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // Get.offAllNamed('/login'); // Navigate to login page after logout
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Weight Scale"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              accountName: Text(user?.tenantId ?? ""),
              accountEmail: Text(user?.email ?? "Email not available"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 18),
                      child: Text(
                        state,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: bleState == BleState.scanning ? null : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Scan", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            Expanded(child: ProductScreen()),
          ],
        ),
      ),
    );
  }
}

class ProductModel {
  final String product1;
  final String product2;
  final String product3;
  final String product4;

  ProductModel(
      {required this.product1,
      required this.product2,
      required this.product3,
      required this.product4});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      product1: json['product1'].toString(),
      product2: json['product2'].toString(),
      product3: json['product3'].toString(),
      product4: json['product4'].toString(),
    );
  }
}
