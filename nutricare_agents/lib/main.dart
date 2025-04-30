import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricare_agents/screens/splash_screen.dart';
import 'package:nutricare_agents/utils/theme.dart';
import 'package:flutter/foundation.dart'; // Thêm import này cho kIsWeb và kDebugMode
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:nutricare_agents/services/auth_service.dart';
import 'package:provider/provider.dart' as provider;
import 'package:nutricare_agents/providers/health_profile_provider.dart';
import 'package:nutricare_agents/screens/profile/health_info_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive trước Firebase để lưu trữ cục bộ
  await Hive.initFlutter();
  await Hive.openBox('userPreferences');
  await Hive.openBox('userProfile');
  await Hive.openBox('favorites');

  // Khởi tạo Firebase
  bool firebaseInitialized = false;
  int retryCount = 0;
  const maxRetries = 3;

  while (!firebaseInitialized && retryCount < maxRetries) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Cấu hình Firestore để hoạt động offline
      FirebaseFirestore.instance.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Thử kết nối đến Firestore để kiểm tra (có thể bỏ qua nếu muốn tối ưu cho web)
      try {
        await FirebaseFirestore.instance.collection('users').limit(1).get();
        if (kDebugMode) {
          print('Kết nối Firestore thành công');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Cảnh báo: Không thể kết nối đến Firestore: $e');
        }
        // Vẫn coi là khởi tạo thành công vì Firebase Auth có thể vẫn hoạt động
      }

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

  // Khởi tạo AuthService sau khi Firebase đã được khởi tạo
  final authService = AuthService();
  await authService.init();

  // Lưu trạng thái khởi tạo Firebase vào Hive
  final userBox = Hive.box('userPreferences');
  await userBox.put('firebaseInitialized', firebaseInitialized);

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => HealthProfileProvider()),
        // Add other providers here if needed
      ],
      child: ProviderScope(
        child: NutriCareApp(
          firebaseInitialized: firebaseInitialized,
          hasInternetConnection: true, // Luôn true vì không kiểm tra nữa
        ),
      ),
    ),
  );
}

class NutriCareApp extends ConsumerWidget {
  final bool firebaseInitialized;
  final bool hasInternetConnection;

  const NutriCareApp({
    super.key,
    required this.firebaseInitialized,
    required this.hasInternetConnection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'NutriCare Agents',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: SplashScreen(
        firebaseInitialized: firebaseInitialized,
      ),
      routes: {
        '/health_info': (context) => const HealthInfoScreen(),
        // Add other routes here if needed
      },
    );
  }
}
