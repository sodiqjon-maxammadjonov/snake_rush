enum Direction {
  up,
  down,
  left,
  right,
}

extension DirectionExtension on Direction {
  //  up.opposite => down
  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }

  String get name {
    switch (this) {
      case Direction.up:
        return 'Yuqoriga';
      case Direction.down:
        return 'Pastga';
      case Direction.left:
        return 'Chapga';
      case Direction.right:
        return 'O\'ngga';
    }
  }
}