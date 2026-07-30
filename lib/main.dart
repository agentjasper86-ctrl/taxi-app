import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/taxi_provider.dart';
import 'screens/role_selection_screen.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization check
  try {
    await Firebase.initializeApp();
    FirebaseService.instance.markInitialized();
    debugPrint("Firebase muvaffaqiyatli ishga tushirildi.");
  } catch (e) {
    debugPrint("Firebase rejimida ogohlantirish (Demo Mode ishlamoqda): $e");
  }

  runApp(const TaxiApp());
}

class TaxiApp extends StatelessWidget {
  const TaxiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaxiProvider()),
      ],
      child: MaterialApp(
        title: 'Tezkor Taksi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const RoleSelectionScreen(),
      ),
    );
  }
}
