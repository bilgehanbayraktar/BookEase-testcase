class Booking {
  final String id;
  final String slotId;
  final String slotStartTime;
  final String slotEndTime;
  final String serviceName;
  final String businessName;
  final String customerName;
  final String customerEmail;
  final String status;
  final String? note;
  final String createdAt;
  final String? cancelledAt;

  const Booking({
    required this.id,
    required this.slotId,
    required this.slotStartTime,
    required this.slotEndTime,
    required this.serviceName,
    required this.businessName,
    required this.customerName,
    required this.customerEmail,
    required this.status,
    this.note,
    required this.createdAt,
    this.cancelledAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        slotId: json['slotId'] as String,
        slotStartTime: json['slotStartTime'] as String,
        slotEndTime: json['slotEndTime'] as String,
        serviceName: json['serviceName'] as String,
        businessName: json['businessName'] as String,
        customerName: json['customerName'] as String,
        customerEmail: json['customerEmail'] as String,
        status: json['status'] as String,
        note: json['note'] as String?,
        createdAt: json['createdAt'] as String,
        cancelledAt: json['cancelledAt'] as String?,
      );
}
