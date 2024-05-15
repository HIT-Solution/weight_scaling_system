import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weight_scale/home_screen.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isScanning = false;
  bool isConnected = false;

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
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
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
      isScanning = false;
    });
  }

  connectToDevice(BluetoothDevice device) async {
    await device.disconnect();
    await device.connect();
    isConnected = true;
    setState(() {});
    print("Device connected");
    discoverServices(device);
  }

  Product? productData;

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
                productData = Product.fromJson(jsonDecode(jsonString));
              });
              print("Received: $jsonString");
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
      print("error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String state = isConnected
        ? "Weight Scale Connected"
        : isScanning
            ? "Weight Scale Scanning..."
            : "Weight Scale Connecting...";
    return Scaffold(
      backgroundColor: const Color(0xFFE1C8C8),
      appBar: AppBar(
        title: const Text("Weight Scale"),
        backgroundColor: const Color(0xFFE1C8C8),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ProductScreen(
                  potatoWeight: productData?.potato ?? "__",
                  onionWeight: productData?.onion ?? "__",
                  riceWeight: productData?.rice ?? "__",
                  saltWeight: productData?.salt ?? "__",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: isScanning ? null : requestPermissions,
                      child: const Text("Scan"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Text(state)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final String potato;
  final String onion;
  final String rice;
  final String salt;

  Product(
      {required this.potato,
      required this.onion,
      required this.rice,
      required this.salt});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      potato: json['potato'].toString(),
      onion: json['onion'].toString(),
      rice: json['rice'].toString(),
      salt: json['salt'].toString(),
    );
  }
}
