class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    required this.capacity,
    required this.isActive,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final double price;
  final int capacity;
  final bool isActive;

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'] as String,
        name: json['name'] as String,
        durationMinutes: json['durationMinutes'] as int,
        price: (json['price'] as num).toDouble(),
        capacity: json['capacity'] as int,
        isActive: json['isActive'] as bool,
      );
}
