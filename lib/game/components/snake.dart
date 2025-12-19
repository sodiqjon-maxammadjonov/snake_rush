import 'dart:ui';
import 'package:flame/components.dart';
import '../config/game_constants.dart';
import 'game_map.dart';

class Snake extends PositionComponent {
  Vector2 direction = Vector2(1, 0);
  final GameMap map;

  late final Paint _paint;

  Snake({required this.map}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(GameConstants.snakeRadius * 2);
    position = Vector2(GameConstants.startX, GameConstants.startY);

    _paint = Paint()..color = GameConstants.snakeColor..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!direction.isZero()) {
      position += direction.normalized() * GameConstants.snakeSpeed * dt;
    }

    position.x = position.x.clamp(size.x / 2, map.width - size.x / 2);
    position.y = position.y.clamp(size.y / 2, map.height - size.y / 2);

    angle = direction.screenAngle();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(size.x/2, size.y/2), size.x / 2, _paint);

    _renderEyes(canvas);
  }

  void _renderEyes(Canvas canvas) {
    final eyePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.3), 3, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.7), 3, eyePaint);
  }
}