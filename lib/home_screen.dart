import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    required this.potatoWeight,
    required this.onionWeight,
    required this.riceWeight,
    required this.saltWeight,
    required this.isBLEConnected,
  });

  final String potatoWeight;
  final String onionWeight;
  final String riceWeight;
  final String saltWeight;
  final bool isBLEConnected;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];
  bool _isShowingLowWeightDialog =
      false; // {"potato":5,"onion":1,"rice":1,"salt":1}
  final TextEditingController potatoController = TextEditingController();
  final TextEditingController onionController = TextEditingController();
  final TextEditingController riceController = TextEditingController();
  final TextEditingController saltController = TextEditingController();
  late List<TextEditingController> controllers;
  @override
  void initState() {
    super.initState();
    // Make sure to load weights from storage first
    //products = getProducts();
    controllers = [
      potatoController,
      onionController,
      riceController,
      saltController
    ];
    products = getProducts([1, 1, 1, 1]);
    _checkLowWeightProducts();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  List<Product> getProducts(List<double> minWeights) {
    print(" widget.potatoWeight");
    print(widget.potatoWeight);
    return [
      Product(
          productName: 'Potato',
          productImageAsset: 'assets/potato.jpg',
          minWeight: minWeights[0],
          currentWeight: widget.potatoWeight.isNotEmpty
              ? double.parse(widget.potatoWeight)
              : 0,
          index: 0),
      Product(
          productName: 'Onion',
          productImageAsset: 'assets/onion.jpg',
          minWeight: minWeights[1],
          currentWeight: widget.onionWeight.isNotEmpty
              ? double.parse(widget.onionWeight)
              : 0,
          index: 1),
      Product(
          productName: 'Rice',
          productImageAsset: 'assets/rice.jpg',
          minWeight: minWeights[2],
          currentWeight: widget.riceWeight.isNotEmpty
              ? double.parse(widget.riceWeight)
              : 0,
          index: 2),
      Product(
          productName: 'Salt',
          productImageAsset: 'assets/salt.jpg',
          minWeight: minWeights[3],
          currentWeight: widget.saltWeight.isNotEmpty
              ? double.parse(widget.saltWeight)
              : 0,
          index: 3),
    ];
  }

  void _checkLowWeightProducts() async {
    //if(context.mounted)
    print("1");
    await Future.delayed(Duration(seconds: 2));
    // if (mounted) {}
    print("widget.isBLEConnected check : ${widget.isBLEConnected}");
    if (!widget.isBLEConnected) {
      _checkLowWeightProducts();
      return;
    }
    await loadMinWeights();
    print("2 ${products.length}");
    final lowWeightProducts =
        products.where((product) => product.hasLowWeight()).toList();
    print("22 ${lowWeightProducts.length}");
    print("3");
    if (lowWeightProducts.isNotEmpty) {
      print("4");
      await _showLowWeightDialog(lowWeightProducts);
    }
    print("5");
    await Future.delayed(
        const Duration(seconds: 30)); // Check again after 10 seconds
    print("6");
    _checkLowWeightProducts();
  }

  Future<void> _showLowWeightDialog(List<Product> lowWeightProducts) async {
    // setState(() {
    // _isShowingLowWeightDialog = true;
    // });

    await showDialog(
      context: context,
      barrierDismissible: false, // Disable dismiss by tapping outside
      builder: (context) => AlertDialog(
        title: const Text(
          'Low Weight Products',
          style: TextStyle(color: Colors.red),
        ),
        content: Container(
          height: 200,
          width: 100,
          child: ListView.builder(
            shrinkWrap: true, // Prevent excessive height
            itemCount: lowWeightProducts.length,
            itemBuilder: (context, index) {
              final product = lowWeightProducts[index];
              return Text(
                '- ${product.productName} (Current weight: ${product.currentWeight} Kg, Min weight: ${product.minWeight} Kg)',
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // setState(() {
              // _isShowingLowWeightDialog = false;
              // });
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  late SharedPreferences prefs;
  bool isInitializedPrefs = false;
  List<bool> controllerInited = [
    false,
    false,
    false,
    false,
  ];
  Future<void> loadMinWeights() async {
    try {
      print("1");
      if (!isInitializedPrefs) {
        prefs = await SharedPreferences.getInstance();
        isInitializedPrefs = true;
      }
      print("2");
      List<double> minWeights = [];
      for (var product in products) {
        double storedWeight =
            prefs.getDouble('${product.productName}_minWeight') ?? 1;
        print("3");
        // {"potato":5,"onion":1,"rice":1,"salt":1}
        //  product.minWeight = storedWeight;
        if (!controllerInited[product.index]) {
          print("4");
          controllers[product.index].text = storedWeight.toString();
          controllerInited[product.index] = false;
        }
        print("5");
        product.minWeight = storedWeight;
        minWeights.add(storedWeight);
      }
      print("products weight are: ");
      print(
          "${minWeights[0]} ${minWeights[1]} ${minWeights[2]} ${minWeights[3]}");
      products = getProducts(minWeights);

      print("products weight 2 are: ");
      print(
          "${products[0].minWeight} ${products[1].minWeight} ${products[2].minWeight} ${products[3].minWeight}");
      // setState(() {});
    } on Exception catch (e) {
      print("error in load min wieght $e");
    }
  }

  void saveMinWeight(Product product) async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('${product.productName}_minWeight',
          double.parse(controllers[product.index].text));
      double storedWeight =
          prefs.getDouble('${product.productName}_minWeight') ?? 1;
      await loadMinWeights();
      print("Saved min wit $storedWeight");
    } on Exception catch (e) {
      print("error in save min wieght $e");
      // TODO
    }
  }

  @override
  Widget build(BuildContext context) {
    // _checkLowWeightProducts();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: 2,
        childAspectRatio: .7,
        children: products
            .map((product) => ProductBox(
                  product: product,
                  onMinWeightChanged: (newWeight) {
                    saveMinWeight(product);
                  },
                  controller: controllers[product.index],
                ))
            .toList(),
      ),
    );
  }
}

class ProductBox extends StatelessWidget {
  const ProductBox(
      {super.key,
      required this.product,
      required this.onMinWeightChanged,
      required this.controller});

  final Product product;
  final Function(double) onMinWeightChanged;
  final TextEditingController controller;

//   @override
//   _ProductBoxState createState() => _ProductBoxState();
// }

// class _ProductBoxState extends State<ProductBox> {
//   late TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller;
//     _controller =
//         TextEditingController(text: widget.product.minWeight.toString());
//   }

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
          Image.asset(
            product.productImageAsset,
            height: 100,
          ),
          const SizedBox(height: 4),
          Text(
            product.productName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Min weight: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Min weight',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final double? newWeight = double.tryParse(value);
                      if (newWeight != null) {
                        onMinWeightChanged(newWeight);
                        //   setState(() {
                        product.minWeight = newWeight;
                        //   });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Current weight: ${product.currentWeight} Kg',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
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
