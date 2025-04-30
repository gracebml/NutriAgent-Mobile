class Meal {
  final String name;
  final List<String> ingredients;
  final Nutrition nutrition;
  final String preparation;
  final double price;
  
  Meal({
    required this.name,
    required this.ingredients,
    required this.nutrition,
    required this.preparation,
    required this.price,
  });
}

class Nutrition {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int sodium;
  
  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sodium,
  });
}