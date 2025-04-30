import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Meal model based on MenuItemSchema from the original web app
/// This represents a single dish/meal item
class Meal extends Equatable {
  /// The name of the dish (in Vietnamese)
  final String name;
  
  /// List of ingredients required for this meal
  final List<String> ingredients;
  
  /// Preparation instructions
  final String preparation;
  
  /// Estimated cost (e.g., "khoảng 30k", "dưới 50k")
  final String? estimatedCost;
  
  /// Estimated calories (if available)
  final int? calories;
  
  /// Protein content in grams (if available)
  final double? protein;
  
  /// Carbohydrate content in grams (if available)
  final double? carbs;
  
  /// Fat content in grams (if available)
  final double? fat;
  
  /// Health benefits of this meal (if available)
  final List<String>? healthBenefits;
  
  /// URL of an AI-generated image (if available)
  final String? imageUrl;
  
  /// DateTime when this meal was created
  final DateTime? createdAt;
  
  /// Reference to user who created this meal (if applicable)
  final String? createdBy;

  /// Constructor
  const Meal({
    required this.name,
    required this.ingredients,
    required this.preparation,
    this.estimatedCost,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.healthBenefits,
    this.imageUrl,
    this.createdAt,
    this.createdBy,
  });

  /// Create an empty meal
  static Meal empty() {
    return const Meal(
      name: '',
      ingredients: [],
      preparation: '',
    );
  }
  
  /// Calculate the macronutrient distribution (protein/carbs/fat percentages)
  /// Returns a Map with 'protein', 'carbs', and 'fat' percentages
  Map<String, double>? get macroDistribution {
    if (protein == null || carbs == null || fat == null) {
      return null;
    }
    
    // Convert to calories (protein: 4 cal/g, carbs: 4 cal/g, fat: 9 cal/g)
    final proteinCal = protein! * 4;
    final carbsCal = carbs! * 4;
    final fatCal = fat! * 9;
    
    final totalCal = proteinCal + carbsCal + fatCal;
    
    if (totalCal <= 0) {
      return null;
    }
    
    return {
      'protein': (proteinCal / totalCal) * 100,
      'carbs': (carbsCal / totalCal) * 100,
      'fat': (fatCal / totalCal) * 100,
    };
  }
  
  /// Get a brief summary of the meal (name and key ingredients)
  String get summary {
    final ingredientsList = ingredients.take(3).join(', ');
    return '$name ($ingredientsList${ingredients.length > 3 ? '...' : ''})';
  }
  
  /// Create a copy of this Meal with the given fields replaced
  Meal copyWith({
    String? name,
    List<String>? ingredients,
    String? preparation,
    String? estimatedCost,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    List<String>? healthBenefits,
    String? imageUrl,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Meal(
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      preparation: preparation ?? this.preparation,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      healthBenefits: healthBenefits ?? this.healthBenefits,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
  
  /// Convert the Meal to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ingredients': ingredients,
      'preparation': preparation,
      'estimatedCost': estimatedCost,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'healthBenefits': healthBenefits,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
    };
  }
  
  /// Create a Meal from a map
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] as String,
      ingredients: List<String>.from(map['ingredients']),
      preparation: map['preparation'] as String,
      estimatedCost: map['estimatedCost'] as String?,
      calories: map['calories'] as int?,
      protein: map['protein'] as double?,
      carbs: map['carbs'] as double?,
      fat: map['fat'] as double?,
      healthBenefits: map['healthBenefits'] != null 
        ? List<String>.from(map['healthBenefits']) 
        : null,
      imageUrl: map['imageUrl'] as String?,
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] as Timestamp).toDate() 
        : null,
      createdBy: map['createdBy'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();
  
  /// Create from JSON
  factory Meal.fromJson(Map<String, dynamic> json) => Meal.fromMap(json);
  
  /// Create a Meal from the original MenuItemSchema format
  factory Meal.fromMenuItemSchema(Map<String, dynamic> schema) {
    return Meal(
      name: schema['name'] as String,
      ingredients: List<String>.from(schema['ingredients']),
      preparation: schema['preparation'] as String,
      estimatedCost: schema['estimatedCost'] as String?,
      calories: schema['calories'] as int?,
      protein: schema['protein'] as double?,
      carbs: schema['carbs'] as double?,
      fat: schema['fat'] as double?,
      healthBenefits: schema['healthBenefits'] != null 
        ? List<String>.from(schema['healthBenefits']) 
        : null,
      createdAt: DateTime.now(),
    );
  }
  
  @override
  List<Object?> get props => [
    name,
    ingredients,
    preparation,
    estimatedCost,
    calories,
    protein,
    carbs,
    fat,
    healthBenefits,
    imageUrl,
    createdAt,
    createdBy,
  ];
  
  @override
  String toString() {
    return 'Meal(name: $name, ingredients: ${ingredients.length}, calories: $calories)';
  }
}

/// Represents a type of meal (breakfast, lunch, dinner, snack)
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;
  
  /// Get the display name for this meal type in Vietnamese
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Bữa Sáng';
      case MealType.lunch:
        return 'Bữa Trưa';
      case MealType.dinner:
        return 'Bữa Tối';
      case MealType.snack:
        return 'Bữa Phụ';
    }
  }
  
  /// Get the meal type from a string (case-insensitive)
  static MealType? fromString(String value) {
    final lowerValue = value.toLowerCase();
    return MealType.values.firstWhere(
      (type) => type.name.toLowerCase() == lowerValue,
      orElse: () => MealType.values.firstWhere(
        (type) => type.displayName.toLowerCase() == lowerValue,
        orElse: () => throw ArgumentError('Invalid meal type: $value'),
      ),
    );
  }
}

/// Extension methods for Meal lists
extension MealListExtension on List<Meal> {
  /// Get total calories in all meals in the list
  int get totalCalories {
    return fold(0, (sum, meal) => sum + (meal.calories ?? 0));
  }
  
  /// Get total protein in all meals in the list
  double get totalProtein {
    return fold(0, (sum, meal) => sum + (meal.protein ?? 0));
  }
  
  /// Get total carbs in all meals in the list
  double get totalCarbs {
    return fold(0, (sum, meal) => sum + (meal.carbs ?? 0));
  }
  
  /// Get total fat in all meals in the list
  double get totalFat {
    return fold(0, (sum, meal) => sum + (meal.fat ?? 0));
  }
  
  /// Get all ingredients from all meals, without duplicates
  List<String> get allIngredients {
    final result = <String>{};
    for (final meal in this) {
      result.addAll(meal.ingredients);
    }
    return result.toList();
  }
}