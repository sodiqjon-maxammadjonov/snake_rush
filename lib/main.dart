import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';
import 'utils/constants.dart';

void main() {
  // Flutter ni ishga tushirish
  WidgetsFlutterBinding.ensureInitialized();

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
// MAIN MENU - Bosh menyu (oddiy versiya)
// =============================================================================

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                const SizedBox(height: 60),

                // Play Button
                _buildMenuButton(
                  context,
                  'PLAY',
                  GameConstants.secondaryColor,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
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
}