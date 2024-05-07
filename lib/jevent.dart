import 'point.dart';
import 'dart:core';

class Jevent {
  String? _name;
  String? _date;
  Point? _location;
  String? _hostName;
  String? _imageUrl; // New image property
  String? _time;

  // Updated constructor to include imageUrl parameter
  Jevent(
      {String? name,
      String? date,
      Point? location,
      String? hostName,
      String? imageUrl,
      String? time}) {
    this.name = name;
    this.date = date;
    this.location = location;
    this.hostName = hostName;
    this.imageUrl = imageUrl; // Set the image URL
    this.time = time;
  }

  // Getter for name
  String? get name => _name;

  set time(String? value) {
    _time = value;
  }

  String? get time => _time;

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

  // Getter for imageUrl
  String? get imageUrl => _imageUrl;

  // Setter for imageUrl
  set imageUrl(String? value) {
    _imageUrl = value;
  }

  @override
  String toString() {
    return 'The event name is $name. It is being run by $hostName on $date at $location at $time. Image URL: $imageUrl';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date,
      'location': location?.toMap(),
      'hostName': hostName,
      'imageUrl': imageUrl,
      'time': time,
    };
  }
}
