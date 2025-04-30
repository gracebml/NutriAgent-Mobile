import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutricare_agents/screens/auth/register_screen.dart';
import 'package:nutricare_agents/screens/home_screen.dart';
import 'package:nutricare_agents/widgets/gradient_background.dart';
import 'package:nutricare_agents/widgets/testimonial_card.dart';
import 'package:nutricare_agents/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
    
    // Load saved email if any
    _loadSavedEmail();
  }
  
  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      if (savedEmail != null && savedEmail.isNotEmpty) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved email: $e');
      // Silently fail - not critical functionality
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Reset previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
    
    // Validate form
    if (!_formKey.currentState!.validate()) return;
    
    // Safety check for empty values - shouldn't happen due to validators
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) _emailError = 'Email không được để trống';
        if (password.isEmpty) _passwordError = 'Mật khẩu không được để trống';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Save email if remember me is checked
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_email');
      }
      
      // Attempt to sign in
      final userCredential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      
      // Check if sign-in was successful
      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Không tìm thấy tài khoản với email này.',
        );
      }
      
      // Successfully logged in - navigate to home screen
      // Update isLoggedIn status in Hive
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      // Also update Hive storage for consistency with splash screen check
      final userBox = await Hive.box('userPreferences');
      await userBox.put('isLoggedIn', true);
      
      // Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          _emailError = 'Email không hợp lệ hoặc không tồn tại';
        } else if (e.code == 'wrong-password') {
          _passwordError = 'Mật khẩu không chính xác';
        } else if (e.code == 'user-disabled') {
          _emailError = 'Tài khoản đã bị vô hiệu hóa';
        } else if (e.code == 'too-many-requests') {
          _emailError = 'Quá nhiều yêu cầu đăng nhập. Vui lòng thử lại sau.';
        } else {
          _emailError = 'Đăng nhập thất bại: ${e.message}';
        }
      });
    } catch (e) {
      debugPrint('Generic Error during login: $e');
      setState(() {
        _emailError = 'Lỗi không xác định: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient for the entire screen
          GradientBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isSmallScreen || !isLandscape) {
                    return _buildMobileLayout(context);
                  } else {
                    return _buildTabletLayout(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildLogo().animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 20),
            _buildLoginForm(context).animate().fadeIn(duration: 800.ms).slide(begin: const Offset(0, 20), curve: Curves.easeOutQuint),
            const SizedBox(height: 16),
            _buildSignUpLink().animate().fadeIn(duration: 600.ms, delay: 400.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Left side with decorative content (1/2 or 2/5 of screen)
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade800, 
                  Colors.green.shade600,
                  Colors.green.shade500,
                  const Color(0xFFE8F5E9),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(isTablet: true)
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(delay: 300.ms, duration: 600.ms),
                  
                  const Spacer(),
                  
                  // Testimonials
                  TestimonialCard(
                    quote: "Hệ thống AI này đã giúp tôi lập kế hoạch dinh dưỡng hiệu quả và khoa học hơn rất nhiều.",
                    author: "Sofia Davis - Chuyên gia dinh dưỡng",
                  ).animate().fadeIn(delay: 400.ms).slide(begin: const Offset(-20, 0)),
                  
                  const SizedBox(height: 20),
                  
                  TestimonialCard(
                    quote: "Đơn giản, hiệu quả và chính xác. Tôi đã đạt được mục tiêu sức khỏe của mình nhanh hơn dự kiến.",
                    author: "Minh Tuấn - Huấn luyện viên thể hình",
                  ).animate().fadeIn(delay: 600.ms).slide(begin: const Offset(-20, 0)),
                  
                  const Spacer(),
                  
                  // Footer
                  Text(
                    "© 2025 NutriCare Agents. Mọi quyền được bảo lưu.",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
        
        // Right side with login form (1/2 or 3/5 of screen)
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildLoginForm(context)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slide(begin: const Offset(0, 30), curve: Curves.easeOutQuint),
                    const SizedBox(height: 16),
                    _buildSignUpLink()
                      .animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLogo({bool isTablet = false}) {
    return Row(
      mainAxisSize: isTablet ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: isTablet ? 50 : 40,
          height: isTablet ? 50 : 40,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.restaurant_menu,
              color: isTablet ? Colors.white : Theme.of(context).primaryColor,
              size: isTablet ? 30 : 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "NutriCare Agents",
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: isTablet ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoginForm(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              "Chào mừng trở lại",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ).animate().fadeIn().slide(delay: 200.ms, begin: const Offset(0, -10)),
            
            const SizedBox(height: 8),
            
            Text(
              "Đăng nhập để tiếp tục hành trình dinh dưỡng của bạn",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ).animate().fadeIn().slide(delay: 300.ms, begin: const Offset(0, -10)),
            
            const SizedBox(height: 32),
            
            // Email field
            _buildInputLabel(
              icon: Icons.email_outlined,
              label: "Email",
              isFocused: _emailFocusNode.hasFocus,
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: InputDecoration(
                hintText: "email@example.com",
                errorText: _emailError,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ).animate().fadeIn(delay: 400.ms).slide(begin: const Offset(0, 10)),
            
            const SizedBox(height: 24),
            
            // Password field
            _buildInputLabel(
              icon: Icons.lock_outline,
              label: "Mật khẩu",
              isFocused: _passwordFocusNode.hasFocus,
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: "••••••••",
                errorText: _passwordError,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                return null;
              },
            ).animate().fadeIn(delay: 500.ms).slide(begin: const Offset(0, 10)),
            
            const SizedBox(height: 12),
            
            // "Remember me" checkbox and "Forgot password" link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Nhớ đăng nhập",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                
                TextButton(
                  onPressed: () {
                    // Navigate to forgot password
                    // Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    "Quên mật khẩu?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Login button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Đăng nhập",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
            ).animate().fadeIn(delay: 700.ms).scale(delay: 800.ms, duration: 400.ms),
            
            const SizedBox(height: 24),
            
            // Or continue with
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Hoặc tiếp tục với",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 24),
            
            // Social login buttons
            Row(
              children: [
                Expanded(
                  child: _buildSocialLoginButton(
                    icon: FontAwesomeIcons.google,
                    label: "Google",
                    color: Colors.red.shade600,
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        // Attempt sign in with Google
                        final userCredential = await _authService.signInWithGoogle();
                        
                        if (userCredential != null) {
                          // Update isLoggedIn status in SharedPreferences
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', true);
                          
                          // Also update Hive storage for consistency with splash screen check
                          final userBox = await Hive.box('userPreferences');
                          await userBox.put('isLoggedIn', true);
                          
                          // Navigate to home screen
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          }
                        }
                      } catch (e) {
                        debugPrint('Google Sign-In Error: $e');
                        setState(() {
                          _emailError = 'Đăng nhập Google thất bại: ${e.toString()}';
                        });
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSocialLoginButton(
                    icon: FontAwesomeIcons.facebook,
                    label: "Facebook",
                    color: Colors.blue.shade600,
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        // Attempt sign in with Facebook
                        await _authService.signInWithFacebook();
                        // Navigation handled by auth state listeners
                      } catch (e) {
                        debugPrint('Facebook Sign-In Error: $e');
                        setState(() {
                          _emailError = 'Đăng nhập Facebook thất bại: ${e.toString()}';
                        });
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputLabel({
    required IconData icon,
    required String label,
    required bool isFocused,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isFocused ? Theme.of(context).primaryColor : Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isFocused ? Theme.of(context).primaryColor : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSocialLoginButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Chưa có tài khoản? ",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            "Đăng ký ngay",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
              decorationThickness: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
