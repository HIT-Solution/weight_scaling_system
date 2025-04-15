class ScaleModel {
  final String currentWeight;
  final String rfidTag;
  final String sentTime;


  ScaleModel({
    required this.currentWeight,
    required this.rfidTag,
    required this.sentTime,

  });

  factory ScaleModel.fromMap(Map<String, dynamic> map) {
    return ScaleModel(
      currentWeight: map['currentWeight'] ?? '',
      rfidTag: map['rfidTag'] ?? '',
      sentTime: map['sentTime'] ?? '',

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentWeight': currentWeight,
      'rfidTag': rfidTag,
      'sentTime': sentTime,

    };
  }
}
