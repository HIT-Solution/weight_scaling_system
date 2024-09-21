import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weight_scale/product_screen.dart';

class ProductController extends GetxController {
  var productNames = ['Product 1', 'Product 2', 'Product 3', 'Product 4'].obs;
  var productImages = [
    'assets/product.png',
    'assets/product.png',
    'assets/product.png',
    'assets/product.png',
  ].obs;

  // Min and max weight lists
  var minWeights = [5.0, 5.0, 5.0, 5.0].obs;
  var productCurrentWeights = [0.0, 0.0, 0.0, 0.0].obs;
  var isBLEConnected = false.obs;

  final ImagePicker _picker = ImagePicker();

  // Initialize data from SharedPreferences
  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < productNames.length; i++) {
      productNames[i] = prefs.getString('productName_$i') ?? productNames[i];
      productImages[i] = prefs.getString('productImage_$i') ?? productImages[i];
      minWeights[i] = prefs.getDouble('minWeight_$i') ?? minWeights[i];
    }
  }

  void checkLowWeightProducts(BuildContext context) async {
    //if(context.mounted)
    print("1");
    //prefs = await SharedPreferences.getInstance();

    await Future.delayed(Duration(seconds: 2));
    // if (mounted) {}
    print("widget.isBLEConnected check : ${isBLEConnected.value}");
    if (!isBLEConnected.value) {
      checkLowWeightProducts(context);
      return;
    }
    final List<Product> products = [];
    for (int i = 0; i < 4; i++) {
      products.add(Product(
          index: i,
          productName: productImages[i],
          productImageAsset: productImages[i],
          minWeight: minWeights[i],
          currentWeight: productCurrentWeights[i]));
    }
    final lowWeightProducts =
        products.where((product) => product.hasLowWeight()).toList();
    print("22 ${lowWeightProducts.length}");
    print("3");
    if (lowWeightProducts.isNotEmpty && !isShowingLowWeightDialog.value) {
      print("4");
      await _showLowWeightDialog(lowWeightProducts, context);
    }
    print("5");
    await Future.delayed(
        const Duration(seconds: 10)); // Check again after 10 seconds
    print("6");
    checkLowWeightProducts(context);
  }

  var isShowingLowWeightDialog =
      false.obs; // {"product1":5,"product2":1,"product3":1,"product4":1}

  Future<void> _showLowWeightDialog(
      List<Product> lowWeightProducts, BuildContext context) async {
    // setState(() {
    isShowingLowWeightDialog.value = true;
    // });

    await showDialog(
      context: context,
      barrierDismissible: false, // Disable dismiss by tapping outside
      builder: (context) => AlertDialog(
        title: const Text(
          'Low Weight Products',
          style: TextStyle(color: Colors.red),
        ),
        content: Container(
          height: 200,
          width: 100,
          child: ListView.builder(
            shrinkWrap: true, // Prevent excessive height
            itemCount: lowWeightProducts.length,
            itemBuilder: (context, index) {
              final product = lowWeightProducts[index];
              return Text(
                '- ${productNames[index]} (Current weight: ${product.currentWeight} Kg, Min weight: ${product.minWeight} Kg)',
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // setState(() {
              // });
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
    isShowingLowWeightDialog.value = false;
  }

  Future<void> saveProduct(
      int index, String name, String imagePath, double minWeight) async {
    final prefs = await SharedPreferences.getInstance();
    productNames[index] = name;
    productImages[index] = imagePath;
    minWeights[index] = formatDoubleToTwoDecimals(minWeight);
    await prefs.setString('productName_$index', name);
    await prefs.setString('productImage_$index', imagePath);
    await prefs.setDouble('minWeight_$index', minWeight);
  }

  double formatDoubleToTwoDecimals(double number) {
    return double.parse(number.toStringAsFixed(3));
  }

  // Pick an image from the gallery
  Future<void> pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      saveProduct(
          index, productNames[index], pickedFile.path, minWeights[index]);
    }
  }
}
