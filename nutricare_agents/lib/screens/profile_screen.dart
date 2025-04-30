import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutricare_agents/utils/theme.dart';
import 'package:nutricare_agents/widgets/custom_button.dart';

class UserProfile {
  String name;
  int age;
  String gender;
  double height;
  double weight;
  List<String> dietaryRestrictions;
  List<String> healthGoals;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.dietaryRestrictions,
    required this.healthGoals,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      height: json['height'] as double,
      weight: json['weight'] as double,
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions']),
      healthGoals: List<String>.from(json['healthGoals']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'dietaryRestrictions': dietaryRestrictions,
      'healthGoals': healthGoals,
    };
  }

  // Tính BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Phân loại BMI
  String get bmiCategory {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _userProfile;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final profileBox = Hive.box('userProfile');
    final profileData = profileBox.get('profile');

    if (profileData != null) {
      setState(() {
        _userProfile = UserProfile.fromJson(Map<String, dynamic>.from(profileData));
      });
    } else {
      // Tạo profile mẫu nếu chưa có
      setState(() {
        _userProfile = UserProfile(
          name: 'Người dùng',
          age: 30,
          gender: 'Nam',
          height: 170,
          weight: 65,
          dietaryRestrictions: ['Không'],
          healthGoals: ['Duy trì cân nặng'],
        );
      });
      _saveUserProfile();
    }
  }

  Future<void> _saveUserProfile() async {
    final profileBox = Hive.box('userProfile');
    await profileBox.put('profile', _userProfile.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _saveUserProfile();
                  setState(() {
                    _isEditing = false;
                  });
                }
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar và thông tin cơ bản
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isEditing
                        ? TextFormField(
                            initialValue: _userProfile.name,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _userProfile.name = value!;
                            },
                          )
                        : Text(
                            _userProfile.name,
                            style: AppTextStyles.heading1,
                          ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Thông tin chi tiết
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin cá nhân',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 16),
                      
                      // Tuổi
                      _buildProfileField(
                        label: 'Tuổi',
                        value: _userProfile.age.toString(),
                        isEditing: _isEditing,
                        onSaved: (value) {
                          _userProfile.age = int.parse(value!);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tuổi';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Tuổi phải là số';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      
                      // Giới tính
                      _isEditing
                          ? DropdownButtonFormField<String>(
                              value: _userProfile.gender,
                              decoration: const InputDecoration(
                                labelText: 'Giới tính',
                              ),
                              items: ['Nam', 'Nữ', 'Khác'].map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _userProfile.gender = value!;
                                });
                              },
                            )
                          : _buildInfoRow('Giới tính', _userProfile.gender),
                      
                      // Chiều cao
                      _buildProfileField(
                        label: 'Chiều cao (cm)',
                        value: _userProfile.height.toString(),
                        isEditing: _isEditing,
                        onSaved: (value) {
                          _userProfile.height = double.parse(value!);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập chiều cao';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Chiều cao phải là số';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      
                      // Cân nặng
                      _buildProfileField(
                        label: 'Cân nặng (kg)',
                        value: _userProfile.weight.toString(),
                        isEditing: _isEditing,
                        onSaved: (value) {
                          _userProfile.weight = double.parse(value!);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập cân nặng';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Cân nặng phải là số';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Thông tin BMI
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chỉ số BMI',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BMI hiện tại:',
                                style: AppTextStyles.body1,
                              ),
                              Text(
                                _userProfile.bmi.toStringAsFixed(1),
                                style: AppTextStyles.heading1.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Phân loại:',
                                style: AppTextStyles.body1,
                              ),
                              Text(
                                _userProfile.bmiCategory,
                                style: AppTextStyles.heading3.copyWith(
                                  color: _getBmiCategoryColor(_userProfile.bmiCategory),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Thông tin chế độ ăn
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chế độ ăn',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 16),
                      
                      // Hạn chế ăn uống
                      _isEditing
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hạn chế ăn uống:'),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    'Không',
                                    'Chay',
                                    'Không gluten',
                                    'Không lactose',
                                    'Không đường',
                                    'Không hải sản',
                                  ].map((restriction) {
                                    final isSelected = _userProfile.dietaryRestrictions.contains(restriction);
                                    return FilterChip(
                                      label: Text(restriction),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            if (restriction == 'Không') {
                                              _userProfile.dietaryRestrictions = ['Không'];
                                            } else {
                                              _userProfile.dietaryRestrictions.remove('Không');
                                              _userProfile.dietaryRestrictions.add(restriction);
                                            }
                                          } else {
                                            _userProfile.dietaryRestrictions.remove(restriction);
                                            if (_userProfile.dietaryRestrictions.isEmpty) {
                                              _userProfile.dietaryRestrictions.add('Không');
                                            }
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            )
                          : _buildInfoRow(
                              'Hạn chế ăn uống',
                              _userProfile.dietaryRestrictions.join(', '),
                            ),
                      
                      const SizedBox(height: 16),
                      
                      // Mục tiêu sức khỏe
                      _isEditing
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mục tiêu sức khỏe:'),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    'Duy trì cân nặng',
                                    'Giảm cân',
                                    'Tăng cân',
                                    'Tăng cơ',
                                    'Cải thiện sức khỏe tim mạch',
                                    'Kiểm soát đường huyết',
                                  ].map((goal) {
                                    final isSelected = _userProfile.healthGoals.contains(goal);
                                    return FilterChip(
                                      label: Text(goal),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _userProfile.healthGoals.add(goal);
                                          } else {
                                            _userProfile.healthGoals.remove(goal);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            )
                          : _buildInfoRow(
                              'Mục tiêu sức khỏe',
                              _userProfile.healthGoals.join(', '),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required bool isEditing,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return isEditing
        ? TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
            ),
            keyboardType: keyboardType,
            validator: validator,
            onSaved: onSaved,
          )
        : _buildInfoRow(label, value);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body1,
          ),
        ],
      ),
    );
  }

  Color _getBmiCategoryColor(String category) {
    switch (category) {
      case 'Thiếu cân':
        return Colors.blue;
      case 'Bình thường':
        return Colors.green;
      case 'Thừa cân':
        return Colors.orange;
      case 'Béo phì':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}