import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/order_model.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  FirebaseService._internal();

  bool _isFirebaseInitialized = false;

  // Local Mock State (Firebase ulanmagan taqdirda demo rejimda ishlashi uchun)
  final List<OrderModel> _mockOrders = [];
  final _mockOrdersController = StreamController<List<OrderModel>>.broadcast();

  bool get isFirebaseInitialized => _isFirebaseInitialized;

  void markInitialized() {
    _isFirebaseInitialized = true;
  }

  // 1. Yangi buyurtma yaratish (Customer)
  Future<String> createOrder(OrderModel order) async {
    try {
      if (_isFirebaseInitialized && Firebase.apps.isNotEmpty) {
        final docRef = FirebaseFirestore.instance.collection('orders').doc();
        final newOrder = order.copyWith(id: docRef.id);
        await docRef.set(newOrder.toMap());
        return docRef.id;
      } else {
        // Fallback: Local Demo Mode
        final id = 'demo_${DateTime.now().millisecondsSinceEpoch}';
        final newOrder = order.copyWith(id: id);
        _mockOrders.insert(0, newOrder);
        _notifyMockListeners();
        return id;
      }
    } catch (e) {
      // Emergency fallback
      final id = 'demo_${DateTime.now().millisecondsSinceEpoch}';
      final newOrder = order.copyWith(id: id);
      _mockOrders.insert(0, newOrder);
      _notifyMockListeners();
      return id;
    }
  }

  // 2. Yangi (pending) buyurtmalar ro'yxatini Stream shaklida olish (Driver Feed)
  Stream<List<OrderModel>> getPendingOrdersStream() {
    if (_isFirebaseInitialized && Firebase.apps.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snapshot) {
        final orders = snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList();
        // Saralash: yangi kiritilganlari birinchi bo'lib ko'rinadi
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      });
    } else {
      // Fallback Stream
      return _mockOrdersController.stream.map((list) {
        return list.where((o) => o.status == OrderStatus.pending).toList();
      });
    }
  }

  // 3. Mijozning faol buyurtmasini real-vaqtda kuzatish (Customer Live Tracking)
  Stream<OrderModel?> getCustomerActiveOrderStream(String customerPhone) {
    if (_isFirebaseInitialized && Firebase.apps.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('orders')
          .where('customerPhone', isEqualTo: customerPhone)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        
        final list = snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList();
        
        // Oxirgi va faol buyurtmani olish (pending yoki accepted)
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        try {
          return list.firstWhere(
            (o) => o.status == OrderStatus.pending || o.status == OrderStatus.accepted,
          );
        } catch (_) {
          return list.isNotEmpty ? list.first : null;
        }
      });
    } else {
      return _mockOrdersController.stream.map((list) {
        final matches = list
            .where((o) => o.customerPhone == customerPhone)
            .toList();
        matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        try {
          return matches.firstWhere(
            (o) => o.status == OrderStatus.pending || o.status == OrderStatus.accepted,
          );
        } catch (_) {
          return matches.isNotEmpty ? matches.first : null;
        }
      });
    }
  }

  // 4. Haydovchining qabul qilingan faol buyurtmasini olish (Driver Active Order)
  Stream<OrderModel?> getDriverActiveOrderStream(String driverPhone) {
    if (_isFirebaseInitialized && Firebase.apps.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('orders')
          .where('driverPhone', isEqualTo: driverPhone)
          .where('status', isEqualTo: 'accepted')
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return OrderModel.fromFirestore(snapshot.docs.first);
      });
    } else {
      return _mockOrdersController.stream.map((list) {
        try {
          return list.firstWhere(
            (o) => o.driverPhone == driverPhone && o.status == OrderStatus.accepted,
          );
        } catch (_) {
          return null;
        }
      });
    }
  }

  // 5. Buyurtmani qabul qilish (Driver accepts order)
  Future<void> acceptOrder({
    required String orderId,
    required String driverName,
    required String driverPhone,
  }) async {
    if (_isFirebaseInitialized && Firebase.apps.isNotEmpty) {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'accepted',
        'driverName': driverName,
        'driverPhone': driverPhone,
      });
    } else {
      final index = _mockOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _mockOrders[index] = _mockOrders[index].copyWith(
          status: OrderStatus.accepted,
          driverName: driverName,
          driverPhone: driverPhone,
        );
        _notifyMockListeners();
      }
    }
  }

  // 6. Buyurtmani yakunlash (Driver completes order)
  Future<void> completeOrder(String orderId) async {
    if (_isFirebaseInitialized && Firebase.apps.isNotEmpty) {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'completed',
      });
    } else {
      final index = _mockOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _mockOrders[index] = _mockOrders[index].copyWith(
          status: OrderStatus.completed,
        );
        _notifyMockListeners();
      }
    }
  }

  // 7. Buyurtmani bekor qilish (Customer cancels order)
  Future<void> cancelOrder(String orderId) async {
    if (_isFirebaseInitialized && Firebase.apps.isNotEmpty) {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'cancelled',
      });
    } else {
      final index = _mockOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _mockOrders[index] = _mockOrders[index].copyWith(
          status: OrderStatus.cancelled,
        );
        _notifyMockListeners();
      }
    }
  }

  void _notifyMockListeners() {
    _mockOrdersController.add(List.from(_mockOrders));
  }
}
