import 'package:flutter/material.dart';
import '../models/skin.dart';
import '../utils/constants.dart';
import '../utils/storage.dart';

// =============================================================================
// SHOP SCREEN - Skinlar do'koni
// =============================================================================

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final StorageManager _storage = StorageManager.instance;
  String selectedSkinId = '';

  @override
  void initState() {
    super.initState();
    selectedSkinId = _storage.getSelectedSkin();
  }

  @override
  Widget build(BuildContext context) {
    final coins = _storage.getCoins();
    final unlockedSkins = _storage.getUnlockedSkins();

    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(coins),

            // Skins grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: SnakeSkins.all.length,
                itemBuilder: (context, index) {
                  final skin = SnakeSkins.all[index];
                  final isUnlocked = unlockedSkins.contains(skin.id);
                  final isSelected = selectedSkinId == skin.id;

                  return _buildSkinCard(
                    skin,
                    isUnlocked,
                    isSelected,
                    coins,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int coins) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GameConstants.primaryColor.withOpacity(0.2),
            GameConstants.backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'SKINLAR DO\'KONI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSkinCard(SnakeSkin skin, bool isUnlocked, bool isSelected, int coins) {
    final canAfford = coins >= skin.price;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            skin.rarity.color.withOpacity(0.2),
            skin.rarity.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Colors.amber
              : skin.rarity.color,
          width: isSelected ? 3 : 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSkinTap(skin, isUnlocked, canAfford),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rarity badge
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: skin.rarity.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skin.rarity.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Skin preview
                Column(
                  children: [
                    Text(
                      skin.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),

                    // Color preview
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: skin.hasGradient
                            ? LinearGradient(
                          colors: [skin.color, skin.secondaryColor!],
                        )
                            : null,
                        color: skin.hasGradient ? null : skin.color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white30,
                          width: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                // Name
                Text(
                  skin.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Status button
                _buildStatusButton(skin, isUnlocked, isSelected, canAfford),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(SnakeSkin skin, bool isUnlocked, bool isSelected, bool canAfford) {
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: Colors.black, size: 16),
            SizedBox(width: 4),
            Text(
              'TANLANGAN',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isUnlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: GameConstants.secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'TANLASH',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Locked
    if (skin.unlockMethod == 'score') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, color: Colors.orange, size: 14),
            const SizedBox(width: 4),
            Text(
              '${skin.unlockScore} ochko',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Buy with coins
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: canAfford
            ? GameConstants.accentColor.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canAfford ? GameConstants.accentColor : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '${skin.price}',
            style: TextStyle(
              color: canAfford ? GameConstants.accentColor : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSkinTap(SnakeSkin skin, bool isUnlocked, bool canAfford) {
    if (isUnlocked) {
      // Tanlash
      setState(() {
        selectedSkinId = skin.id;
      });
      _storage.setSelectedSkin(skin.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${skin.emoji} ${skin.name} tanlandi!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (skin.unlockMethod == 'score') {
      // Score bilan ochiladi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${skin.unlockScore} ochkoga yeting!'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (canAfford) {
      // Sotib olish dialogi
      _showBuyDialog(skin);
    } else {
      // Yetarli coin yo'q
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yetarli coin yo\'q! (${skin.price} coin kerak)'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBuyDialog(SnakeSkin skin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: skin.rarity.color, width: 2),
        ),
        title: Row(
          children: [
            Text(skin.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                skin.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: skin.hasGradient
                    ? LinearGradient(
                  colors: [skin.color, skin.secondaryColor!],
                )
                    : null,
                color: skin.hasGradient ? null : skin.color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                skin.emoji,
                style: const TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 8),
                Text(
                  '${skin.price}',
                  style: TextStyle(
                    color: GameConstants.accentColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'BEKOR QILISH',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _storage.spendCoins(skin.price);
              await _storage.unlockSkin(skin.id);
              await _storage.setSelectedSkin(skin.id);

              setState(() {
                selectedSkinId = skin.id;
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${skin.emoji} ${skin.name} sotib olindi!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GameConstants.secondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'SOTIB OLISH',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}