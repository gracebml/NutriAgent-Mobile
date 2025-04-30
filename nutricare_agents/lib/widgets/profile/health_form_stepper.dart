import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nutricare_agents/models/health_profile.dart';
import 'package:nutricare_agents/providers/health_profile_provider.dart';

class HealthFormStepper extends StatefulWidget {
  final void Function(bool) onComplete;

  const HealthFormStepper({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<HealthFormStepper> createState() => _HealthFormStepperState();
}

class _HealthFormStepperState extends State<HealthFormStepper> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _dietaryRestrictionsController = TextEditingController();
  final _preferencesController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _goalsController = TextEditingController();
  
  // Focus nodes for styling and validation
  final _nameFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  final _heightFocusNode = FocusNode();
  final _weightFocusNode = FocusNode();
  final _allergiesFocusNode = FocusNode();
  final _dietaryRestrictionsFocusNode = FocusNode();
  final _preferencesFocusNode = FocusNode();
  final _medicalConditionsFocusNode = FocusNode();
  final _goalsFocusNode = FocusNode();
  
  Gender? _selectedGender;
  ActivityLevel? _selectedActivityLevel;
  
  // Step definitions
  final List<Map<String, dynamic>> _steps = [
    {
      'id': 0,
      'name': 'Thông tin Cá nhân',
      'icon': Icons.person_outline,
      'fields': ['name', 'age', 'gender'],
    },
    {
      'id': 1,
      'name': 'Chỉ số Cơ thể',
      'icon': Icons.monitor_weight_outlined,
      'fields': ['height', 'weight'],
    },
    {
      'id': 2,
      'name': 'Mức độ Vận động',
      'icon': Icons.directions_run_outlined,
      'fields': ['activityLevel'],
    },
    {
      'id': 3,
      'name': 'Thông tin Dinh dưỡng',
      'icon': Icons.restaurant_outlined,
      'fields': ['allergies', 'dietaryRestrictions', 'preferences'],
    },
    {
      'id': 4,
      'name': 'Sức khỏe & Mục tiêu',
      'icon': Icons.flag_outlined,
      'fields': ['medicalConditions', 'goals'],
    },
  ];
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Update focus nodes
    _setupFocusNodes();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize form data from provider
    if (!_isInitialized) {
      _initializeFormData();
      _isInitialized = true;
    }
  }
  
  void _setupFocusNodes() {
    // Add listeners to focus nodes for UI updates
    _nameFocusNode.addListener(() {
      setState(() {});
    });
    _ageFocusNode.addListener(() {
      setState(() {});
    });
    _heightFocusNode.addListener(() {
      setState(() {});
    });
    _weightFocusNode.addListener(() {
      setState(() {});
    });
    _allergiesFocusNode.addListener(() {
      setState(() {});
    });
    _dietaryRestrictionsFocusNode.addListener(() {
      setState(() {});
    });
    _preferencesFocusNode.addListener(() {
      setState(() {});
    });
    _medicalConditionsFocusNode.addListener(() {
      setState(() {});
    });
    _goalsFocusNode.addListener(() {
      setState(() {});
    });
  }
  
  void _initializeFormData() {
    final provider = Provider.of<HealthProfileProvider>(context, listen: false);
    final profile = provider.healthProfile;
    
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age?.toString() ?? '';
      _selectedGender = profile.gender;
      _heightController.text = profile.height?.toString() ?? '';
      _weightController.text = profile.weight?.toString() ?? '';
      _selectedActivityLevel = profile.activityLevel;
      _allergiesController.text = profile.allergies ?? '';
      _dietaryRestrictionsController.text = profile.dietaryRestrictions ?? '';
      _preferencesController.text = profile.preferences ?? '';
      _medicalConditionsController.text = profile.medicalConditions ?? '';
      _goalsController.text = profile.goals ?? '';
    }
  }
  
  void _saveCurrentStep() {
    final provider = Provider.of<HealthProfileProvider>(context, listen: false);
    final currentStep = provider.currentStep;
    
    // Validate and save based on current step
    switch (currentStep) {
      case 0: // Personal Information
        provider.updateProfile(
          name: _nameController.text,
          age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
          gender: _selectedGender,
        );
        break;
      case 1: // Body Metrics
        provider.updateProfile(
          height: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
          weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
        );
        break;
      case 2: // Activity Level
        provider.updateProfile(
          activityLevel: _selectedActivityLevel,
        );
        break;
      case 3: // Nutritional Information
        provider.updateProfile(
          allergies: _allergiesController.text,
          dietaryRestrictions: _dietaryRestrictionsController.text,
          preferences: _preferencesController.text,
        );
        break;
      case 4: // Health & Goals
        provider.updateProfile(
          medicalConditions: _medicalConditionsController.text,
          goals: _goalsController.text,
        );
        break;
    }
  }
  
  Future<void> _submitForm() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) return;
    
    // Save the last step
    _saveCurrentStep();
    
    // Save to Firestore
    final provider = Provider.of<HealthProfileProvider>(context, listen: false);
    final success = await provider.saveHealthProfile();
    
    if (success) {
      widget.onComplete(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thông tin sức khỏe đã được lưu thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Đã xảy ra lỗi khi lưu thông tin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _dietaryRestrictionsController.dispose();
    _preferencesController.dispose();
    _medicalConditionsController.dispose();
    _goalsController.dispose();
    
    // Dispose focus nodes
    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    _allergiesFocusNode.dispose();
    _dietaryRestrictionsFocusNode.dispose();
    _preferencesFocusNode.dispose();
    _medicalConditionsFocusNode.dispose();
    _goalsFocusNode.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProfileProvider>(
      builder: (context, provider, child) {
        final currentStep = provider.currentStep;
        final completedSteps = provider.completedSteps;
        
        return Column(
          children: [
            // Step indicator
            _buildStepIndicator(currentStep, completedSteps),
            
            SizedBox(height: 24),
            
            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: _buildStepContent(currentStep),
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(currentStep, provider),
          ],
        );
      },
    );
  }
  
  Widget _buildStepIndicator(int currentStep, Set<int> completedSteps) {
    return Container(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          final step = _steps[index];
          final isCompleted = completedSteps.contains(index);
          final isActive = currentStep == index;
          
          return GestureDetector(
            onTap: () {
              // Only allow navigation to completed steps or the next step
              if (isCompleted || index <= currentStep) {
                Provider.of<HealthProfileProvider>(context, listen: false).goToStep(index);
              }
            },
            child: Container(
              width: 80,
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step icon with circle
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : isCompleted
                              ? Colors.green
                              : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : Icon(
                              step['icon'] as IconData,
                              color: isActive ? Colors.white : Colors.grey.shade600,
                              size: 20,
                            ),
                    ),
                  ).animate()
                      .scale(
                        duration: 400.ms,
                        delay: 100.ms,
                        curve: Curves.easeOutBack,
                        begin: Offset(isActive ? 0.9 : 1.0, isActive ? 0.9 : 1.0),
                        end: Offset(isActive ? 1.1 : 1.0, isActive ? 1.1 : 1.0),
                      ),
                  
                  SizedBox(height: 8),
                  
                  // Step name
                  Text(
                    step['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStepContent(int step) {
    // Return the appropriate form content based on the current step
    switch (step) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildBodyMetricsStep();
      case 2:
        return _buildActivityLevelStep();
      case 3:
        return _buildNutritionalInfoStep();
      case 4:
        return _buildHealthGoalsStep();
      default:
        return Container(
          child: Center(
            child: Text('Bước không hợp lệ'),
          ),
        );
    }
  }
  
  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin Cá nhân',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          
          // Name field
          _buildInputLabel(
            icon: Icons.person_outline,
            label: 'Họ và Tên',
            isFocused: _nameFocusNode.hasFocus,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              hintText: 'Nhập họ và tên của bạn',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tên của bạn';
              }
              if (value.length < 2) {
                return 'Tên phải có ít nhất 2 ký tự';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          
          // Age field
          _buildInputLabel(
            icon: Icons.cake_outlined,
            label: 'Tuổi',
            isFocused: _ageFocusNode.hasFocus,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _ageController,
            focusNode: _ageFocusNode,
            decoration: InputDecoration(
              hintText: 'Nhập tuổi của bạn',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final age = int.tryParse(value);
                if (age == null) {
                  return 'Vui lòng nhập một số';
                }
                if (age <= 0 || age > 120) {
                  return 'Vui lòng nhập tuổi hợp lệ';
                }
              }
              return null; // Age is optional
            },
          ),
          SizedBox(height: 24),
          
          // Gender selection
          _buildInputLabel(
            icon: Icons.people_outline,
            label: 'Giới tính',
            isFocused: false,
          ),
          SizedBox(height: 8),
          Column(
            children: Gender.values.map((gender) {
              return RadioListTile<Gender>(
                title: Text(genderToString(gender)),
                value: gender,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                dense: true,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBodyMetricsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chỉ số Cơ thể',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          
          // Height field
          _buildInputLabel(
            icon: Icons.height_outlined,
            label: 'Chiều cao (cm)',
            isFocused: _heightFocusNode.hasFocus,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _heightController,
            focusNode: _heightFocusNode,
            decoration: InputDecoration(
              hintText: 'Ví dụ: 170',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final height = double.tryParse(value);
                if (height == null) {
                  return 'Vui lòng nhập một số';
                }
                if (height <= 0 || height > 250) {
                  return 'Vui lòng nhập chiều cao hợp lệ';
                }
              }
              return null; // Height is optional
            },
          ),
          SizedBox(height: 24),
          
          // Weight field
          _buildInputLabel(
            icon: Icons.monitor_weight_outlined,
            label: 'Cân nặng (kg)',
            isFocused: _weightFocusNode.hasFocus,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _weightController,
            focusNode: _weightFocusNode,
            decoration: InputDecoration(
              hintText: 'Ví dụ: 65',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final weight = double.tryParse(value);
                if (weight == null) {
                  return 'Vui lòng nhập một số';
                }
                if (weight <= 0 || weight > 300) {
                  return 'Vui lòng nhập cân nặng hợp lệ';
                }
              }
              return null; // Weight is optional
            },
          ),
          SizedBox(height: 24),
          
          // Display BMI if both height and weight are entered
          Builder(
            builder: (context) {
              final height = double.tryParse(_heightController.text);
              final weight = double.tryParse(_weightController.text);
              
              if (height != null && weight != null && height > 0) {
                final heightInMeters = height / 100;
                final bmi = weight / (heightInMeters * heightInMeters);
                
                String bmiCategory;
                Color bmiColor;
                
                if (bmi < 18.5) {
                  bmiCategory = 'Thiếu cân';
                  bmiColor = Colors.blue;
                } else if (bmi < 25) {
                  bmiCategory = 'Bình thường';
                  bmiColor = Colors.green;
                } else if (bmi < 30) {
                  bmiCategory = 'Thừa cân';
                  bmiColor = Colors.orange;
                } else {
                  bmiCategory = 'Béo phì';
                  bmiColor = Colors.red;
                }
                
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bmiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bmiColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chỉ số BMI của bạn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bmi.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: bmiColor,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: bmiColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              bmiCategory,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityLevelStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mức độ Vận động',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          Text(
            'Chọn mức độ phù hợp nhất với lối sống của bạn:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 24),
          
          // Activity level cards
          ..._buildActivityLevelCards(),
          
          SizedBox(height: 24),
          
          // Calorie estimation
          Builder(
            builder: (context) {
              final provider = Provider.of<HealthProfileProvider>(context, listen: false);
              final profile = provider.healthProfile;
              
              if (profile != null && 
                  profile.age != null && 
                  profile.gender != null &&
                  profile.height != null && 
                  profile.weight != null &&
                  _selectedActivityLevel != null) {
                
                // Create a temporary profile with current selection
                final tempProfile = profile.copyWith(
                  activityLevel: _selectedActivityLevel,
                );
                
                final calories = tempProfile.calculateDailyCalories();
                
                if (calories != null) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_outlined,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Nhu cầu Calo ước tính',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$calories kcal / ngày',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dựa trên độ tuổi, giới tính, chiều cao, cân nặng và mức độ vận động của bạn',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildActivityLevelCards() {
    final activityLevels = [
      {
        'level': ActivityLevel.sedentary,
        'title': 'Ít vận động',
        'icon': Icons.weekend_outlined,
        'description': 'Chủ yếu ngồi hoặc nằm, ít hoặc không tập thể dục.',
      },
      {
        'level': ActivityLevel.light,
        'title': 'Vận động nhẹ',
        'icon': Icons.directions_walk_outlined,
        'description': 'Tập thể dục nhẹ 1-3 ngày/tuần.',
      },
      {
        'level': ActivityLevel.moderate,
        'title': 'Vận động vừa phải',
        'icon': Icons.directions_run_outlined,
        'description': 'Tập thể dục vừa phải 3-5 ngày/tuần.',
      },
      {
        'level': ActivityLevel.active,
        'title': 'Vận động tích cực',
        'icon': Icons.fitness_center_outlined,
        'description': 'Tập thể dục nặng 6-7 ngày/tuần.',
      },
      {
        'level': ActivityLevel.extraActive,
        'title': 'Vận động rất tích cực',
        'icon': Icons.sports_gymnastics_outlined,
        'description': 'Tập thể dục nặng + công việc thể chất hoặc tập luyện 2 lần/ngày.',
      },
    ];
    
    return activityLevels.map((activity) {
      final level = activity['level'] as ActivityLevel;
      final isSelected = _selectedActivityLevel == level;
      
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedActivityLevel = level;
          });
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      activity['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  Widget _buildNutritionalInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin Dinh dưỡng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          
          // Allergies field
          _buildInputLabel(
            icon: Icons.no_meals_outlined,
            label: 'Dị ứng thực phẩm (nếu có)',
            isFocused: _allergiesFocusNode.hasFocus,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _allergiesController,
            focusNode: _allergiesFocusNode,
            decoration: InputDecoration(
              hintText: 'Vd: đậu phộng, hải sản, sữa...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 24),
          
          // Dietary restrictions field
          _buildInputLabel(
            icon: Icons.block_outlined,
            label: 'Hạn chế ăn uống (nếu có)',
            isFocused: _dietaryRestrictionsFocusNode.hasFocus,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _dietaryRestrictionsController,
            focusNode: _dietaryRestrictionsFocusNode,
            decoration: InputDecoration(
              hintText: 'Vd: ăn chay, không dung nạp lactose, không ăn thịt đỏ...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 24),
          
          // Preferences field
          _buildInputLabel(
            icon: Icons.favorite_outline,
            label: 'Sở thích ăn uống',
            isFocused: _preferencesFocusNode.hasFocus,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _preferencesController,
            focusNode: _preferencesFocusNode,
            decoration: InputDecoration(
              hintText: 'Mô tả các món ăn bạn yêu thích hoặc không thích...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }
  
  Widget _buildHealthGoalsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sức khỏe & Mục tiêu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          
          // Medical conditions field
          _buildInputLabel(
            icon: Icons.medical_services_outlined,
            label: 'Tình trạng sức khỏe liên quan (nếu có)',
            isFocused: _medicalConditionsFocusNode.hasFocus,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _medicalConditionsController,
            focusNode: _medicalConditionsFocusNode,
            decoration: InputDecoration(
              hintText: 'Vd: tiểu đường, huyết áp cao, bệnh tim...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 24),
          
          // Goals field
          _buildInputLabel(
            icon: Icons.flag_outlined,
            label: 'Mục tiêu dinh dưỡng/sức khỏe',
            isFocused: _goalsFocusNode.hasFocus,
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _goalsController,
            focusNode: _goalsFocusNode,
            decoration: InputDecoration(
              hintText: 'Vd: giảm cân, tăng cơ, ăn uống lành mạnh hơn...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 4,
          ),
          SizedBox(height: 24),
          
          // Summary of completed information
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tóm tắt thông tin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Bạn đã hoàn thành việc nhập thông tin sức khỏe! Nhấn "Hoàn tất & Lưu" để lưu thông tin của bạn.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Thông tin này sẽ giúp chúng tôi tạo ra thực đơn phù hợp hơn với nhu cầu của bạn.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        SizedBox(width: 8),
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
  
  Widget _buildNavigationButtons(int currentStep, HealthProfileProvider provider) {
    final isLastStep = currentStep == _steps.length - 1;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          TextButton.icon(
            onPressed: currentStep > 0
                ? () {
                    _saveCurrentStep();
                    provider.previousStep();
                  }
                : null,
            icon: Icon(Icons.arrow_back),
            label: Text('Quay lại'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              disabledForegroundColor: Colors.grey.shade400,
            ),
          ),
          
          // Next or Submit button
          ElevatedButton.icon(
            onPressed: () {
              _saveCurrentStep();
              
              if (isLastStep) {
                _submitForm();
              } else {
                provider.nextStep();
              }
            },
            icon: Icon(isLastStep ? Icons.save : Icons.arrow_forward),
            label: Text(isLastStep ? 'Hoàn tất & Lưu' : 'Tiếp theo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}