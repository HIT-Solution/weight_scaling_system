import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

import '../model/product_model.dart';
import '../model/scale_model.dart';
import '../model/product_with_weight_model.dart';
import '../utils/notification_service.dart'; // must contain triggerEmail()

class DeviceController extends GetxController {
  final databaseRef = FirebaseDatabase.instance.ref();
  var searchQuery = ''.obs;
  var productList = <ProductWithWeight>[].obs;

  final picker = ImagePicker();
  final sentLowWeightEmails = <String>{}.obs;
  final sentExpiredEmails = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    listenToScalesAndBuildProductList();
  }

  void listenToScalesAndBuildProductList() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("⚠️ No user signed in. Skipping scale listener.");
      return;
    }

    final userId = user.uid;
    final userEmail = user.email ?? '';

    databaseRef.child('users/$userId/scales').onValue.listen((event) async {
      if (!event.snapshot.exists) return;

      final raw = event.snapshot.value;
      if (raw is! Map) {
        print("❌ Scales root is not a Map: ${raw.runtimeType}");
        return;
      }

      final scaleMap = Map<String, dynamic>.from(raw);
      final productSnap = await databaseRef.child('products').get();

      if (!productSnap.exists) {
        print("❌ No product data found");
        return;
      }

      final productMap = Map<String, dynamic>.from(productSnap.value as Map);
      List<ProductWithWeight> tempList = [];

      for (var entry in scaleMap.entries) {
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

              final currentWeight =
                  double.tryParse(scaleData.currentWeight.toString()) ?? 0.0;
              final minWeight =
                  double.tryParse(product.minimumWeight.toString()) ?? 0.0;
              final tag = scaleData.rfidTag?.toString() ?? '';
              print("triggerEmail 1");
              if (userEmail.isNotEmpty &&
                  currentWeight < minWeight &&
                  !sentLowWeightEmails.contains(tag)) {
                print("triggerEmail 2");
                await triggerEmail(
                  emailType: 'minimumWeight',
                  productName: product.name,
                  userEmail: userEmail,
                );
                print("triggerEmail 3");
                sentLowWeightEmails.add(tag);
              }
              print("triggerEmail 4");

              final expiredDate = product.expiredDate;
              final isExpired = expiredDate != null &&
                  DateTime.tryParse(expiredDate)?.isBefore(DateTime.now()) ==
                      true;

              if (userEmail.isNotEmpty &&
                  isExpired &&
                  !sentExpiredEmails.contains(tag)) {
                await triggerEmail(
                  emailType: 'expired',
                  productName: product.name,
                  userEmail: userEmail,
                );
                sentExpiredEmails.add(tag);
              }
            }
          } catch (e) {
            print('❌ Error processing scale data: $e');
          }
        } else {
          print('❌ Skipped invalid scale entry');
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

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await databaseRef
          .child('products/${product.rfidTag}/minimumWeight')
          .set(weight);
    }
  }

  Future<void> updateProductExpiryDate(int index, String date) async {
    final product = productList[index];
    product.expiredDate = date;
    productList[index] = product;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await databaseRef
          .child('products/${product.rfidTag}/expiredDate')
          .set(date);
    }
  }
}
