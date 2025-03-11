import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale_v2/edit_product_screen.dart';
import 'package:weight_scale_v2/product_controller.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();

    productController.loadProducts();
    productController.checkLowWeightProducts(context);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  // sa

  @override
  Widget build(BuildContext context) {
    // _checkLowWeightProducts();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        return GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          crossAxisCount: 2,
          childAspectRatio: .62,
          children: List.generate(4, (index) {
            return GestureDetector(
                onTap: () {
                  // Open editing options for the product
                  Get.to(() => EditProductScreen(index: index));
                },
                child: ProductBox(
                  product: Product(
                    index: index,
                    productName: productController.productNames[index],
                    productImageAsset: productController.productImages[index],
                    minWeight: productController.minWeights[index],
                    currentWeight:
                        productController.productCurrentWeights[index],
                  ),
                  // onMinWeightChanged: (newWeight) {
                  //   productController.saveMinWeight(index, newWeight);
                  // },
                ));
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
