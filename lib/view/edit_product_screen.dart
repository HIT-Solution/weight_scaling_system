import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/product_controller.dart';

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

  DateTime selectedDate = DateTime(2025, 3, 12); // Placeholder
  final String referenceId = "Ref-5c:2F:18:00";

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: productController.productNames[widget.index]);
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Product image with edit icon
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Obx(() {
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                        productController.productImages[widget.index]
                            .contains('assets/')
                            ? AssetImage(
                            productController.productImages[widget.index])
                        as ImageProvider
                            : FileImage(File(productController
                            .productImages[widget.index])),
                      );
                    }),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: GestureDetector(
                        onTap: () {
                          productController.pickImage(widget.index);
                          updateProduct();
                        },
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

                // Expiry Date Card
                _CardRow(
                  icon: Icons.calendar_month,
                  title: "Expiry Date",
                  value: formatDate(selectedDate),
                  onEdit: pickExpiryDate,
                ),

                const SizedBox(height: 16),

                // Min Quantity Card
                _CardRow(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onEdit;

  const _CardRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 26, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFB8F8C2), // Light green background
            ),
            child: const Icon(Icons.notifications, size: 16),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
              child: const Icon(Icons.edit, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}


