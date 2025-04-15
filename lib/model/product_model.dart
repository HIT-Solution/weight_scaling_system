class ProductModel {
  final String name;
  final String picture;
  final double minimumWeight;
  final String expiredDate;

  ProductModel({
    required this.name,
    required this.picture,
    required this.minimumWeight,
    required this.expiredDate,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      name: map['name'] ?? '',
      picture: map['picture'] ?? '',
      minimumWeight: (map['minimumWeight'] ?? 0).toDouble(),
      expiredDate: map['expiredDate'] ?? '',
    );
  }
}
