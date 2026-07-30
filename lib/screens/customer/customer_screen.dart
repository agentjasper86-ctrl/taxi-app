import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/taxi_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/order_card.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final TextEditingController _fromController = TextEditingController(text: "G'ijduvon markaz");
  final TextEditingController _toController = TextEditingController(text: "Buxoro markaziy bozor");
  final TextEditingController _commentController = TextEditingController();

  bool _isProfileSaved = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TaxiProvider>();
    _nameController = TextEditingController(text: provider.customerName);
    _phoneController = TextEditingController(text: provider.customerPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, ismingiz va telefon raqamingizni kiriting")),
      );
      return;
    }
    context.read<TaxiProvider>().updateCustomerInfo(
          _nameController.text,
          _phoneController.text,
        );
    setState(() {
      _isProfileSaved = true;
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TaxiProvider>();
    final success = await provider.requestTaxi(
      fromAddress: _fromController.text.trim(),
      toAddress: _toController.text.trim(),
      comment: _commentController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Buyurtma yuborildi. Taksi qidirilmoqda..."),
          backgroundColor: AppTheme.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaxiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_pin_circle, color: AppTheme.accentGold),
            SizedBox(width: 8),
            Text("Mijoz Ekran"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            tooltip: "Profilni tahrirlash",
            onPressed: () {
              setState(() {
                _isProfileSaved = false;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profil Kirish Formasi (Ismi va Telefon raqami)
              if (!_isProfileSaved) ...[
                _buildProfileCard(),
                const SizedBox(height: 24),
              ],

              // Real-vaqt Buyurtma Holati (StreamBuilder)
              StreamBuilder<OrderModel?>(
                stream: provider.customerActiveOrderStream,
                builder: (context, snapshot) {
                  final activeOrder = snapshot.data;

                  // Active Order mavjud bo'lsa (Pending yoki Accepted)
                  if (activeOrder != null &&
                      (activeOrder.status == OrderStatus.pending ||
                          activeOrder.status == OrderStatus.accepted)) {
                    return _buildActiveOrderStatusSection(activeOrder, provider);
                  }

                  // Aks holda Buyurtma Berish Formasini ko'rsatish
                  return _buildOrderForm(provider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Customer Profile Card Widget
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.borderRadius,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_circle, color: AppTheme.primaryDark),
              ),
              const SizedBox(width: 10),
              const Text(
                "Shaxsiy Ma'lumotlar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _nameController,
            hintText: "Masalan: Alisher Navoiy",
            labelText: "Ismingiz",
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _phoneController,
            hintText: "Masalan: +998901234567",
            labelText: "Telefon raqamingiz",
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android_outlined,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: "Ma'lumotlarni saqlash",
            height: 48,
            isSecondary: true,
            onPressed: _saveProfile,
          ),
        ],
      ),
    );
  }

  // 2. Buyurtma berish oynasi (Order Creation Form)
  Widget _buildOrderForm(TaxiProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.borderRadius,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Taksi Chaqirish",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Marshrut ma'lumotlarini kiriting va tugmani bosing",
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),

            // Qayerdan
            CustomTextField(
              controller: _fromController,
              hintText: "Masalan: G'ijduvon markaz",
              labelText: "Qayerdan",
              prefixIcon: Icons.my_location_rounded,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Jo'nash manzilini kiriting";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Qayerga
            CustomTextField(
              controller: _toController,
              hintText: "Masalan: Buxoro markaziy bozor",
              labelText: "Qayerga",
              prefixIcon: Icons.location_on_rounded,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Borish manzilini kiriting";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Izoh (Optional)
            CustomTextField(
              controller: _commentController,
              hintText: "Masalan: Sumkam bor, bagaj kerak",
              labelText: "Yo'l haqida qo'shimcha izoh (ixtiyoriy)",
              prefixIcon: Icons.chat_bubble_outline_rounded,
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Taksi Chaqirish Katta Tugma
            CustomButton(
              text: "Taksi chaqirish",
              icon: Icons.local_taxi_rounded,
              isLoading: provider.isLoading,
              onPressed: _submitOrder,
            ),
          ],
        ),
      ),
    );
  }

  // 3. Status Oynasi (Active Order Live Status)
  Widget _buildActiveOrderStatusSection(OrderModel order, TaxiProvider provider) {
    final isPending = order.status == OrderStatus.pending;
    final isAccepted = order.status == OrderStatus.accepted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Banner Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isAccepted
                ? AppTheme.successGreen.withOpacity(0.08)
                : AppTheme.accentGoldLight.withOpacity(0.6),
            borderRadius: AppTheme.borderRadius,
            border: Border.all(
              color: isAccepted ? AppTheme.successGreen : AppTheme.accentGold,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              if (isPending) ...[
                const SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD97706)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Taksi qidirilmoqda...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Atrofdagi haydovchilarga xabar yuborildi. Iltimos kuting...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ] else if (isAccepted) ...[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: AppTheme.successGreen,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Haydovchi qabul qildi!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Haydovchi: ${order.driverName ?? 'Noma\'lum'}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tel: ${order.driverPhone ?? '-'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Order Card component display
        OrderCard(
          order: order,
          isDriverView: false,
          onCancel: () => provider.cancelOrder(order.id),
        ),
      ],
    );
  }
}
