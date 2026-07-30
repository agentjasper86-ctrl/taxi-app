import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/taxi_provider.dart';
import '../theme/app_theme.dart';
import 'customer/customer_screen.dart';
import 'driver/driver_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Logo & App Name Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_taxi_rounded,
                    size: 56,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Tezkor Taksi",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                "Siz uchun qulay va xavfsiz taksi xizmati",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                      fontSize: 15,
                    ),
              ),

              const Spacer(),

              Text(
                "Tizimga kirish rolini tanlang:",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
              ),

              const SizedBox(height: 16),

              // Mijoz Role Card
              _RoleCard(
                title: "Mijoz sifatida",
                subtitle: "Taksi chaqirish va yo'nalishni kuzatish",
                icon: Icons.person_pin_circle_outlined,
                accentColor: AppTheme.accentGold,
                onTap: () {
                  context.read<TaxiProvider>().setRole(UserRole.customer);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Haydovchi Role Card
              _RoleCard(
                title: "Haydovchi sifatida",
                subtitle: "Buyurtmalarni qabul qilish va daromad topish",
                icon: Icons.directions_car_filled_outlined,
                accentColor: AppTheme.primaryDark,
                onTap: () {
                  context.read<TaxiProvider>().setRole(UserRole.driver);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DriverScreen()),
                  );
                },
              ),

              const Spacer(),

              const Text(
                "Flutter & Firebase powered • v1.0.0",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadius,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: AppTheme.borderRadius,
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color: AppTheme.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: accentColor == AppTheme.accentGold
                      ? const Color(0xFFD97706)
                      : accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
