import 'package:afg/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image_proc;

class DetailPage extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String hostName;
  final String imageUrl;

  const DetailPage({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.hostName,
    required this.imageUrl,
  });

  void launchURL(String url) async {
    // Remove spaces from the URL string
    String urlWithoutSpaces = url.replaceAll(' ', '');

    // Parse the URL string into a Uri object
    var uri = Uri.parse(urlWithoutSpaces);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $urlWithoutSpaces';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorWhite,
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align content to left
            children: [
              Hero(
  tag: imageUrl,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: Image.network(
      imageUrl,
      width: double.infinity, // Fill available width
      fit: BoxFit.contain, // Maintain aspect ratio
    ),
  ),
),
              const SizedBox(height: 16.0), // Add spacing after image

              // Information box with rounded corners, border, and increased size
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(20.0), // Increased padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
                  children: [
                    // Title with larger font
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0), // Add spacing

                    //

// Host
Row(
children: [
const Text(
'Host: ',
style: TextStyle(fontSize: 14.0, color: Colors.grey),
),
Text(hostName),
],
),
const SizedBox(height: 4.0), // Add smaller spacing
// Location
Row(
children: [
const Text(
'Location: ',
style: TextStyle(fontSize: 14.0, color: Colors.grey),
),
Text(location),
],
),
const SizedBox(height: 4.0), // Add smaller spacing
// Date
Row(
children: [
const Text(
'Date: ',
style: TextStyle(fontSize: 14.0, color: Colors.grey),
),
Text(date),
],
),
],
),
),
const SizedBox(height: 16.0),
Center(child: 
          GestureDetector(
            onTap: () {
              launchURL(
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
            ),
          ),
        ],
      ),
    ),
  ),
  );
  }

  Future<double> getImageAspectRatio(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl)); // Use await
    final contentType = response.headers['content-type'];
    
    if (contentType != null && contentType.contains('image')) {
      final contentLength =
          int.tryParse(response.headers['content-length'] ?? '0');
      if (contentLength! > 0) {
        final imageBytes = response.bodyBytes; // Await here too
        final image = image_proc.decodeImage(imageBytes);
        return image!.height / image.width;
      }
    }
    return 1.0; // Default aspect ratio if unavailable
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
      if (kDebugMode) {
        print(address);
      }

      return address;
    } else {
      throw 'Invalid location format';
    }
  }
}
