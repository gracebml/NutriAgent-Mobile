import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutricare_agents/screens/splash_screen.dart';
import 'package:nutricare_agents/utils/theme.dart';
import 'package:nutricare_agents/services/firebase_service.dart';
import 'package:flutter/foundation.dart'; // Thêm import này cho kIsWeb và kDebugMode
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  bool firebaseInitialized = false;
  int retryCount = 0;
  const maxRetries = 3;

  while (!firebaseInitialized && retryCount < maxRetries) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
      if (kDebugMode) {
        print('Firebase khởi tạo thành công');
      }
    } catch (e) {
      retryCount++;
      if (kDebugMode) {
        print('Lỗi khởi tạo Firebase (lần $retryCount/$maxRetries): $e');
      }
      if (retryCount < maxRetries) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }
  
  // Khởi tạo Hive
  await Hive.initFlutter();
  await Hive.openBox('userPreferences');
  await Hive.openBox('userProfile');
  await Hive.openBox('favorites');

  // Lưu trạng thái khởi tạo Firebase vào Hive
  final userBox = Hive.box('userPreferences');
  await userBox.put('firebaseInitialized', firebaseInitialized);

  runApp(
    ProviderScope(
      child: NutriCareApp(firebaseInitialized: firebaseInitialized),
    ),
  );
}

class NutriCareApp extends ConsumerWidget {
  final bool firebaseInitialized;

  const NutriCareApp({
    super.key,
    required this.firebaseInitialized,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'NutriCare Agents',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: SplashScreen(firebaseInitialized: firebaseInitialized),
    );
  }
}