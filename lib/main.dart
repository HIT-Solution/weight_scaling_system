import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weight_scale/product_controller.dart';
import 'package:weight_scale/product_screen.dart';

void main() {
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
  // Controller to manage product data and BLE status
  final ProductController productController = Get.put(ProductController());

  // BLE state and UUIDs
  BleState bleState = BleState.initial;
  final String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUIDRx = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String characteristicUUIDTx = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  ProductModel? productData;

  @override
  void initState() {
    super.initState();
    requestPermissions(); // Request necessary permissions and start scanning
  }

  // Start scanning for BLE devices
  void startScan() async {
    print("Starting BLE scan...");
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        print('Device found: ${result.device.advName}, RSSI: ${result.rssi}');
        if (result.device.advName == 'weight_scale') {
          stopScan();
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  // Stop scanning for BLE devices
  void stopScan() {
    FlutterBluePlus.stopScan();
    setState(() {
      bleState = BleState.connecting;
    });
  }

  // Connect to the selected BLE device
  void connectToDevice(BluetoothDevice device) async {
    setState(() {
      bleState = BleState.connecting;
    });
    await device.disconnect(); // Ensure any previous connections are cleared
    await device.connect(); // Connect to the device
    setState(() {
      bleState = BleState.connected;
    });
    print("Device connected");
    discoverServices(device); // Discover services after connection
  }

  // Discover services and characteristics of the connected device
  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUIDTx) {
            characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) {
              // Handle received data and update UI
              String jsonString = String.fromCharCodes(value);
              setState(() {
                productData = ProductModel.fromString(jsonString);
                if (productData != null) {
                  productController.isBLEConnected.value = true;
                  productController.productNames.value = [
                    productData!.name1,
                    productData!.name2,
                    productData!.name3,
                    productData!.name4,
                  ];
                  productController.productCurrentWeights.value = [
                    productData!.qty1,
                    productData!.qty2,
                    productData!.qty3,
                    productData!.qty4,
                  ];
                }
              });
              print("Data received: $jsonString");
            }).onError((error) {
              setState(() {
                bleState = BleState.initial;
              });
              print("Error: $error");
            });
          }
        }
      }
    }
  }

  // Request necessary permissions for BLE and location
  Future<void> requestPermissions() async {
    try {
      print("Requesting permissions...");
      await Permission.bluetooth.request();
      await Permission.location.request();
      startScan(); // Start scanning after permissions are granted
    } catch (e) {
      setState(() {
        bleState = BleState.initial;
      });
      print("Error requesting permissions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String stateMessage = bleState == BleState.connected
        ? "Weight Scale Connected"
        : bleState == BleState.connecting
            ? "Connecting to Weight Scale..."
            : bleState == BleState.scanning
                ? "Scanning for Weight Scale..."
                : "Tap the Scan button to start.";

    return Scaffold(
      backgroundColor: Colors.white,
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
                          stateMessage,
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
                      onPressed: bleState == BleState.scanning
                          ? null
                          : requestPermissions,
                      style: ElevatedButton.styleFrom(
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
                    // ElevatedButton(
                    //   onPressed: () {
                    //     productController.sendLowWeightEmail([
                    //       Product(
                    //           index: 0,
                    //           productName: "Apple",
                    //           productImageAsset: "",
                    //           minWeight: 20,
                    //           currentWeight: 30)
                    //     ]);
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 20, vertical: 12),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   child: const Text(
                    //     "Send email test",
                    //     style: TextStyle(
                    //       fontSize: 16,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const Expanded(
                child: ProductScreen(), // Display the product list
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductModel {
  final String name1;
  final String name2;
  final String name3;
  final String name4;
  final double qty1;
  final double qty2;
  final double qty3;
  final double qty4;

  ProductModel({
    required this.name1,
    required this.qty1,
    required this.name2,
    required this.qty2,
    required this.name3,
    required this.qty3,
    required this.name4,
    required this.qty4,
  });

  // New method to parse from a single string
  factory ProductModel.fromString(String productString) {
    List<String> productList = productString.split(',');
    if (productList.length != 8) {
      throw const FormatException("Invalid product string format.");
    }
    return ProductModel(
      name1: productList[0],
      qty1: double.tryParse(productList[1]) ?? 0.0,
      name2: productList[2],
      qty2: double.tryParse(productList[3]) ?? 0.0,
      name3: productList[4],
      qty3: double.tryParse(productList[5]) ?? 0.0,
      name4: productList[6],
      qty4: double.tryParse(productList[7]) ?? 0.0,
    );
  }
}
