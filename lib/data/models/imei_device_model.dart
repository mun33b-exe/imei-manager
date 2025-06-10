import 'package:cloud_firestore/cloud_firestore.dart';

enum DeviceStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  suspended('suspended');

  const DeviceStatus(this.value);
  final String value;

  static DeviceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'approved':
        return DeviceStatus.approved;
      case 'rejected':
        return DeviceStatus.rejected;
      case 'suspended':
        return DeviceStatus.suspended;
      case 'pending':
      default:
        return DeviceStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case DeviceStatus.pending:
        return 'Pending Review';
      case DeviceStatus.approved:
        return 'Approved';
      case DeviceStatus.rejected:
        return 'Rejected';
      case DeviceStatus.suspended:
        return 'Suspended';
    }
  }
}

class ImeiDevice {
  final String id;
  final String imeiNumber;
  final String deviceBrand;
  final String deviceModel;
  final String deviceType;
  final String? deviceColor;
  final String? purchaseDate;
  final String? retailerName;
  final String? serialNumber;
  final DeviceStatus status;
  final String userId;
  final String userFullName;
  final String userEmail;
  final String userPhone;
  final String userCnic;
  final DateTime registeredAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? approvedBy;

  ImeiDevice({
    required this.id,
    required this.imeiNumber,
    required this.deviceBrand,
    required this.deviceModel,
    required this.deviceType,
    this.deviceColor,
    this.purchaseDate,
    this.retailerName,
    this.serialNumber,
    required this.status,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.userPhone,
    required this.userCnic,
    required this.registeredAt,
    this.approvedAt,
    this.rejectionReason,
    this.approvedBy,
  });

  // Factory constructor to create ImeiDevice from Firestore document
  factory ImeiDevice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ImeiDevice(
      id: doc.id,
      imeiNumber: data['imeiNumber'] ?? '',
      deviceBrand: data['deviceBrand'] ?? '',
      deviceModel: data['deviceModel'] ?? '',
      deviceType: data['deviceType'] ?? '',
      deviceColor: data['deviceColor'],
      purchaseDate: data['purchaseDate'],
      retailerName: data['retailerName'],
      serialNumber: data['serialNumber'],
      status: DeviceStatus.fromString(data['status'] ?? 'pending'),
      userId: data['userId'] ?? '',
      userFullName: data['userFullName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'] ?? '',
      userCnic: data['userCnic'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      approvedAt:
          data['approvedAt'] != null
              ? (data['approvedAt'] as Timestamp).toDate()
              : null,
      rejectionReason: data['rejectionReason'],
      approvedBy: data['approvedBy'],
    );
  }

  // Convert ImeiDevice to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'imeiNumber': imeiNumber,
      'deviceBrand': deviceBrand,
      'deviceModel': deviceModel,
      'deviceType': deviceType,
      'deviceColor': deviceColor,
      'purchaseDate': purchaseDate,
      'retailerName': retailerName,
      'serialNumber': serialNumber,
      'status': status.value,
      'userId': userId,
      'userFullName': userFullName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userCnic': userCnic,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
    };
  }

  // Copy with method for updating device data
  ImeiDevice copyWith({
    String? imeiNumber,
    String? deviceBrand,
    String? deviceModel,
    String? deviceType,
    String? deviceColor,
    String? purchaseDate,
    String? retailerName,
    String? serialNumber,
    DeviceStatus? status,
    DateTime? approvedAt,
    String? rejectionReason,
    String? approvedBy,
  }) {
    return ImeiDevice(
      id: id,
      imeiNumber: imeiNumber ?? this.imeiNumber,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceType: deviceType ?? this.deviceType,
      deviceColor: deviceColor ?? this.deviceColor,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      retailerName: retailerName ?? this.retailerName,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      userId: userId,
      userFullName: userFullName,
      userEmail: userEmail,
      userPhone: userPhone,
      userCnic: userCnic,
      registeredAt: registeredAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}
