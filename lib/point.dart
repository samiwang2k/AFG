import 'dart:math';

class Point {
  double? x;
  double? y;
  
  @override
  String toString() {
    return 'Point(x: $x, y: $y)';
  }

  Point(this.x, this.y);

  double? get xCoordinate => x;
  double? get yCoordinate => y;

  static double dist(Point p) {
    return sqrt(p.x! * p.x! + p.y! * p.y!);
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
    };
  }
}
