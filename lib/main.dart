import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/difficulty_selection_screen.dart';
import 'screens/shop_screen.dart';
import 'utils/constants.dart';
import 'utils/storage.dart';

void main() async {
  // Flutter ni ishga tushirish
  WidgetsFlutterBinding.ensureInitialized();

  // Storage'ni initialize qilish
  await StorageManager.instance.init();

  // Faqat portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SnakeRushApp());
}

class SnakeRushApp extends StatelessWidget {
  const SnakeRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: GameConstants.primaryColor,
        scaffoldBackgroundColor: GameConstants.backgroundColor,
        colorScheme: ColorScheme.dark(
          primary: GameConstants.primaryColor,
          secondary: GameConstants.secondaryColor,
        ),
      ),
      home: const MainMenu(),
    );
  }
}

// =============================================================================
// MAIN MENU - Bosh menyu
// =============================================================================

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final StorageManager _storage = StorageManager.instance;

  @override
  Widget build(BuildContext context) {
    final bestScore = _storage.getBestScore();
    final coins = _storage.getCoins();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GameConstants.backgroundColor,
                GameConstants.backgroundColor.withBlue(100),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  const Text(
                    '🐍',
                    style: TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 16),
        
                  const Text(
                    'SNAKE RUSH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
        
                  Text(
                    'Classic Snake Game',
                    style: TextStyle(
                      color: GameConstants.textSecondaryColor,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 32),
        
                  // Best Score
                  _buildStatCard('⭐', 'Best Score', '$bestScore'),
                  const SizedBox(height: 16),
        
                  // Coins - Katta qilib + button bilan
                  _buildCoinsCard(coins),
                  const SizedBox(height: 32),
        
                  // Play Button
                  _buildMenuButton(
                    context,
                    'PLAY',
                    GameConstants.secondaryColor,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DifficultySelectionScreen(),
                        ),
                      ).then((_) => setState(() {})); // Refresh after game
                    },
                  ),
                  const SizedBox(height: 16),
        
                  // Shop Button
                  _buildMenuButton(
                    context,
                    'SHOP',
                    GameConstants.primaryColor,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopScreen(),
                        ),
                      ).then((_) => setState(() {})); // Refresh after shop
                    },
                  ),
                  const SizedBox(height: 20),
        
                  // Info
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: GameConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: GameConstants.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('🍎', 'Oddiy Olma', '+10 ochko'),
                        const SizedBox(height: 8),
                        _buildInfoRow('🌟', 'Oltin Olma', '+50 ochko'),
                        const SizedBox(height: 8),
                        _buildInfoRow('⚡', 'Power Olma', '2x ochko 3 soniya'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
        
                  // Version
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: GameConstants.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsCard(int coins) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GameConstants.accentColor.withOpacity(0.3),
            GameConstants.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GameConstants.accentColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: GameConstants.accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Coins info
          Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coinlar',
                    style: TextStyle(
                      color: GameConstants.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Add button
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddCoinsDialog(context),
                borderRadius: BorderRadius.circular(15),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context,
      String text,
      Color color,
      VoidCallback onPressed,
      ) {
    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String name, String description) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: GameConstants.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: GameConstants.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: GameConstants.primaryColor,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: GameConstants.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Add Coins Dialog
  void _showAddCoinsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: GameConstants.accentColor, width: 2),
        ),
        title: const Row(
          children: [
            Text('🪙', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text(
              'COIN QO\'SHISH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reklama ko'rib coin olish
              ElevatedButton(
                onPressed: () async {
                  // Demo: Reklama ko'rildi
                  await _storage.addCoins(GameConstants.adRewardCoins);
                  setState(() {}); // Main menu'ni yangilash
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📺 +${GameConstants.adRewardCoins} coins olindi!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline, size: 32),
                        SizedBox(width: 12),
                        Text(
                          'REKLAMA KO\'RISH',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${GameConstants.adRewardCoins} coins BEPUL',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),

              const Text(
                'SOTIB OLISH',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),

              // Coin paketlari
              ..._buildCoinPackButtons(dialogContext),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCoinPackButtons(BuildContext dialogContext) {
    return GameConstants.coinPacks.entries.map((entry) {
      final coins = entry.value['coins'] as int;
      final price = entry.value['price'] as String;
      final packName = entry.key == 'small' ? 'Kichik' :
      entry.key == 'medium' ? 'O\'rtacha' :
      entry.key == 'large' ? 'Katta' : 'Mega';

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GameConstants.accentColor.withOpacity(0.2),
                GameConstants.accentColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: GameConstants.accentColor,
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Demo: To'lov qilindi
                _storage.addCoins(coins);
                setState(() {}); // Main menu'ni yangilash
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ $coins coins sotib olindi!'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text(
                              '$coins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: GameConstants.accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}