import 'package:firebase_database/firebase_database.dart';

import '../model/product_model.dart';
import '../model/scale_model.dart';

Future<void> fetchAndShowData() async {
  final dbRef = FirebaseDatabase.instance.ref();

  // Step 1: Fetch scale data
  final scaleSnap = await dbRef
      .child("users/user1001/scales/F8:B3:B7:7A:F0:EC")
      .get();

  final scaleData = ScaleModel.fromMap(
      Map<String, dynamic>.from(scaleSnap.value as Map));

  // Step 2: Fetch product info based on rfidTag
  final productSnap =
  await dbRef.child("products/${scaleData.rfidTag}").get();

  final productData = ProductModel.fromMap(
      Map<String, dynamic>.from(productSnap.value as Map));

  // Now you have both scaleData and productData
  print("Weight: ${scaleData.currentWeight}");
  print("Product Name: ${productData.name}");
}
