import 'dart:math';

// Define a class named Point to represent a point in a 2D space.
class Point {
  // Declare nullable double variables for the x and y coordinates.
  double? x;
  double? y;

  // Override the toString method to return a string representation of the point.
  @override
  String toString() {
    // Return a string in the format 'x,y'.
    return '$x,$y';
  }

  // Define a constructor for the Point class.
  // The constructor takes optional x and y coordinates.
  Point({double? xCoordinate, double? yCoordinate}) {
    // Assign the provided coordinates to the x and y variables.
    x = xCoordinate;
    y = yCoordinate;
  }

  // Define a factory constructor for creating a Point instance with predefined x and y values.
  Point.defined(this.x, this.y);

  // Define getter methods for the x and y coordinates.
  double? get xCoordinate => x;
  double? get yCoordinate => y;

  // Define setter methods for the x and y coordinates.
  set setX(double? value) {
    // Assign the provided value to the x variable.
    x = value;
  }

  set setY(double? value) {
    // Assign the provided value to the y variable.
    y = value;
  }

  // Define a static method to calculate the distance from the origin (0,0) to the point.
  static double dist(Point p) {
    // Calculate the distance using the Pythagorean theorem.
    // The sqrt function is used to calculate the square root.
    return sqrt(p.x! * p.x! + p.y! * p.y!);
  }

  // Define a method to convert the point to a map.
  Map<String, dynamic> toMap() {
    // Return a map with the x and y coordinates.
    return {
      'x': x,
      'y': y,
    };
  }
}
