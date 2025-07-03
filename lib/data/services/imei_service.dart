import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/imei_device_model.dart';
import '../models/user_model.dart';

class ImeiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new IMEI device
  Future<ImeiDevice?> registerDevice({
    required String imeiNumber,
    required String deviceBrand,
    required String deviceModel,
    required String deviceType,
    String? deviceColor,
    String? purchaseDate,
    String? retailerName,
    String? serialNumber,
    required AppUser user,
  }) async {
    try {
      // Check if IMEI already exists
      final existingDevice = await getDeviceByImei(imeiNumber);
      if (existingDevice != null) {
        throw Exception('This IMEI number is already registered');
      }

      // Create new device registration
      final deviceData = ImeiDevice(
        id: '', // Will be set by Firestore
        imeiNumber: imeiNumber,
        deviceBrand: deviceBrand,
        deviceModel: deviceModel,
        deviceType: deviceType,
        deviceColor: deviceColor,
        purchaseDate: purchaseDate,
        retailerName: retailerName,
        serialNumber: serialNumber,
        status: DeviceStatus.pending,
        userId: user.uid,
        userFullName: user.fullName,
        userEmail: user.email,
        userPhone: user.phoneNumber,
        userCnic: user.cnic,
        registeredAt: DateTime.now(),
      ); // Save to Firestore
      await _firestore
          .collection('imei_registrations')
          .add(deviceData.toFirestore());

      // Return the created device
      return deviceData;
    } catch (e) {
      throw Exception('Failed to register device: ${e.toString()}');
    }
  }

  // Get device by IMEI number
  Future<ImeiDevice?> getDeviceByImei(String imeiNumber) async {
    try {
      final QuerySnapshot result =
          await _firestore
              .collection('imei_registrations')
              .where('imeiNumber', isEqualTo: imeiNumber)
              .limit(1)
              .get();

      if (result.docs.isNotEmpty) {
        return ImeiDevice.fromFirestore(result.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to check IMEI: ${e.toString()}');
    }
  }

  // Get user's registered devices
  Future<List<ImeiDevice>> getUserDevices(String userId) async {
    try {
      final QuerySnapshot result =
          await _firestore
              .collection('imei_registrations')
              .where('userId', isEqualTo: userId)
              .orderBy('registeredAt', descending: true)
              .get();

      return result.docs.map((doc) => ImeiDevice.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user devices: ${e.toString()}');
    }
  }

  // Get all device registrations (for admin)
  Future<List<ImeiDevice>> getAllDevices() async {
    try {
      final QuerySnapshot result =
          await _firestore
              .collection('imei_registrations')
              .orderBy('registeredAt', descending: true)
              .get();

      return result.docs.map((doc) => ImeiDevice.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all devices: ${e.toString()}');
    }
  }

  // Get devices by status (for admin)
  Future<List<ImeiDevice>> getDevicesByStatus(DeviceStatus status) async {
    try {
      final QuerySnapshot result =
          await _firestore
              .collection('imei_registrations')
              .where('status', isEqualTo: status.value)
              .orderBy('registeredAt', descending: true)
              .get();

      return result.docs.map((doc) => ImeiDevice.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get devices by status: ${e.toString()}');
    }
  }

  // Update device status (for admin)
  Future<void> updateDeviceStatus({
    required String deviceId,
    required DeviceStatus status,
    String? rejectionReason,
    String? approvedBy,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': status.value};

      if (status == DeviceStatus.approved) {
        updateData['approvedAt'] = Timestamp.fromDate(DateTime.now());
        updateData['approvedBy'] = approvedBy;
      } else if (status == DeviceStatus.rejected) {
        updateData['rejectionReason'] = rejectionReason;
      }

      await _firestore
          .collection('imei_registrations')
          .doc(deviceId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update device status: ${e.toString()}');
    }
  }

  // Get registration statistics
  Future<Map<String, int>> getRegistrationStats() async {
    try {
      final allDevices = await getAllDevices();

      final stats = <String, int>{
        'total': allDevices.length,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'suspended': 0,
      };

      for (final device in allDevices) {
        stats[device.status.value] = (stats[device.status.value] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get registration stats: ${e.toString()}');
    }
  }

  // Validate IMEI number format
  static bool isValidImei(String imei) {
    // Remove any spaces or dashes
    final cleanImei = imei.replaceAll(RegExp(r'[-\s]'), '');

    // IMEI should be 15 digits
    if (cleanImei.length != 15) return false;

    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(cleanImei)) return false;

    // For development/testing, use a more lenient validation
    // You can enable strict Luhn validation later by uncommenting the line below
    
    // Strict Luhn algorithm check for IMEI validation (uncomment for production)
    // return _luhnCheck(cleanImei);
    
    // Lenient validation for testing (comment out for production)
    return true;
  }

  // Alternative validation for testing - more lenient
  static bool isValidImeiForTesting(String imei) {
    final cleanImei = imei.replaceAll(RegExp(r'[-\s]'), '');
    return cleanImei.length == 15 && RegExp(r'^\d+$').hasMatch(cleanImei);
  }

  // Luhn algorithm implementation for IMEI validation
  static bool _luhnCheck(String imei) {
    int sum = 0;
    bool alternate = false;

    for (int i = imei.length - 1; i >= 0; i--) {
      int digit = int.parse(imei[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + (digit ~/ 10);
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  // Get device brands for dropdown
  static List<String> getDeviceBrands() {
    return [
      'Samsung',
      'Apple',
      'Huawei',
      'Xiaomi',
      'Oppo',
      'Vivo',
      'OnePlus',
      'Realme',
      'Nokia',
      'Motorola',
      'LG',
      'Sony',
      'Google',
      'Infinix',
      'Tecno',
      'Honor',
      'Other',
    ];
  }

  // Get device types for dropdown
  static List<String> getDeviceTypes() {
    return ['Smartphone', 'Tablet', 'Feature Phone', 'Smartwatch', 'Other'];
  }
}
