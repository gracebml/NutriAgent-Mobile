import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other, preferNotToSay }

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  extraActive,
}

// Helper function to convert String to Gender enum
Gender stringToGender(String? value) {
  switch (value?.toLowerCase()) {
    case 'male':
      return Gender.male;
    case 'female':
      return Gender.female;
    case 'other':
      return Gender.other;
    case 'prefer not to say':
      return Gender.preferNotToSay;
    default:
      return Gender.preferNotToSay;
  }
}

// Helper to convert Gender to String
String genderToString(Gender gender) {
  switch (gender) {
    case Gender.male:
      return 'Male';
    case Gender.female:
      return 'Female';
    case Gender.other:
      return 'Other';
    case Gender.preferNotToSay:
      return 'Prefer not to say';
  }
}

// Helper to convert ActivityLevel enum to String
String activityLevelToString(ActivityLevel level) {
  switch (level) {
    case ActivityLevel.sedentary:
      return 'Sedentary (little or no exercise)';
    case ActivityLevel.light:
      return 'Lightly active (light exercise/sports 1-3 days/week)';
    case ActivityLevel.moderate:
      return 'Moderately active (moderate exercise/sports 3-5 days/week)';
    case ActivityLevel.active:
      return 'Very active (hard exercise/sports 6-7 days a week)';
    case ActivityLevel.extraActive:
      return 'Extra active (very hard exercise/sports & physical job)';
  }
}

// Helper to convert String to ActivityLevel enum
ActivityLevel stringToActivityLevel(String? value) {
  switch (value?.toLowerCase()) {
    case 'sedentary':
      return ActivityLevel.sedentary;
    case 'light':
      return ActivityLevel.light;
    case 'moderate':
      return ActivityLevel.moderate;
    case 'active':
      return ActivityLevel.active;
    case 'extra_active':
      return ActivityLevel.extraActive;
    default:
      return ActivityLevel.moderate; // Default value
  }
}

class HealthProfileModel {
  String? id;
  String userId;
  String name;
  int? age;
  Gender? gender;
  double? height; // in cm
  double? weight; // in kg
  ActivityLevel? activityLevel;
  String? allergies;
  String? dietaryRestrictions;
  String? preferences;
  String? medicalConditions;
  String? goals;
  DateTime lastUpdated;

  HealthProfileModel({
    this.id,
    required this.userId,
    required this.name,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.activityLevel,
    this.allergies,
    this.dietaryRestrictions,
    this.preferences,
    this.medicalConditions,
    this.goals,
    DateTime? lastUpdated,
  }) : this.lastUpdated = lastUpdated ?? DateTime.now();

  // Factory constructor from Firestore document
  factory HealthProfileModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return HealthProfileModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'User',
      age: data['age'],
      gender: stringToGender(data['gender']),
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      activityLevel: stringToActivityLevel(data['activityLevel']),
      allergies: data['allergies'],
      dietaryRestrictions: data['dietaryRestrictions'],
      preferences: data['preferences'],
      medicalConditions: data['medicalConditions'],
      goals: data['goals'],
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'gender': gender != null ? genderToString(gender!) : null,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel != null ? activityLevel.toString().split('.').last : null,
      'allergies': allergies,
      'dietaryRestrictions': dietaryRestrictions,
      'preferences': preferences,
      'medicalConditions': medicalConditions,
      'goals': goals,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Create a copy with updated fields
  HealthProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? age,
    Gender? gender,
    double? height,
    double? weight,
    ActivityLevel? activityLevel,
    String? allergies,
    String? dietaryRestrictions,
    String? preferences,
    String? medicalConditions,
    String? goals,
    DateTime? lastUpdated,
  }) {
    return HealthProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      allergies: allergies ?? this.allergies,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      preferences: preferences ?? this.preferences,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      goals: goals ?? this.goals,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Get BMI calculation
  double? calculateBMI() {
    if (height == null || weight == null || height! <= 0) return null;
    
    // BMI = weight(kg) / (height(m) * height(m))
    double heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  String? getBMICategory() {
    final bmi = calculateBMI();
    if (bmi == null) return null;
    
    if (bmi < 18.5) return "Thiếu cân";
    if (bmi < 25) return "Bình thường";
    if (bmi < 30) return "Thừa cân";
    return "Béo phì";
  }

  // Calculate estimated daily calorie needs using the Harris-Benedict equation
  int? calculateDailyCalories() {
    if (weight == null || height == null || age == null || gender == null) return null;
    
    // Base Metabolic Rate (BMR)
    double bmr;
    
    if (gender == Gender.male) {
      bmr = 88.362 + (13.397 * weight!) + (4.799 * height!) - (5.677 * age!);
    } else {
      bmr = 447.593 + (9.247 * weight!) + (3.098 * height!) - (4.330 * age!);
    }
    
    // Activity Multiplier
    double activityMultiplier;
    
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        activityMultiplier = 1.2;
        break;
      case ActivityLevel.light:
        activityMultiplier = 1.375;
        break;
      case ActivityLevel.moderate:
        activityMultiplier = 1.55;
        break;
      case ActivityLevel.active:
        activityMultiplier = 1.725;
        break;
      case ActivityLevel.extraActive:
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.55; // Default to moderate
    }
    
    return (bmr * activityMultiplier).round();
  }
}