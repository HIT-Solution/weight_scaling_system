import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weight_scale_v2/view/product_screen.dart';

class ProductController extends GetxController {
  var productNames = <String>['Product 1', 'Product 2', 'Product 3', 'Product 4'].obs;

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
  var previousLowWeightCount =
      0.obs; // To track the number of low-weight products

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
    final lowWeightCount = lowWeightProducts.length;

    // Check if the low-weight count has changed and is greater than 0
    if (lowWeightCount > 0 && lowWeightCount != previousLowWeightCount.value) {
      // Update the previous low-weight count
      previousLowWeightCount.value = lowWeightCount;

      // Send email notification
      //  sendLowWeightEmail(lowWeightProducts);
    }

    // If the count is 0, just update the previous count and do nothing else
    if (lowWeightCount == 0) {
      previousLowWeightCount.value = lowWeightCount;
    }

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
                '- ${productNames[product.index]} (Current weight: ${product.currentWeight} Kg, Min weight: ${product.minWeight} Kg)',
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

  // Function to send an email
  // Future<void> sendLowWeightEmail(List<Product> lowWeightProducts) async {
  //   print("sendLowWeightEmail 1");
  //   // String username = 'weightscale436@gmail.com';
  //   String username = 'weightscale436@gmail.com';
  //   print("sendLowWeightEmail 2");
  //   String password = 'aget yors iieo vbal';
  //   // String password = 'w@123456#';
  //   print("sendLowWeightEmail 3");
  //   final smtpServer = gmail(username, password);
  //   print("sendLowWeightEmail 4");
  //   // Use the SmtpServer class to configure an SMTP server:
  //   // final smtpServer = SmtpServer('smtp.domain.com');
  //   // See the named arguments of SmtpServer for further configuration
  //   // options.

  //   // Create our message.
  //   final message = Message()
  //     ..from = Address(username, 'Weight Scale')
  //     //    ..recipients.add('kazisakib556@gmail.com')
  //     ..recipients.add('hasansit48@gmail.com')
  //     ..subject = 'Low Weight Products Detected'
  //     ..text =
  //         'This is a plain text version of the email. Please view in an HTML-compatible viewer.'
  //     ..html = "<h1>Hey!</h1><p>The following products have low weights:<br>"
  //         "${lowWeightProducts.map((product) => '${productNames[product.index]}: Current weight ${product.currentWeight} Kg, Min weight ${product.minWeight} Kg.').join('<br>')}</p>";

  //   print("sendLowWeightEmail 6");
  //   try {
  //     final sendReport = await send(message, smtpServer);
  //     print("sendLowWeightEmail 7");
  //     print('Message sent: ' + sendReport.toString());
  //     print("sendLowWeightEmail 8");
  //   } on MailerException catch (e) {
  //     print("sendLowWeightEmail 9");
  //     print('Message not sent. ${e}');
  //     print('Message not sent. ${e.message}');
  //     for (var p in e.problems) {
  //       print('Problem: ${p.code}: ${p.msg}');
  //       print("sendLowWeightEmail 10");
  //     }
  //   }
  //   print("sendLowWeightEmail 101111");
  // }

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
