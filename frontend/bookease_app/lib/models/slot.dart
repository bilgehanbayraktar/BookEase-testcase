class Slot {
  final String id;
  final String serviceId;
  final String serviceName;
  final String startTime;
  final String endTime;
  final int currentBookings;
  final int capacity;
  final bool isAvailable;
  final bool isActive;

  const Slot({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    required this.currentBookings,
    required this.capacity,
    required this.isAvailable,
    required this.isActive,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        id: json['id'] as String,
        serviceId: json['serviceId'] as String,
        serviceName: json['serviceName'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        currentBookings: json['currentBookings'] as int,
        capacity: json['capacity'] as int,
        isAvailable: json['isAvailable'] as bool,
        isActive: json['isActive'] as bool,
      );
}
