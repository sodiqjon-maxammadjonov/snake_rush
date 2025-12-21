// Bu faylni game_constants.dart ga qo'shishingiz mumkin
// Yoki alohida growth_config.dart sifatida saqlashingiz mumkin

class GrowthConfig {
  // Progressive o'sish sozlamalari

  // Boshlang'ich uzunlik
  static const int startLength = 100;

  // Maksimal uzunlik
  static const int maxLength = 20000;

  // Boshlang'ich o'sish ko'paytiruvchisi
  static const double baseGrowthMultiplier = 8.0;

  // O'sish bosqichlari (length: scale factor)
  static const Map<int, double> growthStages = {
    0: 1.0,      // 0-200: 100% o'sish
    200: 0.9,    // 200-500: 90% o'sish
    500: 0.7,    // 500-1000: 70% o'sish
    1000: 0.4,   // 1000-2000: 40% o'sish
    2000: 0.2,   // 2000-5000: 20% o'sish
    5000: 0.08,  // 5000-10000: 8% o'sish
    10000: 0.05, // 10000+: 5% o'sish
  };

  // Minimal o'sish (har doim)
  static const int minGrowthPerFood = 1;

  // Maksimal o'sish (bir ovqatdan)
  static const int maxGrowthPerFood = 100;
}

// MISOL:
// Length 100, Small food (1 point):
//   → growth = 1 * 8 * 1.0 = 8 segments
//
// Length 500, Medium food (3 points):
//   → growth = 3 * 8 * 0.7 = 16.8 ≈ 17 segments
//
// Length 2000, Large food (5 points):
//   → growth = 5 * 8 * 0.2 = 8 segments
//
// Length 10000, Super food (10 points):
//   → growth = 10 * 8 * 0.05 = 4 segments