import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale_v2/product_controller.dart';
import 'package:weight_scale_v2/product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(
      const GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

enum BleState { initial, scanning, connecting, connected, disconnected }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // bool isScanning = false;
  // bool isConnected = false;
  final ProductController productController = Get.put(ProductController());

  BleState bleState = BleState.initial;
  // UUIDs
  final String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUIDRx = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String characteristicUUIDTx = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  // BluetoothDevice? connectedDevice;
  // List<BluetoothService> services = [];

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
      //  resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Weight Scale"),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width: 16), // Spacing between text and button
                    ElevatedButton(
                      onPressed: bleState == BleState.scanning ? null : null,
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.bl, // Soft red button color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Scan",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ProductScreen(),
              ),
            ],
          ),
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
