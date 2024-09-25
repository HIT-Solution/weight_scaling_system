import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_controller.dart';

class EditProductScreen extends StatelessWidget {
  final int index;
  final ProductController productController = Get.find<ProductController>();

  EditProductScreen({required this.index});

  @override
  Widget build(BuildContext context) {
    // TextEditingController nameController =
    //     TextEditingController(text: productController.productNames[index]);
    TextEditingController minWeightController = TextEditingController(
        text: productController.minWeights[index].toString());

    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Display current image and provide option to change
            Obx(() {
              return GestureDetector(
                onTap: () => productController.pickImage(index),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: productController.productImages[index]
                          .contains('assets/')
                      ? AssetImage(productController.productImages[index])
                      : FileImage(File(productController.productImages[index]))
                          as ImageProvider,
                ),
              );
            }),
            const SizedBox(height: 20),

            // Product name input
            // TextField(
            //   controller: nameController,
            //   decoration: InputDecoration(labelText: 'Product Name'),
            // ),
            Text(productController.productNames[index]),
            const SizedBox(height: 20),
            TextField(
              controller: minWeightController,
              decoration: InputDecoration(labelText: 'Minimum Weight'),
            ),
            const SizedBox(height: 20),
            // Save Button
            ElevatedButton(
              onPressed: () {
                final double? newWeight =
                    double.tryParse(minWeightController.text);

                productController.saveProduct(
                  index,
                  // nameController.text,
                  productController.productImages[index],
                  newWeight ?? productController.minWeights[index],
                );
                Get.back(); // Go back to the previous screen
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
