import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutricare_agents/screens/auth/login_screen.dart';
import 'package:nutricare_agents/screens/settings_screen.dart';
import 'package:nutricare_agents/utils/theme.dart';
import 'package:nutricare_agents/widgets/search_bar.dart';
import 'package:nutricare_agents/models/menu_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    final userBox = Hive.box('userProfile');
    final currentUser = userBox.get('currentUser');
    
    if (currentUser != null && currentUser is Map) {
      setState(() {
        _userName = currentUser['name'] ?? 'User';
      });
    }
  }
  
  Future<void> _logout() async {
    final userBox = Hive.box('userPreferences');
    await userBox.put('isLoggedIn', false);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: () => _onNavItemTapped(index),
    );
  }

  Widget _buildDashboardContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: AppTextStyles.body1,
                        ),
                        Text(
                          _userName.isNotEmpty ? _userName : 'User',
                          style: AppTextStyles.heading2,
                        ),
                        Text(
                          'Hôm nay bạn muốn ăn gì?',
                          style: AppTextStyles.body1.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Search bar
          CustomSearchBar(
            controller: _searchController,
            onChanged: (value) {
              // Implement search functionality
            },
          ),
          const SizedBox(height: 24),
          
          // Quick actions
          Text(
            'Khám phá',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildQuickActionCard(
                'Tạo thực đơn',
                Icons.restaurant_menu,
                colorScheme.primary,
                () {
                  // Navigate to menu generator
                },
              ),
              _buildQuickActionCard(
                'Tư vấn dinh dưỡng',
                Icons.chat_bubble_outline,
                colorScheme.secondary,
                () {
                  // Navigate to nutrition chat
                },
              ),
              _buildQuickActionCard(
                'Theo dõi calo',
                Icons.pie_chart,
                colorScheme.tertiary,
                () {
                  // Navigate to calorie tracker
                },
              ),
              _buildQuickActionCard(
                'Công thức nấu ăn',
                Icons.book_outlined,
                Colors.orange,
                () {
                  // Navigate to recipes
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recommended meals
          Text(
            'Gợi ý cho bạn',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMealCard(
                  'Salad gà nướng',
                  'Bữa trưa lành mạnh, giàu protein',
                  '320 kcal',
                  'assets/images/chicken_salad.jpg',
                ),
                _buildMealCard(
                  'Cá hồi áp chảo',
                  'Giàu omega-3, tốt cho tim mạch',
                  '450 kcal',
                  'assets/images/salmon.jpg',
                ),
                _buildMealCard(
                  'Sinh tố rau củ',
                  'Đầy đủ vitamin và khoáng chất',
                  '180 kcal',
                  'assets/images/smoothie.jpg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMealCard(
    String title,
    String description,
    String calories,
    String imageAsset,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 120,
              color: colorScheme.primaryContainer,
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.body1.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    calories,
                    style: AppTextStyles.body1.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Kế hoạch ăn uống',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Tính năng đang được phát triển',
            style: AppTextStyles.body1,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Thông tin dinh dưỡng',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Tính năng đang được phát triển',
            style: AppTextStyles.body1,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Hồ sơ người dùng',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Tính năng đang được phát triển',
            style: AppTextStyles.body1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    
    // Danh sách các widget chính cho từng tab
    final List<Widget> _mainScreens = [
      _buildDashboardContent(),
      _buildMealPlanContent(),
      _buildNutritionContent(),
      _buildProfileContent(),
    ];
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar navigation (visible on desktop)
            if (isDesktop)
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                child: Container(
                  width: 250,
                  height: double.infinity,
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      // App logo and title
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.restaurant_menu,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'NutriCare',
                              style: AppTextStyles.heading3.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      
                      // User info
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Xin chào, $_userName',
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      
                      // Navigation items
                      _buildNavItem(0, 'Trang chủ', Icons.dashboard),
                      _buildNavItem(1, 'Kế hoạch ăn', Icons.calendar_today),
                      _buildNavItem(2, 'Dinh dưỡng', Icons.pie_chart),
                      _buildNavItem(3, 'Hồ sơ', Icons.person),
                      
                      const Spacer(),
                      const Divider(),
                      
                      // Settings and logout
                      ListTile(
                        leading: Icon(Icons.settings, color: colorScheme.onSurfaceVariant),
                        title: Text(
                          'Cài đặt',
                          style: AppTextStyles.body1,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: colorScheme.error),
                        title: Text(
                          'Đăng xuất',
                          style: AppTextStyles.body1.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                        onTap: _logout,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            
            // Main content
            Expanded(
              child: Column(
                children: [
                  // App bar (only for mobile)
                  if (!isDesktop)
                    AppBar(
                      title: const Text('NutriCare Agents'),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  
                  // Main content area
                  Expanded(
                    child: _mainScreens[_selectedIndex],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom navigation (only for mobile)
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavItemTapped,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Trang chủ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Kế hoạch',
                ),
                NavigationDestination(
                  icon: Icon(Icons.pie_chart_outline),
                  selectedIcon: Icon(Icons.pie_chart),
                  label: 'Dinh dưỡng',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Hồ sơ',
                ),
              ],
            ),
    );
  }
}