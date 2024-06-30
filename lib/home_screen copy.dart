// import 'dart:async';
// import 'package:flutter/material.dart';

// class ProductScreen extends StatefulWidget {
//   const ProductScreen({
//     super.key,
//     required this.potatoWeight,
//     required this.onionWeight,
//     required this.riceWeight,
//     required this.saltWeight,
//     required this.isBLEConnected,
//   });

//   final String potatoWeight;
//   final String onionWeight;
//   final String riceWeight;
//   final String saltWeight;
//   final bool isBLEConnected;

//   @override
//   State<ProductScreen> createState() => _ProductScreenState();
// }

// class _ProductScreenState extends State<ProductScreen> {
//   List<Product> products = [];
//   bool _isShowingLowWeightDialog = false;
//   @override
//   void initState() {
//     super.initState();
//     products = getProducts();

//     _checkLowWeightProducts();
//   }

//   // @override
//   // void didChangeDependencies() {
//   //   super.didChangeDependencies();
//   // }

//   List<Product> getProducts() {
//     print(" widget.potatoWeight");
//     print(widget.potatoWeight);
//     return [
//       Product(
//         productName: 'Potato',
//         productImageAsset: 'assets/potato.jpg',
//         minWeight: 2,
//         currentWeight: widget.potatoWeight.isNotEmpty
//             ? double.parse(widget.potatoWeight)
//             : 0,
//       ),
//       Product(
//         productName: 'Onion',
//         productImageAsset: 'assets/onion.jpg',
//         minWeight: 1,
//         currentWeight: widget.onionWeight.isNotEmpty
//             ? double.parse(widget.onionWeight)
//             : 0,
//       ),
//       Product(
//         productName: 'Rice',
//         productImageAsset: 'assets/rice.jpg',
//         minWeight: 5,
//         currentWeight:
//             widget.riceWeight.isNotEmpty ? double.parse(widget.riceWeight) : 0,
//       ),
//       Product(
//         productName: 'Salt',
//         productImageAsset: 'assets/salt.jpg',
//         minWeight: 1,
//         currentWeight:
//             widget.saltWeight.isNotEmpty ? double.parse(widget.saltWeight) : 0,
//       ),
//     ];
//   }

//   void _checkLowWeightProducts() async {
//     //if(context.mounted)
//     print("1");
//     await Future.delayed(Duration(seconds: 2));
//     // if (mounted) {}
//     print("widget.isBLEConnected check : ${widget.isBLEConnected}");
//     if (!widget.isBLEConnected) {
//       _checkLowWeightProducts();
//       return;
//     }
//     products = getProducts();

//     print("2 ${products.length}");
//     final lowWeightProducts =
//         products.where((product) => product.hasLowWeight()).toList();
//     print("22 ${lowWeightProducts.length}");
//     print("3");
//     if (lowWeightProducts.isNotEmpty) {
//       print("4");
//       await _showLowWeightDialog(lowWeightProducts);
//     }
//     print("5");
//     await Future.delayed(
//         const Duration(seconds: 30)); // Check again after 10 seconds
//     print("6");
//     _checkLowWeightProducts();
//   }

//   Future<void> _showLowWeightDialog(List<Product> lowWeightProducts) async {
//     // setState(() {
//     // _isShowingLowWeightDialog = true;
//     // });

//     await showDialog(
//       context: context,
//       barrierDismissible: false, // Disable dismiss by tapping outside
//       builder: (context) => AlertDialog(
//         title: const Text(
//           'Low Weight Products',
//           style: TextStyle(color: Colors.red),
//         ),
//         content: Container(
//           height: 200,
//           width: 100,
//           child: ListView.builder(
//             shrinkWrap: true, // Prevent excessive height
//             itemCount: lowWeightProducts.length,
//             itemBuilder: (context, index) {
//               final product = lowWeightProducts[index];
//               return Text(
//                 '- ${product.productName} (Current weight: ${product.currentWeight} Kg, Min weight: ${product.minWeight} Kg)',
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // setState(() {
//               // _isShowingLowWeightDialog = false;
//               // });
//             },
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // _checkLowWeightProducts();
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: GridView.count(
//         padding: const EdgeInsets.all(16),
//         mainAxisSpacing: 10,
//         crossAxisSpacing: 10,
//         crossAxisCount: 2,
//         childAspectRatio: .7,
//         children:
//             products.map((product) => ProductBox(product: product)).toList(),
//       ),
//     );
//   }
// }

// class ProductBox extends StatelessWidget {
//   const ProductBox({super.key, required this.product});

//   final Product product;

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width * 0.45;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       width: width,
//       clipBehavior: Clip.antiAlias,
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         shadows: [
//           BoxShadow(
//             color: const Color(0x19000000),
//             blurRadius: 4,
//             offset: const Offset(0, 4),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Image.asset(
//             product.productImageAsset,
//             height: 100,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             product.productName,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 14,
//               fontFamily: 'Inter',
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Min weight: ',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 12,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               Text(
//                 '${product.minWeight} Kg',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Color(0xFF030303),
//                   fontSize: 12,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Current weight: ',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 12,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               Text(
//                 '${product.currentWeight} Kg',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Color(0xFF030303),
//                   fontSize: 12,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Product {
//   const Product({
//     required this.productName,
//     required this.productImageAsset,
//     required this.minWeight,
//     required this.currentWeight,
//   });

//   final String productName;
//   final String productImageAsset;
//   final double minWeight;
//   final double currentWeight;

//   bool hasLowWeight() {
//     return currentWeight < minWeight;
//   }
// }
