import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

import '../model/product_model.dart';
import '../model/scale_model.dart';
import '../model/product_with_weight_model.dart';

class DeviceController extends GetxController {
  final databaseRef = FirebaseDatabase.instance.ref();
  var searchQuery = ''.obs;
  var productList = <ProductWithWeight>[].obs;

  final picker = ImagePicker(); // Add this if using image picker in screen

  @override
  void onInit() {
    super.onInit();
    listenToScalesAndBuildProductList();
  }

  void listenToScalesAndBuildProductList() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    databaseRef.child('users/$userId/scales').onValue.listen((event) async {
      if (!event.snapshot.exists) return;

      final raw = event.snapshot.value;
      if (raw is! Map) {
        print("❌ Scales root is not a Map: \${raw.runtimeType}");
        return;
      }

      final scaleMap = Map<String, dynamic>.from(raw);
      final productSnap = await databaseRef.child('products').get();

      if (!productSnap.exists) {
        print("❌ No productName data found");
        return;
      }

      final productMap = Map<String, dynamic>.from(productSnap.value as Map);
      List<ProductWithWeight> tempList = [];

      for (var entry in scaleMap.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is Map) {
          try {
            final scaleData =
                ScaleModel.fromMap(Map<String, dynamic>.from(value));
            final productData = productMap[scaleData.rfidTag];

            if (productData != null && productData is Map) {
              final product =
                  ProductModel.fromMap(Map<String, dynamic>.from(productData));
              final combined = ProductWithWeight.fromCombined(
                  product: product, scale: scaleData);
              tempList.add(combined);
            }
          } catch (e) {
            print('❌ Error with \$key: \$e');
          }
        } else {
          print('❌ Skipped \$key: not a Map');
        }
      }

      productList.assignAll(tempList);
    });
  }

  Future<void> updateProductImage(int index, String imageUrl) async {
    final product = productList[index];
    product.picture = imageUrl;
    productList[index] = product;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await databaseRef
          .child('products/${product.rfidTag}/picture')
          .set(imageUrl);
    }
  }

  Future<void> updateProductName(int index, String name) async {
    final product = productList[index];
    product.name = name;
    productList[index] = product;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await databaseRef.child('products/${product.rfidTag}/name').set(name);
    }
  }

  Future<void> updateProductMinimumWeight(int index, double weight) async {
    final product = productList[index];
    product.minimumWeight = weight;
    productList[index] = product;
    print("minimum 1");
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      print("minimum 133");
      await databaseRef
          .child('products/${product.rfidTag}/minimumWeight')
          .set(weight);
    }
    print("minimum 13377");
  }

  Future<void> updateProductExpiryDate(int index, String date) async {
    final product = productList[index];
    product.expiredDate = date;
    productList[index] = product;
    print("minimum 1366");

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      print("minimum 13677");
      await databaseRef
          .child('products/${product.rfidTag}/expiredDate')
          .set(date);
    }
    print("minimum 13677000");
  }
}
