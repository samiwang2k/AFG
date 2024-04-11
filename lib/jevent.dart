// ignore_for_file: unnecessary_getters_setters

import 'point.dart';
import 'dart:core';

class Jevent {
  String? _name;
  String? _date;
  Point? _location;
  String? _hostName;

  Jevent({String? name, String? date, Point? location, String? hostName}) {
    this.name = name;
    this.date = date;
    this.location = location;
    this.hostName = hostName;
  }

  // Getter for name
  String? get name => _name;

  // Setter for name
  set name(String? value) {
    _name = value;
  }

  // Getter for date
  String? get date => _date;

  // Setter for date
  set date(String? value) {
    _date = value;
  }

  // Getter for location
  Point? get location => _location;

  // Setter for location
  set location(Point? value) {
    _location = value;
  }

  // Getter for hostName
  String? get hostName => _hostName;

  // Setter for hostName
  set hostName(String? value) {
    _hostName = value;
  }

  @override
  String toString() {
    return 'The event name is $name. It is being run by $hostName on $date at $location';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date,
      'location': location?.toMap(),
      'hostName': hostName,
    };
  }
}
