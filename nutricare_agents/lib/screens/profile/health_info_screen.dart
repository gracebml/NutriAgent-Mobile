import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutricare_agents/providers/health_profile_provider.dart';
import 'package:nutricare_agents/widgets/profile/health_form_stepper.dart';
import 'package:nutricare_agents/widgets/gradient_background.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HealthInfoScreen extends StatefulWidget {
  const HealthInfoScreen({Key? key}) : super(key: key);

  @override
  State<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen> {
  bool _isLoading = true;
  bool _isCompleted = false;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _loadHealthProfile();
  }

  Future<void> _loadHealthProfile() async {
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isGuest = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<HealthProfileProvider>(context, listen: false);
    await provider.loadHealthProfile();

    setState(() {
      _isLoading = false;
    });
  }

  void _handleComplete(bool success) {
    setState(() {
      _isCompleted = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isGuest) {
      return _buildGuestView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin Sức khỏe'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingView()
              : _isCompleted
                  ? _buildCompletedView()
                  : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin Sức khỏe'),
        centerTitle: true,
      ),
      body: GradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 24),
                Text(
                  'Bạn cần đăng nhập',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Đăng nhập để nhập và lưu thông tin sức khỏe của bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  icon: Icon(Icons.login),
                  label: Text('Đăng nhập ngay'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Quay lại'),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Lottie.asset(
              'assets/animations/health_loading.json', // Make sure this animation exists
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Đang tải thông tin sức khỏe...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.green,
              ),
            ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                  delay: 300.ms,
                ),
            SizedBox(height: 32),
            Text(
              'Lưu thành công!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Thông tin sức khỏe của bạn đã được lưu và sẽ được sử dụng để tạo thực đơn phù hợp.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isCompleted = false;
                });
              },
              icon: Icon(Icons.edit),
              label: Text('Chỉnh sửa thông tin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.home),
              label: Text('Quay lại trang chủ'),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }

  Widget _buildFormView() {
    return Consumer<HealthProfileProvider>(
      builder: (context, provider, child) {
        final error = provider.error;
        
        return Column(
          children: [
            // Show error message if any
            if (error != null)
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        provider.clearError();
                      },
                      icon: Icon(Icons.close, size: 18),
                      color: Colors.red.shade800,
                    ),
                  ],
                ),
              ),
              
            // Health form stepper
            Expanded(
              child: HealthFormStepper(
                onComplete: _handleComplete,
              ),
            ),
          ],
        );
      },
    );
  }
}