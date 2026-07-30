import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,   // Taksi qidirilmoqda...
  accepted,  // Haydovchi qabul qildi
  completed, // Yakunlandi
  cancelled  // Bekor qilindi
}

class OrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String fromAddress;
  final String toAddress;
  final String comment;
  final OrderStatus status;
  final String? driverName;
  final String? driverPhone;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.fromAddress,
    required this.toAddress,
    this.comment = '',
    this.status = OrderStatus.pending,
    this.driverName,
    this.driverPhone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // OrderStatus dynamic parsing helper
  static OrderStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.pending:
        return 'pending';
    }
  }

  // Firestore Document to OrderModel conversion
  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return OrderModel(
      id: documentId,
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      fromAddress: map['fromAddress'] as String? ?? '',
      toAddress: map['toAddress'] as String? ?? '',
      comment: map['comment'] as String? ?? '',
      status: _parseStatus(map['status'] as String?),
      driverName: map['driverName'] as String?,
      driverPhone: map['driverPhone'] as String?,
      createdAt: parsedDate,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel.fromMap(data, doc.id);
  }

  // OrderModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'comment': comment,
      'status': _statusToString(status),
      'driverName': driverName,
      'driverPhone': driverPhone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? fromAddress,
    String? toAddress,
    String? comment,
    OrderStatus? status,
    String? driverName,
    String? driverPhone,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
