// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// Future<void> triggerEmail({
//   required String emailType,
//   required String productName,
//   required String userEmail,
// }) async {
//   print("object 1");
//   final callable = FirebaseFunctions.instance.httpsCallable('sendEmailNotification');
//
//   print("object 2");
//   try {
//     final result = await callable.call({
//       'emailType': emailType,
//       'productName': productName,
//       'userEmail': userEmail,
//     });
//   print("object 3");
//
//     if (result.data['success'] == true) {
//       print("✅ Email sent successfully");
//   print("object 4");
//     }
//   } catch (e) {
//   print("object 5");
//     print("❌ Email send failed: $e");
//   }
// }
