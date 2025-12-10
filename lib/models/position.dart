import 'direction.dart';

class Position {
  final int x; // X koordinatasi (gorizontal)
  final int y; // Y koordinatasi (vertikal)

  // Constructor
  const Position(this.x, this.y);

  // Ikkita pozitsiyani solishtiramiz
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  // Yangi yo'nalishga qarab keyingi pozitsiyani hisoblaydi
  // Masalan: Position(5, 5) + Direction.up => Position(5, 4)
  Position moveInDirection(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Position(x, y - 1);
      case Direction.down:
        return Position(x, y + 1);
      case Direction.left:
        return Position(x - 1, y);
      case Direction.right:
        return Position(x + 1, y);
    }
  }

  Position copyWith({int? x, int? y}) {
    return Position(x ?? this.x, y ?? this.y);
  }

  @override
  String toString() => 'Position(x: $x, y: $y)';
}
