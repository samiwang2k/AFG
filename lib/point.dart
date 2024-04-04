import 'dart:math';

class Point {
  double? x;
  double? y;

  @override
  String toString() {
    return 'Point(x: $x, y: $y)';
  }

  Point({double? xCoordinate, double? yCoordinate}) {
    x = xCoordinate;
    y = yCoordinate;
  }

  Point.defined(this.x, this.y);

  double? get xCoordinate => x;
  double? get yCoordinate => y;

  set setX(double? value) {
    x = value;
  }

  set setY(double? value) {
    y = value;
  }

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
