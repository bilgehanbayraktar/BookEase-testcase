class BusinessOwner {
  final String id;
  final String fullName;
  final String email;

  const BusinessOwner({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory BusinessOwner.fromJson(Map<String, dynamic> json) => BusinessOwner(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
      );
}

class Business {
  final String id;
  final String name;
  final String category;
  final String? description;
  final bool isActive;
  final String createdAt;
  final BusinessOwner owner;

  const Business({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.owner,
  });

  factory Business.fromJson(Map<String, dynamic> json) => Business(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        description: json['description'] as String?,
        isActive: json['isActive'] as bool,
        createdAt: json['createdAt'] as String,
        owner: BusinessOwner.fromJson(json['owner'] as Map<String, dynamic>),
      );
}
