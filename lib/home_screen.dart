import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen(
      {super.key,
      required this.potatoWeight,
      required this.onionWeight,
      required this.riceWeight,
      required this.saltWeight});
  final String potatoWeight;
  final String onionWeight;
  final String riceWeight;
  final String saltWeight;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.count(
        padding: EdgeInsets.all(16),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: 2,
        childAspectRatio: .7,
        children: [
          ProductBox(
            productName: 'Potato',
            productImageAsset: 'assets/potato.jpg',
            maxWeight: '5',
            currentWeight: potatoWeight,
          ),
          ProductBox(
            productName: 'Onion',
            productImageAsset: 'assets/onion.jpg',
            maxWeight: '10',
            currentWeight: onionWeight,
          ),
          ProductBox(
            productName: 'Rice',
            productImageAsset: 'assets/rice.jpg',
            maxWeight: '15',
            currentWeight: riceWeight,
          ),
          ProductBox(
            productName: 'Salt',
            productImageAsset: 'assets/salt.jpg',
            maxWeight: '20',
            currentWeight: saltWeight,
          ),
        ],
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
            Image.asset(
              productImageAsset,
              height: 100,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              productName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
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
                  'Max weight: ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '$maxWeight Kg',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF030303),
                    fontSize: 12,
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
                  'Current weight: ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '$currentWeight Kg',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF030303),
                    fontSize: 12,
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
