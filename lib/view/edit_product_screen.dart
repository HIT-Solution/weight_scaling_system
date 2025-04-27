import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:weight_scale_v2/controller/device_controller.dart';
import '../model/card_row.dart';
import '../model/image_picker_button.dart';

class EditProductScreen extends StatefulWidget {
  final int index;

  const EditProductScreen({super.key, required this.index});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final productController = Get.find<DeviceController>();
  final RxBool isLoading = false.obs;
  late TextEditingController nameController;
  late TextEditingController minQuantityController;
  late DateTime selectedDate;
  late String referenceId;
  @override
  void initState() {
    super.initState();
    final product = productController.productList[widget.index];
    nameController = TextEditingController(text: product.name);
    minQuantityController = TextEditingController(text: product.minimumWeight.toString());






    final rawDate = product.expiredDate.trim();
    print("expire date from db (raw): $rawDate");

    try {
      selectedDate = DateTime.parse(rawDate);
    } catch (e) {
      print("⚠️ Failed to parse date, using DateTime.now()");
      selectedDate = DateTime.now();
    }

    print("Parsed expire date: $selectedDate");

    referenceId = 'Ref-${product.rfidTag}';
  }

  String formatDate(DateTime date) {
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${date.day} ${monthNames[date.month]}, ${date.year}';
  }

  Future<String> uploadImageToFirebase(String path, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images')
        .child('$fileName-${DateTime.now().millisecondsSinceEpoch}.jpg');

    final uploadTask = await ref.putFile(File(path));
    return await uploadTask.ref.getDownloadURL();
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ImagePickerButton(
                      icon: Icons.photo_library,
                      label: 'Upload',
                      onTap: () async {
                        Navigator.pop(context);
                        final pickedFile = await productController.picker
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          isLoading.value = true;
                          final firebaseUrl = await uploadImageToFirebase(
                              pickedFile.path, nameController.text);
                          await productController.updateProductImage(
                              widget.index, firebaseUrl);
                          isLoading.value = false;
                        }
                      },
                    ),
                    ImagePickerButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final pickedFile = await productController.picker
                            .pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          isLoading.value = true;
                          final firebaseUrl = await uploadImageToFirebase(
                              pickedFile.path, nameController.text);
                          await productController.updateProductImage(
                              widget.index, firebaseUrl);
                          isLoading.value = false;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose a method to update your product image',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final product = productController.productList[widget.index];
      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              // title: const Text(
              //   'Edit Product',
              //   style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              // ),
              // centerTitle: true,
            ),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: product.picture.startsWith('http')
                              ? NetworkImage(product.picture)
                              : const AssetImage('assets/product.png')
                                  as ImageProvider,
                        ),
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: GestureDetector(
                            onTap: () => _showImagePickerOptions(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Icon(Icons.edit, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: nameController,
                            onChanged: (val) => productController
                                .updateProductName(widget.index, val),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit, size: 18),
                      ],
                    ),
                    Text(referenceId,
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 32),
                    CardRow(
                      icon: Icons.calendar_month,
                      title: "Expiry Date",
                      value: formatDate(selectedDate),
                      onEdit: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null && picked != selectedDate) {
                          selectedDate = picked;
                          await productController.updateProductExpiryDate(
                              widget.index, picked.toIso8601String());
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CardRow(
                      icon: Icons.shopping_cart,
                      title: "Minimum Quantity",
                      value: '${minQuantityController.text} kg',
                      onEdit: () async {
                        final TextEditingController tempController =
                            TextEditingController(
                                text: minQuantityController.text);
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Edit Minimum Quantity"),
                            content: TextField(
                              controller: tempController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "Enter minimum weight (kg)",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  minQuantityController.text =
                                      tempController.text;
                                  final weight =
                                      double.tryParse(tempController.text) ??
                                          0.0;
                                  await productController
                                      .updateProductMinimumWeight(
                                          widget.index, weight);
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                  ],
                ),
              ),
            ),
          ),
          if (isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      );
    });
  }
}
