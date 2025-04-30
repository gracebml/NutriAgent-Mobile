import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutricare_agents/screens/auth/login_screen.dart';
import 'package:nutricare_agents/screens/home_screen.dart';
import 'package:nutricare_agents/utils/theme.dart';

class SplashScreen extends StatefulWidget {
  final bool firebaseInitialized;
  
  const SplashScreen({
    super.key,
    required this.firebaseInitialized,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Kiểm tra trạng thái đăng nhập và điều hướng sau 2.5 giây
    Future.delayed(const Duration(milliseconds: 2500), () {
      _checkLoginStatus();
    });
  }

  // Kiểm tra trạng thái đăng nhập từ Hive
  void _checkLoginStatus() {
    // Kiểm tra xem Firebase đã được khởi tạo thành công chưa
    if (!widget.firebaseInitialized) {
      // Hiển thị thông báo lỗi nếu Firebase chưa được khởi tạo
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Lỗi khởi tạo'),
          content: const Text(
            'Không thể kết nối đến Firebase. Vui lòng kiểm tra kết nối mạng và khởi động lại ứng dụng.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Đóng ứng dụng
                Navigator.of(context).pop();
                // Trong môi trường thực tế, bạn có thể muốn sử dụng SystemNavigator.pop() để thoát ứng dụng
              },
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      return;
    }
    
    final userBox = Hive.box('userPreferences');
    final isLoggedIn = userBox.get('isLoggedIn', defaultValue: false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo ứng dụng
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 60,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tên ứng dụng
                    Text(
                      'NutriCare Agents',
                      style: AppTextStyles.heading1.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Khẩu hiệu ứng dụng
                    Text(
                      'Dinh dưỡng cá nhân hoá',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Hiệu ứng loading
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    
                    // Phiên bản ứng dụng
                    const SizedBox(height: 24),
                    Text(
                      'Phiên bản 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
