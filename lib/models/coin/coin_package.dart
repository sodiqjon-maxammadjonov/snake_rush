class CoinPackage {
  final int coins;
  final String price;
  final int bonus;
  final bool isPopular;
  final bool isBestValue;
  final String productId;

  const CoinPackage({
    required this.coins,
    required this.price,
    this.bonus = 0,
    this.isPopular = false,
    this.isBestValue = false,
    required this.productId,
  });

  static const List<CoinPackage> packages = [
    CoinPackage(
      coins: 250,
      price: '\$0.49',
      productId: 'coins_250',
    ),

    CoinPackage(
      coins: 500,
      price: '\$0.99',
      productId: 'coins_500',
    ),

    CoinPackage(
      coins: 1200,
      price: '\$1.99',
      bonus: 20,
      isPopular: true,
      productId: 'coins_1200',
    ),

    CoinPackage(
      coins: 2500,
      price: '\$3.99',
      bonus: 25,
      productId: 'coins_2500',
    ),

    CoinPackage(
      coins: 5500,
      price: '\$6.99',
      bonus: 30,
      isBestValue: true,
      productId: 'coins_5500',
    ),

    CoinPackage(
      coins: 12000,
      price: '\$12.99',
      bonus: 40,
      productId: 'coins_12000',
    ),

    CoinPackage(
      coins: 30000,
      price: '\$29.99',
      bonus: 50,
      productId: 'coins_30000',
    ),

    CoinPackage(
      coins: 80000,
      price: '\$59.99',
      bonus: 70,
      productId: 'coins_80000',
    ),
  ];
}
