import 'package:weight_scale_v2/model/product_model.dart';
import 'package:weight_scale_v2/model/scale_model.dart';

class ProductWithWeight {
  final String name;
  final String picture;
  final double minimumWeight;
  final String expiredDate;
  final String currentWeight;
  final String rfidTag;

  ProductWithWeight({
    required this.name,
    required this.picture,
    required this.minimumWeight,
    required this.expiredDate,
    required this.currentWeight,
    required this.rfidTag,
  });

  factory ProductWithWeight.fromCombined({
    required ProductModel product,
    required ScaleModel scale,
  }) {
    return ProductWithWeight(
      name: product.name,
      picture: product.picture,
      minimumWeight: product.minimumWeight,
      expiredDate: product.expiredDate,
      currentWeight: scale.currentWeight,
      rfidTag: scale.rfidTag,
    );
  }
}
