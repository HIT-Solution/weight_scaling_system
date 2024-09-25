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
  // bool isScanning = false;
  // bool isConnected = false;
  final ProductController productController = Get.put(ProductController());

  BleState bleState = BleState.initial;
  // UUIDs
  final String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUIDRx = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String characteristicUUIDTx = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  startScan() async {
    print("startScan1 ");

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    print("startScan2 ");
    FlutterBluePlus.scanResults.listen((results) {
      print("startScan3 ");
      for (ScanResult result in results) {
        print('${result.device.advName} found! rssi: ${result.rssi}');
      }
    });
    FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.advName == 'weight_scale') {
          stopScan();
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  stopScan() {
    FlutterBluePlus.stopScan();
    setState(() {
      bleState = BleState.connecting;
    });
  }

  connectToDevice(BluetoothDevice device) async {
    setState(() {
      bleState = BleState.connecting;
    });
    await device.disconnect();
    await device.connect();
    setState(() {
      bleState = BleState.connected;
    });
    print("Device connected");
    discoverServices(device);
  }

  ProductModel? productData;

  discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUIDTx) {
            characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) {
              // Handle the received data
              // Decode JSON and update UI
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
              print("Received: $jsonString");
            }).onError((handleError) {
              setState(() {
                bleState = BleState.initial;
              });
              print("handleError: ${handleError}");
            });
          }
        }
      }
    }
  }

  Future<void> requestPermissions() async {
    try {
      print("run 2");
      await Permission.bluetooth.request();
      await Permission.location.request();
      print("run 3");
      startScan();
    } on Exception catch (e) {
      setState(() {
        bleState = BleState.initial;
      });
      print("requestPermissions: ${e.toString()}");
      print("error $e");
    }
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
                      onPressed: bleState == BleState.scanning
                          ? null
                          : requestPermissions,
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

  // factory ProductModel.fromJson(Map<String, dynamic> json) {
  //   return ProductModel(
  //     name1: json['name1'].toString(),
  //     qty1: double.tryParse(json['qty1'].toString()) ?? 0.0,
  //     name2: json['name2'].toString(),
  //     qty2: double.tryParse(json['qty2'].toString()) ?? 0.0,
  //     name3: json['name3'].toString(),
  //     qty3: double.tryParse(json['qty3'].toString()) ?? 0.0,
  //     name4: json['name4'].toString(),
  //     qty4: double.tryParse(json['qty4'].toString()) ?? 0.0,
  //   );
  // }

  // New method to parse from a single string
  factory ProductModel.fromString(String productString) {
    List<String> productList = productString.split(',');
    if (productList.length != 8) {
      throw FormatException("Invalid product string format.");
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
