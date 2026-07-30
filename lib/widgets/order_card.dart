import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isDriverView;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const OrderCard({
    Key? key,
    required this.order,
    this.isDriverView = true,
    this.onAccept,
    this.onReject,
    this.onComplete,
    this.onCancel,
  }) : super(key: key);

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Telefon ilovasini ochib bo'lmadi: $phoneNumber");
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = order.status == OrderStatus.accepted;
    final isPending = order.status == OrderStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.borderRadius,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: isAccepted
              ? AppTheme.accentGold
              : AppTheme.borderLight,
          width: isAccepted ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Customer Name & Status / Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppTheme.primaryDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName.isNotEmpty
                              ? order.customerName
                              : "Mijoz",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          _formatTime(order.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Status Badge
                _buildStatusBadge(),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Divider(height: 1, color: AppTheme.borderLight),
            ),

            // Route details (Qayerdan -> Qayerga)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route Visual Indicator (Dots and Line)
                Column(
                  children: [
                    const Icon(Icons.circle, color: AppTheme.successGreen, size: 14),
                    Container(
                      width: 2,
                      height: 28,
                      color: AppTheme.borderLight,
                    ),
                    const Icon(Icons.location_on, color: AppTheme.accentGold, size: 18),
                  ],
                ),
                const SizedBox(width: 12),
                // Address Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "QAYERDAN",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        order.fromAddress,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "QAYERGA",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        order.toAddress,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Optional Comment Badge
            if (order.comment.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.bgLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Izoh: ${order.comment}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Driver Specific Action Buttons
            if (isDriverView) ...[
              if (isPending) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: const BorderSide(color: AppTheme.errorRed),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.borderRadius,
                          ),
                        ),
                        onPressed: onReject,
                        child: const Text(
                          "Rad etish",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Qabul qilish",
                        height: 48,
                        onPressed: onAccept,
                      ),
                    ),
                  ],
                ),
              ] else if (isAccepted) ...[
                // Phone Call & Complete Order buttons
                InkWell(
                  onTap: () => _makePhoneCall(order.customerPhone),
                  borderRadius: AppTheme.borderRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGoldLight,
                      borderRadius: AppTheme.borderRadius,
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_forwarded, color: AppTheme.primaryDark, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          "Mijozga qo'ng'iroq: ${order.customerPhone}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: "Safarni Yakunlash",
                  height: 48,
                  backgroundColor: AppTheme.successGreen,
                  textColor: Colors.white,
                  icon: Icons.check_circle_outline,
                  onPressed: onComplete,
                ),
              ],
            ] else ...[
              // Customer Specific Actions
              if (isPending) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.borderRadius,
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text("Buyurtmani bekor qilish"),
                  onPressed: onCancel,
                ),
              ] else if (isAccepted) ...[
                InkWell(
                  onTap: () => _makePhoneCall(order.driverPhone ?? ''),
                  borderRadius: AppTheme.borderRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: AppTheme.borderRadius,
                      border: Border.all(color: AppTheme.successGreen),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_in_talk, color: AppTheme.successGreen, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          "Haydovchiga qo'ng'iroq: ${order.driverPhone ?? ''}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeBg;
    Color badgeTextColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        badgeBg = AppTheme.accentGoldLight;
        badgeTextColor = const Color(0xFFB45309);
        statusText = "Qidirilmoqda...";
        break;
      case OrderStatus.accepted:
        badgeBg = AppTheme.successGreen.withOpacity(0.12);
        badgeTextColor = AppTheme.successGreen;
        statusText = "Qabul qilindi";
        break;
      case OrderStatus.completed:
        badgeBg = Colors.blue.withOpacity(0.12);
        badgeTextColor = Colors.blue;
        statusText = "Yakunlandi";
        break;
      case OrderStatus.cancelled:
        badgeBg = AppTheme.errorRed.withOpacity(0.12);
        badgeTextColor = AppTheme.errorRed;
        statusText = "Bekor qilindi";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: badgeTextColor,
        ),
      ),
    );
  }
}
