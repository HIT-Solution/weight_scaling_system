import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale/edit_product_screen.dart';
import 'package:weight_scale/product_controller.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // Initialize the ProductController to manage product data and actions
  final ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();

    // Load product details from storage and start monitoring for low-weight products
    productController.loadProducts();
    productController.checkLowWeightProducts(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16), // Add padding around the grid
      child: Obx(() {
        // Observe changes in product data and rebuild the UI accordingly
        return GridView.count(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 16), // Grid padding
          mainAxisSpacing: 10, // Space between rows
          crossAxisSpacing: 10, // Space between columns
          crossAxisCount: 2, // Two items per row
          childAspectRatio: .62, // Aspect ratio of each grid item
          children: List.generate(4, (index) {
            return GestureDetector(
              onTap: () {
                // Navigate to the EditProductScreen to edit the selected product
                Get.to(() => EditProductScreen(index: index));
              },
              child: ProductBox(
                product: Product(
                  index: index,
                  productName:
                      productController.productNames[index], // Product name
                  productImageAsset:
                      productController.productImages[index], // Product image
                  minWeight: productController
                      .minWeights[index], // Minimum weight threshold
                  currentWeight: productController
                      .productCurrentWeights[index], // Current weight
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

class ProductBox extends StatelessWidget {
  const ProductBox({
    super.key,
    required this.product,
    // required this.onMinWeightChanged,
    // required this.controller
  });

  final Product product;
  // final Function(double) onMinWeightChanged;
  // final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.45;

    return Container(
      padding: const EdgeInsets.all(16),
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 4,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image.asset(
          //   product.productImageAsset,
          //   height: 100,
          // ),
          product.productImageAsset.contains('assets/')
              ? Image.asset(product.productImageAsset, height: 100)
              : Image.file(File(product.productImageAsset), height: 100),
          const SizedBox(height: 4),
          Text(
            product.productName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Min Weight:\n${product.minWeight} Kg',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Current weight:\n${product.currentWeight} Kg',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  Product({
    required this.index,
    required this.productName,
    required this.productImageAsset,
    required this.minWeight,
    required this.currentWeight,
  });

  final int index;
  final String productName;
  final String productImageAsset;
  double minWeight; // Not final anymore to allow modification
  final double currentWeight;

  bool hasLowWeight() => currentWeight < minWeight;
}
