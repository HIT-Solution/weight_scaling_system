import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weight_scale/product_screen.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ProductController extends GetxController {
  // Email credentials for sending notifications
  String fromUsername = 'weightscale436@gmail.com';
  String password = 'xahu mvst mdkn pfsf'; // App-specific password for Gmail
  String toUsername = 'hasansit48@gmail.com';

  // Observable lists for managing product data
  var productNames = ['Product 1', 'Product 2', 'Product 3', 'Product 4'].obs;
  var productImages = [
    'assets/product.png',
    'assets/product.png',
    'assets/product.png',
    'assets/product.png',
  ].obs;
  var minWeights = [1.0, 1.0, 1.0, 1.0].obs; // Minimum weight thresholds
  var productCurrentWeights =
      [0.0, 0.0, 0.0, 0.0].obs; // Current weights of products
  var isBLEConnected = false.obs; // BLE connection status

  final ImagePicker _picker = ImagePicker(); // Image picker instance
  var previousLowWeightCount =
      0.obs; // Tracks the number of low-weight products

  // Load product data from SharedPreferences (persistent storage)
  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < productNames.length; i++) {
      productImages[i] = prefs.getString('productImage_$i') ?? productImages[i];
      minWeights[i] = prefs.getDouble('minWeight_$i') ?? minWeights[i];
    }
  }

  // Monitor and check for products with low weight
  void checkLowWeightProducts(BuildContext context) async {
    await Future.delayed(
        Duration(seconds: 2)); // Initial delay for BLE connection check

    if (!isBLEConnected.value) {
      // Retry if BLE is not connected
      checkLowWeightProducts(context);
      return;
    }

    // Create a list of products with current data
    final List<Product> products = [];
    for (int i = 0; i < 4; i++) {
      products.add(Product(
        index: i,
        productName: productImages[i],
        productImageAsset: productImages[i],
        minWeight: minWeights[i],
        currentWeight: productCurrentWeights[i],
      ));
    }

    // Filter products that have low weight
    final lowWeightProducts =
        products.where((product) => product.hasLowWeight()).toList();
    final lowWeightCount = lowWeightProducts.length;

    if (lowWeightCount > 0 && lowWeightCount != previousLowWeightCount.value) {
      // Update and notify if the low-weight count changes
      previousLowWeightCount.value = lowWeightCount;
      sendLowWeightEmail(lowWeightProducts); // Send email notification
    }

    if (lowWeightProducts.isNotEmpty && !isShowingLowWeightDialog.value) {
      // Show alert dialog for low-weight products
      await _showLowWeightDialog(lowWeightProducts, context);
    }

    // Recheck after a delay
    await Future.delayed(Duration(seconds: 10));
    checkLowWeightProducts(context);
  }

  var isShowingLowWeightDialog = false.obs; // Tracks if the dialog is visible

  // Show dialog listing low-weight products
  Future<void> _showLowWeightDialog(
      List<Product> lowWeightProducts, BuildContext context) async {
    isShowingLowWeightDialog.value = true;

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) => AlertDialog(
        title: const Text(
          'Low Weight Products',
          style: TextStyle(color: Colors.red),
        ),
        content: Container(
          height: 200,
          child: ListView.builder(
            shrinkWrap: true, // Optimize height usage
            itemCount: lowWeightProducts.length,
            itemBuilder: (context, index) {
              final product = lowWeightProducts[index];
              return Text(
                '- ${productNames[product.index]} (Current weight: ${product.currentWeight} Kg, Min weight: ${product.minWeight} Kg)',
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    isShowingLowWeightDialog.value = false;
  }

  // Save product details to SharedPreferences
  Future<void> saveProduct(
      int index, String imagePath, double minWeight) async {
    final prefs = await SharedPreferences.getInstance();
    productImages[index] = imagePath;
    minWeights[index] = formatDoubleToTwoDecimals(minWeight);
    await prefs.setString('productImage_$index', imagePath);
    await prefs.setDouble('minWeight_$index', minWeight);
  }

  // Send email notification for low-weight products
  Future<void> sendLowWeightEmail(List<Product> lowWeightProducts) async {
    final smtpServer = gmail(fromUsername, password); // Gmail SMTP server
    final message = Message()
      ..from = Address(fromUsername, 'Weight Scale')
      ..recipients.add(toUsername)
      ..subject = 'Low Weight Products Detected'
      ..html =
          "<h1>Low Weight Alert</h1><p>The following products are below the minimum weight:<br>"
              "${lowWeightProducts.map((product) => '${productNames[product.index]}: Current weight ${product.currentWeight} Kg, Min weight ${product.minWeight} Kg.').join('<br>')}</p>";

    try {
      await send(message, smtpServer); // Attempt to send the email
    } on MailerException catch (e) {
      print('Error sending email: ${e.message}');
    }
  }

  // Format a double value to two decimal places
  double formatDoubleToTwoDecimals(double number) {
    return double.parse(number.toStringAsFixed(2));
  }

  // Pick an image from the gallery and save it
  Future<void> pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      saveProduct(index, pickedFile.path, minWeights[index]);
    }
  }
}
