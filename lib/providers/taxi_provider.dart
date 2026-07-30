import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';

enum UserRole { none, customer, driver }

class TaxiProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  UserRole _currentRole = UserRole.none;
  
  // Customer State
  String _customerName = "Alisher Navoiy";
  String _customerPhone = "+998901234567";

  // Driver State
  String _driverName = "Sardor Rahimov";
  String _driverPhone = "+998998765432";
  bool _isDriverOnline = true;

  // Loading States
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserRole get currentRole => _currentRole;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get driverName => _driverName;
  String get driverPhone => _driverPhone;
  bool get isDriverOnline => _isDriverOnline;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void updateCustomerInfo(String name, String phone) {
    _customerName = name.trim();
    _customerPhone = phone.trim();
    notifyListeners();
  }

  void updateDriverInfo(String name, String phone) {
    _driverName = name.trim();
    _driverPhone = phone.trim();
    notifyListeners();
  }

  void toggleDriverOnline(bool value) {
    _isDriverOnline = value;
    notifyListeners();
  }

  // 1. Mijoz taksi chaqiradi
  Future<bool> requestTaxi({
    required String fromAddress,
    required String toAddress,
    String comment = '',
  }) async {
    _setLoading(true);
    try {
      final newOrder = OrderModel(
        id: '',
        customerName: _customerName,
        customerPhone: _customerPhone,
        fromAddress: fromAddress,
        toAddress: toAddress,
        comment: comment,
        status: OrderStatus.pending,
      );

      await _firebaseService.createOrder(newOrder);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Buyurtma berishda xatolik yuz berdi: $e";
      _setLoading(false);
      return false;
    }
  }

  // 2. Haydovchi buyurtmani qabul qiladi
  Future<bool> acceptOrder(String orderId) async {
    _setLoading(true);
    try {
      await _firebaseService.acceptOrder(
        orderId: orderId,
        driverName: _driverName,
        driverPhone: _driverPhone,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Buyurtmani qabul qilishda xatolik: $e";
      _setLoading(false);
      return false;
    }
  }

  // 3. Haydovchi buyurtmani yakunlaydi
  Future<bool> completeOrder(String orderId) async {
    _setLoading(true);
    try {
      await _firebaseService.completeOrder(orderId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Buyurtmani yakunlashda xatolik: $e";
      _setLoading(false);
      return false;
    }
  }

  // 4. Mijoz buyurtmani bekor qiladi
  Future<bool> cancelOrder(String orderId) async {
    _setLoading(true);
    try {
      await _firebaseService.cancelOrder(orderId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Buyurtmani bekor qilishda xatolik: $e";
      _setLoading(false);
      return false;
    }
  }

  // Streams
  Stream<List<OrderModel>> get pendingOrdersStream =>
      _firebaseService.getPendingOrdersStream();

  Stream<OrderModel?> get customerActiveOrderStream =>
      _firebaseService.getCustomerActiveOrderStream(_customerPhone);

  Stream<OrderModel?> get driverActiveOrderStream =>
      _firebaseService.getDriverActiveOrderStream(_driverPhone);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
