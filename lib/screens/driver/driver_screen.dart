import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/taxi_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/order_card.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({Key? key}) : super(key: key);

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  late TextEditingController _driverNameController;
  late TextEditingController _driverPhoneController;
  bool _isProfileEditing = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TaxiProvider>();
    _driverNameController = TextEditingController(text: provider.driverName);
    _driverPhoneController = TextEditingController(text: provider.driverPhone);
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    super.dispose();
  }

  void _saveDriverProfile() {
    if (_driverNameController.text.trim().isEmpty || _driverPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, ism va telefon raqamingizni kiriting")),
      );
      return;
    }
    context.read<TaxiProvider>().updateDriverInfo(
          _driverNameController.text,
          _driverPhoneController.text,
        );
    setState(() {
      _isProfileEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaxiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car, color: AppTheme.accentGold),
            SizedBox(width: 8),
            Text("Haydovchi Ekran"),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isProfileEditing ? Icons.check : Icons.edit),
            tooltip: _isProfileEditing ? "Saqlash" : "Profilni tahrirlash",
            onPressed: () {
              if (_isProfileEditing) {
                _saveDriverProfile();
              } else {
                setState(() {
                  _isProfileEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Haydovchi Holati va Profil paneli
            _buildDriverHeaderCard(provider),

            const SizedBox(height: 20),

            // Profil tahrirlash formasi (ko'rsatilgan holatda)
            if (_isProfileEditing) ...[
              _buildDriverProfileForm(),
              const SizedBox(height: 20),
            ],

            // 2. Qabul Qilingan Faol Buyurtma (Active Accepted Order)
            StreamBuilder<OrderModel?>(
              stream: provider.driverActiveOrderStream,
              builder: (context, activeSnapshot) {
                final activeOrder = activeSnapshot.data;

                if (activeOrder != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jarayondagi Buyurtma",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OrderCard(
                        order: activeOrder,
                        isDriverView: true,
                        onComplete: () => provider.completeOrder(activeOrder.id),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }

                // 3. Yangi Buyurtmalar Ro'yxati (Feed - Real-time StreamBuilder)
                return _buildPendingOrdersFeed(provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 1. Driver Status Header & Toggle Switch Card
  Widget _buildDriverHeaderCard(TaxiProvider provider) {
    final isOnline = provider.isDriverOnline;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.borderRadius,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: isOnline ? AppTheme.successGreen : AppTheme.borderLight,
          width: isOnline ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppTheme.successGreen : AppTheme.errorRed,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.driverName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOnline ? "Rejim: Onlayn" : "Rejim: Oflayn",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isOnline ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Holat Kaliti (Switch)
          Row(
            children: [
              Text(
                isOnline ? "ON" : "OFF",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOnline ? AppTheme.successGreen : AppTheme.textMuted,
                ),
              ),
              const SizedBox(width: 6),
              Switch.adaptive(
                value: isOnline,
                activeColor: AppTheme.successGreen,
                onChanged: (val) {
                  provider.toggleDriverOnline(val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Driver Profile Edit Form
  Widget _buildDriverProfileForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _driverNameController,
            hintText: "Haydovchi ismi",
            labelText: "Ismingiz",
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: _driverPhoneController,
            hintText: "Telefon raqamingiz",
            labelText: "Telefon",
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone,
          ),
        ],
      ),
    );
  }

  // 2. Pending Orders Real-Time Feed
  Widget _buildPendingOrdersFeed(TaxiProvider provider) {
    if (!provider.isDriverOnline) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: AppTheme.borderRadius,
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(
              Icons.power_settings_new_rounded,
              size: 48,
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              "Siz oflaynsiz",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Yangi buyurtmalarni ko'rish va qabul qilish uchun onlayn rejimga o'ting.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Yangi Buyurtmalar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_tethering, size: 14, color: AppTheme.primaryDark),
                  SizedBox(width: 4),
                  Text(
                    "LIVE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // StreamBuilder to listen to real-time pending orders in Firestore
        StreamBuilder<List<OrderModel>>(
          stream: provider.pendingOrdersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final pendingOrders = snapshot.data ?? [];

            if (pendingOrders.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: AppTheme.borderRadius,
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 44,
                      color: AppTheme.accentGold,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Hozircha yangi buyurtmalar yo'q",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Mijozlar buyurtma berganda ushbu ro'yxatda avtomatik ko'rinadi.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                return OrderCard(
                  order: order,
                  isDriverView: true,
                  onAccept: () => provider.acceptOrder(order.id),
                  onReject: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Buyurtma rad etildi"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
