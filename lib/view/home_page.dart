import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale_v2/controller/device_controller.dart';
import 'package:weight_scale_v2/controller/product_controller.dart';
import 'package:weight_scale_v2/view/products_view.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weight_scale_v2/controller/product_controller.dart';
import 'package:weight_scale_v2/view/products_view.dart';

import 'network_password_screen.dart';

enum BleState { initial, scanning, connecting, connected, disconnected }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DeviceController productController = Get.put(DeviceController());
  BleState bleState = BleState.initial;
  final User? user = FirebaseAuth.instance.currentUser;

  // final TextEditingController _dataController = TextEditingController();
  // final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("entries");

  // void _addData() {
  //   final String data = _dataController.text.trim();
  //   print('1');
  //   if (data.isNotEmpty) {
  //     print('2');
  //     // Push data with unique ID
  //     _dbRef.push().set({"value": data}).then((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Added")));
  //       print('3');
  //       _dataController.clear();
  //     }).catchError((error) {
  //       print('4');
  //       print(error);
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $error")));
  //     });
  //   }
  // }

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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>   NetworkPasswordScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // You can change color
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
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
            // Top Blue Section
            Container(
              color: Colors.blue.shade300,
              padding: const EdgeInsets.symmetric(vertical: 40),
              width: double.infinity,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.pinkAccent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.tenantId ?? "Tenant Name",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "Email not available",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),

            // White Section with Actions
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Logout",
                          style: TextStyle(color: Colors.red)),
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
                      onChanged: (value) => productController.searchQuery.value = value,
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
                    onPressed: () {
                      // Implement the action that should be taken on button press
                      // searchController.filterData(searchController.searchQuery.value);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 16),
                      backgroundColor:
                          Color(0xFF0079D8), // Set the background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Search",
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              Colors.white), // Optional: ensure text is visible
                    ),
                  ),

                  /*
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



                   */
                ],
              ),
            ),
            // TextField(
            //   controller: _dataController,
            //   decoration: InputDecoration(
            //     labelText: 'Add data',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //       borderSide: BorderSide(color: Colors.blueAccent),
            //     ),
            //     filled: true,
            //     fillColor: Colors.white,
            //   ),
            // ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _addData,
            //   child: Text("Add"),
            // ),

            Expanded(child: ProductView()),
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
