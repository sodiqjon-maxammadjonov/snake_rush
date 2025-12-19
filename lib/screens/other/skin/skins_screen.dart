import 'package:flutter/cupertino.dart';
import '../../../game/core/skin.dart';
import '../../../utils/services/service_locator.dart';
import '../../../utils/services/storage/storage_service.dart';
import '../../../utils/ui/colors.dart';
import '../../../utils/ui/dimensions.dart';

class SkinsScreen extends StatefulWidget {
  const SkinsScreen({super.key});

  @override
  State<SkinsScreen> createState() => _SkinsScreenState();
}

class _SkinsScreenState extends State<SkinsScreen> {
  late String _currentSkinId;
  final _storage = getIt<StorageService>();

  @override
  void initState() {
    super.initState();
    _currentSkinId = _storage.selectedSkin;
  }

  void _selectSkin(String id) {
    setState(() => _currentSkinId = id);
    _storage.setSelectedSkin(id);
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    return CupertinoPageScaffold(
      backgroundColor: AppColors.bgDark,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('SHOP SKINS', style: TextStyle(color: CupertinoColors.white)),
        backgroundColor: CupertinoColors.transparent,
      ),
      child: SafeArea(
        child: GridView.builder(
          padding: EdgeInsets.all(d.paddingScreen),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          itemCount: SkinLibrary.allSkins.length,
          itemBuilder: (context, index) {
            final skin = SkinLibrary.allSkins[index];
            final isSelected = _currentSkinId == skin.id;

            return GestureDetector(
              onTap: () => _selectSkin(skin.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A1A2E) : AppColors.glassLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? CupertinoColors.activeBlue : AppColors.glassBorder,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(80, 40),
                      painter: SkinPreviewPainter(skin),
                    ),
                    const SizedBox(height: 10),
                    Text(skin.name, style: const TextStyle(color: CupertinoColors.white, fontSize: 14)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SkinPreviewPainter extends CustomPainter {
  final SnakeSkin skin;
  SkinPreviewPainter(this.skin);
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 5; i++) {
      skin.renderSegment(canvas, Offset(20.0 + (i * 10), size.height / 2), 10, i, i / 5);
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}