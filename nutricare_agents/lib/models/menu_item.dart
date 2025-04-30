import 'package:flutter/foundation.dart';

class MenuItem {
  final String name;
  final List<String> ingredients;
  final String preparation;
  final String? estimatedCost;
  final int? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final List<String>? healthBenefits;

  MenuItem({
    required this.name,
    required this.ingredients,
    required this.preparation,
    this.estimatedCost,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.healthBenefits,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'] as String,
      ingredients: List<String>.from(json['ingredients']),
      preparation: json['preparation'] as String,
      estimatedCost: json['estimatedCost'] as String?,
      calories: json['calories'] as int?,
      protein: json['protein'] as double?,
      carbs: json['carbs'] as double?,
      fat: json['fat'] as double?,
      healthBenefits: json['healthBenefits'] != null
          ? List<String>.from(json['healthBenefits'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ingredients': ingredients,
      'preparation': preparation,
      if (estimatedCost != null) 'estimatedCost': estimatedCost,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (healthBenefits != null) 'healthBenefits': healthBenefits,
    };
  }
}