import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale_v2/view/edit_product_screen.dart';
import 'package:weight_scale_v2/controller/product_controller.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Obx(() {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: productController.productNames.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Get.to(() => EditProductScreen(index: index));
              },
              child: ProductBox(
                product: Product(
                  index: index,
                  productName: productController.productNames[index],
                  productImageAsset: productController.productImages[index],
                  minWeight: productController.minWeights[index],
                  currentWeight: productController.productCurrentWeights[index],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class ProductBox extends StatelessWidget {
  const ProductBox({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final bool isExpired = product.hasLowWeight();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  child: product.productImageAsset.contains('assets/')
                      ? Image.asset(product.productImageAsset, fit: BoxFit.cover)
                      : Image.file(File(product.productImageAsset), fit: BoxFit.cover),
                ),
              ),
              if (isExpired)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: const Text(
                      'Expired',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              product.productName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Text(
              'Current Weight : ${product.currentWeight}gm',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
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
  double minWeight;
  final double currentWeight;

  bool hasLowWeight() => currentWeight < minWeight;
}
