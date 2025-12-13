import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:snake_rush/utils/const_widgets/my_text.dart';
import '../../utils/widgets/morph_page.dart';

class SettingsScreen extends StatefulWidget {
  final Animation<double> animation;
  final Offset startPosition;
  final Size startSize;

  const SettingsScreen({
    super.key,
    required this.animation,
    required this.startPosition,
    required this.startSize,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _gameVolume = 0.7;
  double _musicVolume = 0.5;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: widget.animation,
              builder: (context, child) {
                final t = Curves.easeInOutCubic.transform(widget.animation.value);
                final headerEmojiOpacity = t > 0.7 ? ((t - 0.7) / 0.3).clamp(0.0, 1.0) : 0.0;

                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Icon(CupertinoIcons.back, size: 28),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: headerEmojiOpacity,
                            child: Text('⚙️', style: TextStyle(fontSize: 24)),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Settings',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Game Volume Control
                    _buildVolumeControl(
                      icon: '🎮',
                      title: 'Game Sound',
                      volume: _gameVolume,
                      onChanged: (value) {
                        setState(() {
                          _gameVolume = value;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // Music Volume Control
                    _buildVolumeControl(
                      icon: '🎵',
                      title: 'Music',
                      volume: _musicVolume,
                      onChanged: (value) {
                        setState(() {
                          _musicVolume = value;
                        });
                      },
                    ),

                    SizedBox(height: 30),

                    // Additional game options
                    _buildGameOption(
                      icon: '🏆',
                      title: 'Leaderboard',
                      onTap: () {},
                    ),

                    SizedBox(height: 12),

                    _buildGameOption(
                      icon: '❓',
                      title: 'How to Play',
                      onTap: () {},
                    ),

                    SizedBox(height: 12),

                    _buildGameOption(
                      icon: '📱',
                      title: 'Share Game',
                      onTap: () {},
                    ),

                    SizedBox(height: 30),

                    // Version info
                    Text(
                      'Snake Rush v1.0',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 12,
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildVolumeControl({
    required String icon,
    required String title,
    required double volume,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.1),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyText(icon, fontSize: 24),
              SizedBox(width: 12),
              MyText(title, fontSize: 18),
              Spacer(),
              MyText(
                '${(volume * 100).toInt()}%',
                fontSize: 16,
                color: CupertinoColors.activeBlue,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              MyText(volume == 0 ? '🔇' : '🔉', fontSize: 16),
              SizedBox(width: 8),
              Expanded(
                child: CupertinoSlider(
                  value: volume,
                  min: 0.0,
                  max: 1.0,
                  activeColor: CupertinoColors.activeBlue,
                  onChanged: onChanged,
                ),
              ),
              SizedBox(width: 8),
              MyText('🔊', fontSize: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameOption({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.white.withOpacity(0.1),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.label,
              ),
            ),
            Spacer(),
            Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}