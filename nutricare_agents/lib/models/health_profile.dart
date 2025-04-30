import 'package:equatable/equatable.dart';

/// Health profile information model based on HealthInformationForm.tsx
class HealthProfile extends Equatable {
  /// User's age
  final int? age;
  
  /// User's gender (Male, Female, Other, Prefer not to say)
  final String? gender;
  
  /// User's height in cm
  final double? heightCm;
  
  /// User's weight in kg
  final double? weightKg;
  
  /// Activity level (sedentary, light, moderate, active, extra_active)
  final String? activityLevel;
  
  /// Food allergies as a list
  final List<String>? allergies;
  
  /// Dietary restrictions (e.g., vegetarian, vegan, etc.)
  final List<String>? dietaryRestrictions;
  
  /// Food preferences - what the user likes/dislikes
  final String? preferences;
  
  /// Medical conditions that might affect diet
  final String? medicalConditions;
  
  /// Nutritional or health goals
  final String? goals;
  
  /// Constructor
  const HealthProfile({
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.allergies,
    this.dietaryRestrictions,
    this.preferences,
    this.medicalConditions,
    this.goals,
  });
  
  /// Create an empty health profile
  static const empty = HealthProfile();
  
  /// Calculate BMI if height and weight are available
  double? get bmi {
    if (heightCm != null && weightKg != null && heightCm! > 0) {
      // BMI = weight(kg) / height(m)²
      final heightM = heightCm! / 100;
      return weightKg! / (heightM * heightM);
    }
    return null;
  }
  
  /// Get BMI category based on calculated BMI
  String? get bmiCategory {
    final calculatedBmi = bmi;
    if (calculatedBmi == null) return null;
    
    if (calculatedBmi < 18.5) return 'Underweight';
    if (calculatedBmi < 25) return 'Normal';
    if (calculatedBmi < 30) return 'Overweight';
    return 'Obese';
  }
  
  /// Get daily caloric needs estimate based on profile data
  /// Using Mifflin-St Jeor equation
  double? get dailyCaloricNeeds {
    if (age == null || heightCm == null || weightKg == null || gender == null) {
      return null;
    }
    
    // Base calculation
    double bmr;
    if (gender?.toLowerCase() == 'male') {
      bmr = 10 * weightKg! + 6.25 * heightCm! - 5 * age! + 5;
    } else {
      bmr = 10 * weightKg! + 6.25 * heightCm! - 5 * age! - 161;
    }
    
    // Apply activity multiplier
    double activityMultiplier;
    switch (activityLevel?.toLowerCase()) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'extra_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2; // Default to sedentary
    }
    
    return bmr * activityMultiplier;
  }
  
  /// Create a copy of this HealthProfile with the given fields replaced
  HealthProfile copyWith({
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    List<String>? allergies,
    List<String>? dietaryRestrictions,
    String? preferences,
    String? medicalConditions,
    String? goals,
  }) {
    return HealthProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      allergies: allergies ?? this.allergies,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      preferences: preferences ?? this.preferences,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      goals: goals ?? this.goals,
    );
  }
  
  /// Convert the HealthProfile to a Map
  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel,
      'allergies': allergies,
      'dietaryRestrictions': dietaryRestrictions,
      'preferences': preferences,
      'medicalConditions': medicalConditions,
      'goals': goals,
    };
  }
  
  /// Create a HealthProfile from a map
  factory HealthProfile.fromMap(Map<String, dynamic> map) {
    return HealthProfile(
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      heightCm: map['heightCm'] as double?,
      weightKg: map['weightKg'] as double?,
      activityLevel: map['activityLevel'] as String?,
      allergies: map['allergies'] != null 
          ? List<String>.from(map['allergies']) 
          : null,
      dietaryRestrictions: map['dietaryRestrictions'] != null 
          ? List<String>.from(map['dietaryRestrictions']) 
          : null,
      preferences: map['preferences'] as String?,
      medicalConditions: map['medicalConditions'] as String?,
      goals: map['goals'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();
  
  /// Create from JSON
  factory HealthProfile.fromJson(Map<String, dynamic> json) => HealthProfile.fromMap(json);
  
  @override
  List<Object?> get props => [
    age, 
    gender, 
    heightCm, 
    weightKg, 
    activityLevel,
    allergies,
    dietaryRestrictions,
    preferences,
    medicalConditions,
    goals,
  ];
  
  @override
  String toString() {
    return 'HealthProfile(age: $age, gender: $gender, height: $heightCm cm, weight: $weightKg kg, activity: $activityLevel)';
  }
}

/// Extension for activity level constants
extension ActivityLevels on String {
  static const String sedentary = 'sedentary';
  static const String light = 'light';
  static const String moderate = 'moderate';
  static const String active = 'active';
  static const String extraActive = 'extra_active';
  
  /// Returns true if this string is a valid activity level
  bool get isValidActivityLevel {
    final level = toLowerCase();
    return level == sedentary || 
           level == light || 
           level == moderate || 
           level == active || 
           level == extraActive;
  }
}

/// Extension for gender constants
extension Genders on String {
  static const String male = 'Male';
  static const String female = 'Female';
  static const String other = 'Other';
  static const String preferNotToSay = 'Prefer not to say';
  
  /// Returns true if this string is a valid gender option
  bool get isValidGender {
    return this == male || 
           this == female || 
           this == other || 
           this == preferNotToSay;
  }
}