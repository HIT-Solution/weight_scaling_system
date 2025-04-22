import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/product_controller.dart';
import '../model/card_row.dart';
import '../model/image_picker_button.dart';

class EditProductScreen extends StatefulWidget {
  final int index;

  const EditProductScreen({super.key, required this.index});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductController productController = Get.find<ProductController>();

  late TextEditingController nameController;
  late TextEditingController minQuantityController;

  DateTime selectedDate = DateTime(2025, 3, 12);
  final String referenceId = "Ref-5c:2F:18:00";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: productController.productNames[widget.index],
    );
    minQuantityController = TextEditingController(
      text: productController.minWeights[widget.index].toString(),
    );
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

  Future<void> pickExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void updateProduct() {
    final weight = double.tryParse(minQuantityController.text) ??
        productController.minWeights[widget.index];
    productController.saveProduct(
      widget.index,
      nameController.text,
      productController.productImages[widget.index],
      weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Product image with edit icon
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Obx(() {
                    final path = productController.productImages[widget.index];
                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                        final path = productController.productImages[widget.index];
                    backgroundImage: path.startsWith('http')
                        ? NetworkImage(path)
                        : File(path).existsSync()
                        ? FileImage(File(path))
                        : const AssetImage('assets/product.png'),

                    );
                  }),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
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

              // Editable name with edit icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: nameController,
                      onChanged: (_) => updateProduct(),
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

              Text(referenceId, style: TextStyle(color: Colors.grey[600])),

              const SizedBox(height: 32),

              CardRow(
                icon: Icons.calendar_month,
                title: "Expiry Date",
                value: formatDate(selectedDate),
                onEdit: pickExpiryDate,
              ),

              const SizedBox(height: 16),

              CardRow(
                icon: Icons.shopping_cart,
                title: "Minimum Quantity",
                value: '${minQuantityController.text} gm',
                onEdit: () async {
                  final TextEditingController tempController =
                  TextEditingController(text: minQuantityController.text);

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
                          onPressed: () {
                            minQuantityController.text = tempController.text;
                            updateProduct();
                            setState(() {});
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
    );
  }

  void _showImagePickerOptions() {
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
                        final pickedFile = await productController.picker.pickImage(source: ImageSource.gallery); // or .camera

                        if (pickedFile != null) {
                          final firebaseUrl = await productController.uploadImageToFirebase(
                            pickedFile.path,
                            productController.productNames[index],
                          );

                          await productController.saveProduct(
                            index,
                            productController.productNames[index],
                            firebaseUrl, // Save URL
                            productController.minWeights[index],
                          );

                          onUpdateProduct(); // update local state
                        }

                      },
                    ),
                    ImagePickerButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final pickedFile = await productController.picker.pickImage(source: ImageSource.gallery); // or .camera

                        if (pickedFile != null) {
                          final firebaseUrl = await productController.uploadImageToFirebase(
                            pickedFile.path,
                            productController.productNames[index],
                          );

                          await productController.saveProduct(
                            index,
                            productController.productNames[index],
                            firebaseUrl, // Save URL
                            productController.minWeights[index],
                          );

                          onUpdateProduct(); // update local state
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
}




