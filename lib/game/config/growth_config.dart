import 'dart:math' as dart_math;

class GrowthConfig {
  static const int startLength = 20;
  static const int maxLength = 3000;

  // Asosiy o'sish koeffitsiyenti
  static const double lengthGrowthMultiplier = 0.27;
  static const double radiusGrowthMultiplier = 8.0;

  static const Map<int, double> growthStages = {
    0: 1.0,       // 0-50: Normal tezlik
    50: 0.85,     // 50-100: 15% sekinroq
    100: 0.70,    // 100-200: 30% sekinroq
    200: 0.55,    // 200-500: 45% sekinroq
    500: 0.40,    // 500-1000: 60% sekinroq
    1000: 0.25,   // 1000-2000: 75% sekinroq
    2000: 0.15,   // 2000-5000: 85% sekinroq
    5000: 0.08,   // 5000+: 92% sekinroq
  };

  static const int minGrowthPerFood = 1;
  static const int maxGrowthPerFood = 5;

  /// Score'ga qarab o'sish koeffitsiyentini hisoblash
  static double getGrowthMultiplier(int currentLength) {
    double multiplier = 1.0;

    for (final entry in growthStages.entries) {
      if (currentLength >= entry.key) {
        multiplier = entry.value;
      }
    }

    return multiplier;
  }

  /// Ovqatdan o'sishni hisoblash (score asosida sekinlashadi)
  static int calculateGrowth(int currentLength, int foodPoints) {
    final multiplier = getGrowthMultiplier(currentLength);
    final baseGrowth = foodPoints * lengthGrowthMultiplier;
    final growth = (baseGrowth * multiplier).round();

    return growth.clamp(minGrowthPerFood, maxGrowthPerFood);
  }

  /// ✅ Radius o'sishi - Score oshgan sari sekinroq
  static double calculateRadiusGrowth(double currentScore) {
    // Logaritmik o'sish - boshida tez, keyin juda sekin
    if (currentScore < 100) {
      // Kichik score: tezroq o'sadi
      return dart_math.sqrt(currentScore / 10 + 1) * 2.2 + 12;
    } else if (currentScore < 500) {
      // O'rta score: sekinroq
      return dart_math.sqrt(currentScore / 15 + 1) * 2.0 + 12;
    } else if (currentScore < 2000) {
      // Katta score: ancha sekin
      return dart_math.sqrt(currentScore / 20 + 1) * 1.8 + 12;
    } else {
      // Juda katta score: juda sekin
      return dart_math.sqrt(currentScore / 30 + 1) * 1.5 + 12;
    }
  }

  /// ✅ Score multiplier - Katta bo'lgan sari kamroq bonus
  static double getScoreMultiplier(int currentLength) {
    if (currentLength < 50) return 0.15;    // Boshida kam bonus
    if (currentLength < 100) return 0.25;
    if (currentLength < 200) return 0.35;
    if (currentLength < 500) return 0.45;
    if (currentLength < 1000) return 0.55;
    if (currentLength < 2000) return 0.65;
    if (currentLength < 5000) return 0.75;
    return 0.80; // Maksimal bonus ham past
  }

  /// ✅ YANGI: Score asosida o'sish tezligini ko'rsatish (debug uchun)
  static String getGrowthSpeedDescription(int currentLength) {
    final multiplier = getGrowthMultiplier(currentLength);

    if (multiplier >= 0.8) return "Tez o'sish";
    if (multiplier >= 0.6) return "Normal o'sish";
    if (multiplier >= 0.4) return "Sekin o'sish";
    if (multiplier >= 0.2) return "Juda sekin";
    return "Minimal o'sish";
  }
}