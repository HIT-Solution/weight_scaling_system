import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1C8C8),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: GridView.count(
            padding: EdgeInsets.all(16),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            crossAxisCount: 2,
            children: const [
              ProductBox(
                productName: 'Product A',
                productImageAsset: 'assets/images/product_a.png',
                maxWeight: '5',
                currentWeight: '3',
              ),
              ProductBox(
                productName: 'Product B',
                productImageAsset: 'assets/images/product_b.png',
                maxWeight: '10',
                currentWeight: '7',
              ),
              ProductBox(
                productName: 'Product C',
                productImageAsset: 'assets/images/product_c.png',
                maxWeight: '15',
                currentWeight: '12',
              ),
              ProductBox(
                productName: 'Product D',
                productImageAsset: 'assets/images/product_d.png',
                maxWeight: '20',
                currentWeight: '10',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductBox extends StatelessWidget {
  const ProductBox(
      {super.key,
      required this.productName,
      required this.productImageAsset,
      required this.maxWeight,
      required this.currentWeight});

  final String productName;
  final String productImageAsset;
  final String maxWeight;
  final String currentWeight;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width *
        0.45; // Adjusted width for two cards in a row

    return Container(
        padding: const EdgeInsets.all(20),
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.production_quantity_limits,
              size: 60,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              productName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Max weight:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '$maxWeight Kg',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF030303),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current weight:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '$currentWeight Kg',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF030303),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ],
        ));
  }
}
