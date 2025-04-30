import 'package:flutter/material.dart';
import 'package:nutricare_agents/models/meal.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final bool isFavorite;
  final Function(String) onToggleFavorite;

  const MealCard({
    Key? key,
    required this.meal,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần header với tên món ăn và nút yêu thích
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: () => onToggleFavorite(meal.name),
                ),
              ],
            ),
          ),
          
          // Phần thông tin chi tiết
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nguyên liệu
                const Text(
                  'Nguyên liệu:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: meal.ingredients.map((ingredient) {
                    return Chip(
                      label: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.grey[200],
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 12),
                
                // Thông tin dinh dưỡng
                const Text(
                  'Thông tin dinh dưỡng:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutritionInfo('Calo', '${meal.nutrition.calories} kcal'),
                    _buildNutritionInfo('Protein', '${meal.nutrition.protein}g'),
                    _buildNutritionInfo('Carbs', '${meal.nutrition.carbs}g'),
                    _buildNutritionInfo('Chất béo', '${meal.nutrition.fat}g'),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Cách chế biến
                const Text(
                  'Cách chế biến:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.preparation,
                  style: const TextStyle(fontSize: 14),
                ),
                
                const SizedBox(height: 12),
                
                // Giá tiền
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Giá: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${meal.price.toStringAsFixed(0)} VNĐ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNutritionInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}