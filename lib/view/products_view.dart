import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale_v2/view/edit_product_screen.dart';
import 'package:weight_scale_v2/controller/product_controller.dart';
import '../controller/device_controller.dart';
import '../model/product_model.dart';
import '../model/product_with_weight_model.dart';
import '../model/scale_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final DeviceController deviceController = Get.put(DeviceController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Obx(() {
        final query = deviceController.searchQuery.value.toLowerCase();

        final filteredProducts = deviceController.productList.where((product) {
          return product.name.toLowerCase().contains(query);
        }).toList();

        if (filteredProducts.isEmpty) {
          return const Center(child: Text("No matching products found"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: filteredProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final product = filteredProducts[index];


            return GestureDetector(
                onTap: () {
                  final product = filteredProducts[index];
                  final nameController = TextEditingController(text: product.name);
                  final minController = TextEditingController(text: product.minimumWeight.toString());
                  final selectedDate = DateTime.tryParse(product.expiredDate) ?? DateTime.now();
                  final referenceId = 'Ref-${product.rfidTag}';


                  Get.to(() => EditProductScreen(
                    index: index
                  ));
                },

                child: ProductBox(product: product),
            );
          },
        );
      }),
    );
  }
}

class ProductBox extends StatelessWidget {
  const ProductBox({super.key, required this.product});

  final ProductWithWeight product;

  @override
  Widget build(BuildContext context) {
    final DatabaseReference productRef = FirebaseDatabase.instance
        .ref()
        .child('products')
        .child(product.rfidTag);

    return StreamBuilder<DatabaseEvent>(
      stream: productRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading product"));
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text("Product not found"));
        }

        try {
          final productData = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final String updatedExpiredDate = productData['expiredDate'] ?? '';
          final DateTime now = DateTime.now();
          final DateTime? expireDate = DateTime.tryParse(updatedExpiredDate.trim());
          final bool isExpired = expireDate != null && now.isAfter(expireDate);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
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
                      child: SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Image(
                          image: _buildImageProvider(productData['picture'] ?? ''),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
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
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    product.name,
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
                    'Current Weight : ${product.currentWeight}kg',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Text(
                    'Expire Date: $updatedExpiredDate',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          return Center(child: Text("Parsing error: $e"));
        }
      },
    );
  }

  ImageProvider _buildImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.contains('assets/')) {
      return AssetImage(path);
    } else if (File(path).existsSync()) {
      return FileImage(File(path));
    } else {
      return const AssetImage('assets/product.png');
    }
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