import 'dart:math' as dart_math;

class GrowthConfig {
  static const int startLength = 20;
  static const int maxLength = 3000;

  static const double lengthGrowthMultiplier = 0.8;
  static const double radiusGrowthMultiplier = 12.0;

  static const Map<int, double> growthStages = {
    0: 1.0,
    50: 0.95,
    100: 0.9,
    200: 0.85,
    500: 0.7,
    1000: 0.5,
    2000: 0.3,
  };

  static const int minGrowthPerFood = 1;
  static const int maxGrowthPerFood = 15;

  static double getGrowthMultiplier(int currentLength) {
    double multiplier = 1.0;

    for (final entry in growthStages.entries) {
      if (currentLength >= entry.key) {
        multiplier = entry.value;
      }
    }

    return multiplier;
  }

  static int calculateGrowth(int currentLength, int foodPoints) {
    final multiplier = getGrowthMultiplier(currentLength);
    final baseGrowth = foodPoints * lengthGrowthMultiplier;
    final growth = (baseGrowth * multiplier).round();

    return growth.clamp(minGrowthPerFood, maxGrowthPerFood);
  }

  static double calculateRadiusGrowth(double currentScore) {
    return dart_math.sqrt(currentScore / 10 + 1) * 2.5 + 12;
  }

  static double getScoreMultiplier(int currentLength) {
    if (currentLength < 50) return 1.0;
    if (currentLength < 100) return 1.2;
    if (currentLength < 200) return 1.5;
    if (currentLength < 500) return 2.0;
    return 2.5;
  }
}