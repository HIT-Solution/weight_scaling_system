import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProductController extends GetxController {
  var productName = 'Product Name'.obs;
  var productImage = ''.obs;

  void updateProductName(String newName) {
    productName.value = newName;
  }

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      productImage.value = image.path;
    }
  }
}
