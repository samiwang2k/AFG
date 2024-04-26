import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class DetailPage extends StatelessWidget {
 final String title;
 final String date;
 final String location;
 final String hostName;

 const DetailPage({Key? key, required this.title, required this.date, required this.location, required this.hostName}) : super(key: key);

 void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
 }

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(location),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Host: $hostName'),
              ],
            ),
            const Text('Date:'),
            Text(date),
            GestureDetector(
              onTap: () {
                _launchURL(
                    'https://www.google.com/maps/search/?api=1&query=${location.split(',')[0]}+${location.split(',')[1]}');
                     // Replace with your desired URL
                
              },
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                 color: Colors.blue,
                 borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                 'Visit address',
                 style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                 ),
                ),
              ),
            )
          ],
        ),
      ),
    );
 }

 Future<String> getPlacemarks(String location) async {
    List<String> parts = location.split(',');
    double? lat = double.tryParse(parts[0]);
    double? lon = double.tryParse(parts[1]);

    if (lat != null && lon != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      var address = '';

      if (placemarks.isNotEmpty) {
        var streets = placemarks.reversed
            .map((placemark) => placemark.street)
            .where((street) => street != null);

        streets = streets.where((street) =>
            street!.toLowerCase() !=
            placemarks.reversed.last.locality!
                .toLowerCase()); // Remove city names
        streets = streets
            .where((street) => !street!.contains('+')); // Remove street codes

        address += streets.join(', ');

        address += ', ${placemarks.reversed.last.subLocality ?? ''}';
        address += ', ${placemarks.reversed.last.locality ?? ''}';
        address += ', ${placemarks.reversed.last.subAdministrativeArea ?? ''}';
        address += ', ${placemarks.reversed.last.administrativeArea ?? ''}';
        address += ', ${placemarks.reversed.last.postalCode ?? ''}';
        address += ', ${placemarks.reversed.last.country ?? ''}';
      }
      print(address);

      return address;
      
    } else {
      throw 'Invalid location format';
    }
 }
}
