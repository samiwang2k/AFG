import 'package:afg/create_event.dart';
import 'package:afg/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'details.dart';
import 'jevent.dart';
import 'point.dart';
import 'firebase_options.dart';
import 'package:geolocator/geolocator.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:great_circle_distance_calculator/great_circle_distance_calculator.dart';

final List<String> allJeventNames = [];
final List<String> allHosts = [];
final List<String> allDates = [];
final List<String> allLocs = [];
final List<String> allUrls = [];
final List<String> allTimes = [];
final List<String> allAddress = [];
final List<String> sortedJeventNames = [];
final List<String> sortedHosts = [];
final List<String> sortedDates = [];
final List<String> sortedLocs = [];
final List<String> sortedUrls = [];
final List<String> sortedTimes = [];
final List<String> sortedAddress = [];
final distances = [];
final List<int> signups = [];

// This function asynchronously retrieves a list of signups from a Firestore collection named 'users'.
Future<List<int>> getAllSignups() async {
  // Initialize a reference to the Firestore instance.
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Retrieve all documents from the 'users' collection in Firestore.
  final QuerySnapshot querySnapshot = await firestore.collection('users').get();

  // Clear any existing signups in the 'signups' list.
  signups.clear();

  // Iterate over each document in the retrieved QuerySnapshot.
  for (var doc in querySnapshot.docs) {
    // Extract the 'signups' field from the current document, which is expected to be a list of dynamic types.
    final List<dynamic> jevents = doc['signups'];

    // Iterate over each item in the 'signups' list.
    for (var stringy in jevents) {
      // Add the index of the current item in the 'sortedLocs' list to the 'signups' list.
      // This assumes 'sortedLocs' is a list that contains the same items as 'jevents' but sorted in a specific order.
      signups.add(sortedLocs.indexOf(stringy));
    }
  }

  // Return the 'signups' list, which now contains the indices of the signups from the Firestore documents.
  return signups;
}

// This function asynchronously determines the current position of the device.
Future<Position> _determinePosition() async {
  // Declare a variable to hold the location permission status.
  LocationPermission permission;

  // Request location permission from the user.
  permission = await Geolocator.requestPermission();

  // Check if the permission was granted.
  permission = await Geolocator.checkPermission();

  // Request location permission again, which seems redundant based on the previous check.
  permission = await Geolocator.requestPermission();

  // If the permission is denied, the function does nothing and proceeds to get the current position.
  if (permission == LocationPermission.denied) {
    // No action is taken if the permission is denied.
  }

  // Attempt to get the current position of the device with low desired accuracy.
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low);

  // Return the current position of the device.
  return position;
}

final firestore = FirebaseFirestore.instance;

// This function asynchronously signs out the current user from Firebase Authentication.
Future<void> signOut() async {
  try {
    // Attempt to sign out the current user from Firebase Authentication.
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    // If an error occurs during the sign-out process, print the error message.
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

// Declare two variables to hold the latitude and longitude values.
double lat = 0;
double long = 0;

// This function asynchronously retrieves the current geographical position of the device.
void getPos() async {
  // Attempt to determine the current position of the device.
  Position? currentPos = await _determinePosition();

  // If a position was successfully determined, update the 'lat' and 'long' variables with the latitude and longitude values.
  lat = currentPos.latitude;
  long = currentPos.longitude;
}

// This function asynchronously retrieves all event data from a Firestore collection named 'users'.
Future<void> getAllEventData() async {
  // Initialize a reference to the Firestore instance.
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Retrieve all documents from the 'users' collection in Firestore.
  final QuerySnapshot querySnapshot = await firestore.collection('users').get();

  // Clear any existing data in the lists that will be populated with event data.
  allJeventNames.clear();
  allHosts.clear();
  allDates.clear();
  allLocs.clear();
  allUrls.clear();
  allTimes.clear();
  allAddress.clear();
  distances.clear();
  sortedJeventNames.clear();
  sortedHosts.clear();
  sortedDates.clear();
  sortedLocs.clear();
  sortedUrls.clear();
  sortedTimes.clear();
  sortedAddress.clear();

  // Iterate over each document in the retrieved QuerySnapshot.
  for (var doc in querySnapshot.docs) {
    // Extract the 'events' field from the current document, which is expected to be a list of dynamic types.
    final List<dynamic> jevents = doc['events'];

    // Iterate over each item in the 'events' list.
    for (var thingy in jevents) {
      // Add event details to their respective lists.
      allJeventNames.add(thingy['name']);
      allHosts.add(thingy['hostName']);
      allDates.add(thingy['date']);
      allLocs.add('${thingy['location']['x']}, ${thingy['location']['y']}');
      allUrls.add('${thingy['imageUrl']}');
      allTimes.add(thingy['time']);
      allAddress.add(thingy['address']);

      // Get the current position of the device.
      getPos();
      // Use the current position and the event's location to calculate the distance.
      final lat1 = lat;
      final lon1 = long;

      final lat2 = thingy['location']['x'];
      final lon2 = thingy['location']['y'];

      // Calculate the distance between the current position and the event's location.
      var gcd = GreatCircleDistance.fromDegrees(
          latitude1: lat1, longitude1: lon1, latitude2: lat2, longitude2: lon2);
      distances.add(gcd.haversineDistance());

      // Use allJeventNames to access the allJeventNames list
    }
    // Sort the distances and use them to sort the corresponding event data.
    List<double> sortedDistances = List.from(distances)..sort();

    for (int i = 0; i < sortedDistances.length; i++) {
      int index = distances.indexOf(sortedDistances[i]);
      sortedJeventNames.add(allJeventNames[index]);
      sortedHosts.add(allHosts[index]);
      sortedDates.add(allDates[index]);
      sortedLocs.add(allLocs[index]);
      sortedUrls.add(allUrls[index]);
      sortedTimes.add(allTimes[index]);
      sortedAddress.add(allAddress[index]);
    }
  }
}

// Declare a variable to hold the user's number (UID).
String? userNumber;

// This function asynchronously attempts to sign in a user with an email and password using Firebase Authentication.
Future<String?> signInWithEmailPassword(String email, String password) async {
  try {
    // Attempt to sign in the user with the provided email and password.
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // If the sign-in is successful, store the user's UID in the 'userNumber' variable and return it.
    userNumber = userCredential.user?.uid;
    return userCredential.user?.uid;
  } on FirebaseAuthException catch (e) {
    // If an error occurs during the sign-in process, handle it.
    // If the app is in debug mode, print the error message.
    if (kDebugMode) {
      print(e.message);
    }
    // Return null to indicate that the sign-in was not successful.
    return null;
  }
}

// ignore: unused_element
bool _showTextFields = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if the user is already signed in
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // User is already signed in, navigate to the main content

    runApp(const MaterialApp(
      title: 'AFG',
      home: FirstRoute(),
    ));
  } else {
    // User is not signed in, show the SignInForm
    runApp(const MaterialApp(
      title: 'AFG',
      home: SignInForm(),
    ));
  }
}

// This function attempts to create a Point object from a string input.
Point? createPoint(String inputted) {
  // Split the input string into a list of strings based on the comma delimiter.
  List<String> coordinates = inputted.split(',');

  // Check if the list contains exactly two elements (x and y coordinates).
  if (coordinates.length == 2) {
    // Attempt to parse the first element of the list as a double for the x-coordinate.
    double x = double.tryParse(coordinates[0]) ?? 0.0;
    // Attempt to parse the second element of the list as a double for the y-coordinate.
    double y = double.tryParse(coordinates[1]) ?? 0.0;

    // Create a Point object using the parsed x and y coordinates.
    Point rval = Point.defined(x, y);
    // Return the created Point object.
    return rval;
  }
  // If the input does not contain exactly two coordinates, return null.
  return null;
}

// Future<String> createEvent(String textyInput, File imageFile) async {
//   List<String> jevents = textyInput.split('#');
//   Jevent jevent = Jevent(
//     name: jevents[0],
//     date: jevents[1],
//     location: createPoint(
//         jevents[2]), // Assuming createPoint can handle a default value
//     hostName: jevents.last,
//   );

//   // Upload the image to Firebase Storage
//   final bytes = imageFile.readAsBytesSync();
//   var timestamp = DateTime.now();
//   final metadata = SettableMetadata(contentType: 'image/jpeg');
//   UploadTask task = FirebaseStorage.instance
//       .ref('EventImages/$timestamp/${imageFile.path.split('/').last}')
//       .putData(bytes, metadata);
//   TaskSnapshot downloadUrlSnapshot = await task;

//   // Get the download URL of the uploaded image
//   String imageUrl = await downloadUrlSnapshot.ref.getDownloadURL();
//   jevent.imageUrl = imageUrl; // Set the image URL in the Jevent object

//   if (kDebugMode) {
//     print(jevent);
//   }

//   // Save the event details to Firestore
//   CollectionReference events = FirebaseFirestore.instance.collection('events');

//   await events.add({
//     'name': jevent.name,
//     'date': jevent.date,
//     'location': jevent.location?.toMap(),
//     'hostName': jevent.hostName,
//     'imageUrl': jevent.imageUrl, 'time': jevent.time, // Save the image URL
//   });

//   return jevent.toString();
// }

// This function asynchronously adds a Point object to a Firestore collection named 'points'.
Future<void> addPoint(Point point) async {
  // Convert the Point object to a Map<String, dynamic> for storage in Firestore.
  Map<String, dynamic> pointMap = point.toMap();

  // Add the pointMap to the 'points' collection in Firestore.
  await firestore.collection('points').add(pointMap);
}

Future<void> addEvent(Jevent jevent, {File? imageFile}) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentReference userDocRef = firestore.collection('users').doc(userId);

  // Fetch the user's document
  DocumentSnapshot userDocSnapshot = await userDocRef.get();

  // Check if the user's document exists and has an events array
  if (userDocSnapshot.exists &&
      (userDocSnapshot.data() as Map<String, dynamic>).containsKey('events')) {
    // If the events array exists, handle image upload (if provided)
    if (imageFile != null) {
      String imageUrl = await uploadImage(imageFile);
      jevent.imageUrl = imageUrl;
    }
    await userDocRef.update({
      'events': FieldValue.arrayUnion([jevent.toMap()]),
    });
  } else {
    // If the events array does not exist, create it with the new event
    if (imageFile != null) {
      String imageUrl = await uploadImage(imageFile);
      jevent.imageUrl = imageUrl;
    }
    await userDocRef.set({
      'events': [jevent.toMap()],
    }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields
  }
}

// Helper function to upload image to Firebase Storage
Future<String> uploadImage(File imageFile) async {
  final bytes = imageFile.readAsBytesSync();
  var timestamp = DateTime.now();
  final metadata = SettableMetadata(contentType: 'image/jpeg');
  UploadTask task = FirebaseStorage.instance
      .ref('EventImages/$timestamp/${imageFile.path.split('/').last}')
      .putData(bytes, metadata);
  TaskSnapshot downloadUrlSnapshot = await task;
  String imageUrl = await downloadUrlSnapshot.ref.getDownloadURL();
  return imageUrl;
}

// This function is a shorthand for running the main application widget.
void nav() => runApp(MaterialApp(
      // Set the title of the application.
      title: 'GNav',
      // Set the initial route of the application to 'FirstRoute'.
      home: const FirstRoute(),
      // Define a builder function that takes the BuildContext and the child widget.
      builder: (BuildContext context, Widget? child) {
        // Return the child widget. The exclamation mark (!) is used to assert that 'child' is not null.
        // This is a way to ensure that the function always returns a widget.
        return child!;
      },
    ));

// Define a StatefulWidget named 'FirstRoute'.
class FirstRoute extends StatefulWidget {
  // Constructor for the FirstRoute class.
  // It takes a key as an optional named parameter and passes it to the superclass constructor.
  const FirstRoute({super.key});

  // Override the createState method to return an instance of FirstRouteState.
  @override
  FirstRouteState createState() => FirstRouteState();
}

// Define the State object for the FirstRoute StatefulWidget.
class FirstRouteState extends State<FirstRoute> {
  // Override the initState method to perform initial setup.
  @override
  void initState() {
    // Call the getPos, getAllEventData, and getAllSignups functions to perform initial data fetching.
    getPos();
    getAllEventData();
    getAllSignups();
    // Call the superclass initState method to ensure proper initialization.
    super.initState();
  }

  // Override the build method to describe the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold widget to provide a framework for the app's visual layout.
    return Scaffold(
      // Define the AppBar widget for the app bar.
      appBar: AppBar(
        // Set the title of the AppBar.
        title: const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Your Events'),
              Text('You have signed up for events'), // Use string interpolation
            ],
          ),
        ),
        // Disable the leading widget (back button) in the AppBar.
        automaticallyImplyLeading: false,
      ),
      // Define the body of the Scaffold as a FutureBuilder widget.
      body: FutureBuilder<List<int>>(
        // Set the future to be the result of the getAllSignups function.
        future: getAllSignups(), // This function returns Future<List<int>>
        // Define the builder function to describe the part of the user interface based on the future's state.
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          // If the future is still loading, show a CircularProgressIndicator.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If there's an error, display the error message.
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // If the future is complete, display the data in a ListView.
            return ListView.builder(
              // Set the itemCount to the length of the signups list.
              itemCount: signups.length,
              // Define the itemBuilder function to create each item in the list.
              itemBuilder: (BuildContext context, int index) {
                // Check if the index is within the valid range and present in signups.
                if (index >= allJeventNames.length ||
                    index >= allHosts.length ||
                    index >= allDates.length ||
                    index >= allLocs.length ||
                    !signups.contains(index)) {
                  // If the index is out of range or not in signups, return null.
                  return null;
                }

                // Create a Column widget for each item.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Define an InkWell widget for tapping.
                    InkWell(
                      onTap: () {
                        // Navigate to a DetailPage when tapped.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailPage(
                                  title: sortedJeventNames[index],
                                  hostName: sortedHosts[index],
                                  date: sortedDates[index],
                                  location: sortedLocs[index],
                                  imageUrl: sortedUrls[index],
                                  time: sortedTimes[index],
                                  address: sortedAddress[index])),
                        );
                        // Print a debug message if in debug mode.
                        if (kDebugMode) {
                          print('ListTile tapped');
                        }
                      },
                      // Define the child of the InkWell.
                      child: Container(
                        // Define the decoration for the container.
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.0),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 3.0,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ],
                        ),
                        // Define the padding and child of the container.
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Define the title text.
                              Text(
                                sortedJeventNames[index],
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              // Define the host text.
                              Row(
                                children: [
                                  const Text(
                                    "Hosted by: ",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    sortedHosts[index],
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              // Define the date text.
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 16.0, color: Colors.black),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    sortedDates[index],
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              // Define the location and time text.
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 16.0, color: Colors.black),
                                  const SizedBox(width: 5.0),
                                  Flexible(
                                    child: Text(
                                      sortedTimes[index],
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const Flexible(
                                    child: Text(
                                      " ",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      sortedAddress[index],
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add a divider after each item except the last one.
                    if (index < signups.length - 1) const Divider(),
                  ],
                );
              },
            );
          }
        },
      ),

      // Define a bottom navigation bar using a Container widget.
      bottomNavigationBar: Container(
        // Set the decoration for the container to have a white background and a subtle shadow.
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // Define the shadow properties.
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        // Use a SafeArea widget to ensure the navigation bar is displayed within the safe area of the screen.
        child: SafeArea(
          // Add padding to the navigation bar to ensure it's not too close to the edges of the screen.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            // Define the GNav widget for the navigation bar.
            child: GNav(
              // Set the ripple color for the navigation bar items.
              rippleColor: Colors.grey[300]!,
              // Set the hover color for the navigation bar items.
              hoverColor: Colors.grey[100]!,
              // Set the gap between the icons and text in the navigation bar items.
              gap: 8,
              // Set the active color for the navigation bar items.
              activeColor: Colors.black,
              // Set the size of the icons in the navigation bar items.
              iconSize: 24,
              // Set the padding around the navigation bar items.
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              // Set the duration for the navigation bar item animations.
              duration: const Duration(milliseconds: 400),
              // Set the background color for the active tab in the navigation bar.
              tabBackgroundColor: Colors.grey[100]!,
              // Set the color for the text in the navigation bar items.
              color: Colors.black,
              // Define the tabs for the navigation bar.
              tabs: const [
                GButton(
                  // Set the icon for the 'Home' tab.
                  icon: LineIcons.home,
                  // Set the text for the 'Home' tab.
                  text: 'Home',
                ),
                GButton(
                  // Set the icon for the 'Search' tab.
                  icon: LineIcons.search,
                  // Set the text for the 'Search' tab.
                  text: 'Search',
                ),
                GButton(
                  // Set the icon for the 'Profile' tab.
                  icon: LineIcons.user,
                  // Set the text for the 'Profile' tab.
                  text: 'Profile',
                ),
              ],
              // Set the index of the initially selected tab.
              selectedIndex: 0,
              // Define the callback for when the selected tab changes.
              onTabChange: (index) {
                // Use a switch statement to handle tab changes.
                switch (index) {
                  // If the 'Search' tab is selected, navigate to the SecondRoute.
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SecondRoute()),
                    );
                    break;
                  // If the 'Profile' tab is selected, navigate to the ThirdRoute.
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ThirdRoute()),
                    );
                    break;
                  // Default case does nothing.
                  default:
                    break;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SecondRoute extends StatefulWidget {
  // Constructor for the SecondRoute class.
  // It takes a key as an optional named parameter and passes it to the superclass constructor.
  const SecondRoute({super.key});

  // Override the createState method to return an instance of SecondRouteState.
  @override
  SecondRouteState createState() => SecondRouteState();
}

class SecondRouteState extends State<SecondRoute> {
  //final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation
  String name = '';
  String buttonText = ''; // Assuming variable holds selected date
  String place = '';
  String host = '';
  //File? _pickedImage;

  // Future<void> createEvent(BuildContext context) async {
  //   if (_formKey.currentState!.validate()) {
  //     // Check if an image is selected
  //     if (_pickedImage != null) {
  //       // Implement image upload logic (replace placeholder)
  //       String imageUrl = await uploadImage(
  //           _pickedImage!); // Replace with your upload function
  //       // Create the Jevent object
  //       final newEvent = Jevent(
  //         name: name,
  //         date: buttonText,
  //         location: createPoint(
  //             place), // Assuming createPoint can handle a default value
  //         hostName: host,
  //         imageUrl: imageUrl,
  //       );
  //       addEvent(newEvent); // Replace with your function to store the event
  //       // Reset form and image selection
  //       _formKey.currentState!.reset();
  //       setState(() {
  //         _pickedImage = null;
  //       });
  //     } else {
  //       // Show error message if no image selected
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Please select an image for the event'),
  //         ),
  //       );
  //     }
  //   }
  // }

  // Override the initState method to perform initial setup when the widget is inserted into the tree.
  @override
  void initState() {
    // Call the superclass initState method to ensure proper initialization.
    super.initState();
    // Commented out call to getAllEventData. Uncomment this line if you want to fetch event data when the widget is initialized.
    // getAllEventData();
  }

  // double lat = 0;
  // double long = 0;
  // void getPos() async {
  //   Position? currentPos = await _determinePosition();
  //   setState(() {
  //     lat = currentPos.latitude;
  //     long = currentPos.longitude;
  //   });
  //   if (kDebugMode) {
  //     print(currentPos.latitude);
  //     print(currentPos.longitude);
  //   }
  // }

  // This function asynchronously calculates the total number of events across all documents in the 'users' collection in Firestore.
  Future<int> getTotalEvents() async {
    // Initialize a counter for the total number of events.
    int totalJEvents = 0;

    // Get an instance of the Firestore service.
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Retrieve all documents from the 'users' collection in Firestore.
    final QuerySnapshot querySnapshot =
        await firestore.collection('users').get();

    // Iterate over each document in the retrieved QuerySnapshot.
    for (var doc in querySnapshot.docs) {
      // Extract the 'events' field from the current document, which is expected to be a list of dynamic types.
      final List<dynamic> jevents = doc['events'];

      // Add the length of the 'events' list to the total count of events.
      totalJEvents += jevents.length;
    }

    // Return the total count of events.
    return totalJEvents;
  }

  // Override the build method to describe the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    // Get the width and height of the device's screen.
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    // Return a Theme widget to apply a consistent theme across the app.
    return Theme(
        // Set the theme data, including primary color and color scheme.
        data: ThemeData(
          primaryColor: Colors.white,
          colorScheme: const ColorScheme.light(secondary: Colors.white),
        ),
        // Define the child of the Theme widget.
        child: Scaffold(
          // Set the background color of the Scaffold.
          backgroundColor: Colors.white,
          // Define the body of the Scaffold.
          body: SizedBox(
            // Set the width and height of the SizedBox to match the device's screen size.
            width: deviceWidth,
            height: deviceHeight,
            // Define the child of the SizedBox.
            child: Card(
              // Set the color, margin, and shape of the Card.
              color: Colors.white,
              margin: const EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              // Define the child of the Card.
              child: FutureBuilder<int>(
                // Set the future to be the result of the getTotalEvents function.
                future: getTotalEvents(),
                // Define the builder function to describe the part of the user interface based on the future's state.
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  // If the future is still loading, show a CircularProgressIndicator.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // If there's an error, display the error message.
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    // If the future is complete, display the data in a ListView.
                    return ListView.builder(
                      // Set the itemCount to the length of the sortedJeventNames list.
                      itemCount: sortedJeventNames.length,
                      // Define the itemBuilder function to create each item in the list.
                      itemBuilder: (BuildContext context, int index) {
                        // Check if the index is within the valid range of the lists
                        if (index >= allJeventNames.length ||
                            index >= allHosts.length ||
                            index >= allDates.length ||
                            index >= allLocs.length) {
                          // Handle the case where the index is out of range, e.g., return a default widget
                          return ListTile(
                            // Set the shape, title, and subtitle of the ListTile.
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(5)),
                            title: const Text(
                              'No more events',
                              style: TextStyle(
                                color:
                                    Colors.black, // Set text color (optional)
                                fontSize: 16.0, // Set font size (optional)
                                fontWeight: FontWeight
                                    .w500, // Set font weight (optional)
                              ),
                            ),
                            subtitle: const Text(
                              '',
                              style: TextStyle(
                                color:
                                    Colors.black, // Set text color (optional)
                                fontSize: 16.0, // Set font size (optional)
                                fontWeight: FontWeight
                                    .w500, // Set font weight (optional)
                              ),
                            ),
                          );
                        }
                        // Return a Column widget to display event details in a vertical list.
                        return Column(
                          // Align the content to the start of the column.
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // Define the children of the Column widget.
                          children: <Widget>[
                            // An InkWell widget that makes the entire event card clickable.
                            InkWell(
                              // Define the onTap callback to navigate to a DetailPage when the event card is tapped.
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                          title: sortedJeventNames[index],
                                          hostName: sortedHosts[index],
                                          date: sortedDates[index],
                                          location: sortedLocs[index],
                                          imageUrl: sortedUrls[index],
                                          time: sortedTimes[index],
                                          address: sortedAddress[index])),
                                );
                                // Print a debug message if in debug mode.
                                if (kDebugMode) {
                                  print('ListTile tapped');
                                }
                              },
                              // Define the child of the InkWell widget.
                              child: Container(
                                // Set the height of the container to 125.0.
                                height: 125.0,
                                // Define the decoration for the container.
                                decoration: BoxDecoration(
                                  // Add a border around the container.
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  // Set the background color of the container.
                                  color: Colors.white,
                                  // Add rounded corners to the container.
                                  borderRadius: BorderRadius.circular(10.0),
                                  // Add a subtle shadow to the container.
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 3.0, // Add a subtle shadow
                                      color: Colors.grey.withOpacity(
                                          0.2), // Light gray shadow
                                    ),
                                  ],
                                ),
                                // Define the child of the container.
                                child: Padding(
                                  // Add padding around the content inside the container.
                                  padding: const EdgeInsets.all(16.0),
                                  // Define the child of the padding.
                                  child: Column(
                                    // Align the content to the start of the column.
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // Define the children of the column.
                                    children: [
                                      // Display the event title.
                                      Text(
                                        sortedJeventNames[index],
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .black, // Black text for title
                                        ),
                                      ),
                                      // Display the host information.
                                      Row(
                                        children: [
                                          const Text(
                                            "Hosted by: ",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors
                                                  .black, // Black text for "Hosted by:"
                                            ),
                                          ),
                                          Text(
                                            sortedHosts[index],
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Display the date on a separate line.
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 16.0,
                                              color:
                                                  Colors.black), // Black icon
                                          const SizedBox(width: 5.0),
                                          Text(
                                            sortedDates[index],
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors
                                                  .black, // Black text for date
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Display the location on a separate line.
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 16.0, color: Colors.black),
                                          const SizedBox(width: 5.0),
                                          Flexible(
                                            child: Text(
                                              sortedTimes[index],
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const Flexible(
                                            child: Text(
                                              " ",
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              sortedAddress[index],
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (index < sortedJeventNames.length - 1)
                              const Divider(),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          // Define the AppBar widget for the Scaffold.
          appBar: AppBar(
            // Disable the leading widget (back button) by setting automaticallyImplyLeading to false.
            automaticallyImplyLeading: false,
            // Set the title of the AppBar.
            title: const Text(
              'Upcoming Events',
              // Set the text style for the title.
              style: TextStyle(
                color: Colors.black, // Set the text color to black.
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            // Set the background color of the FloatingActionButton to blue.
            backgroundColor: Colors.blue,
            // Set the child of the FloatingActionButton to an Icon widget.
            child: const Icon(Icons.add, color: Colors.white),
            // Define the onPressed callback for the FloatingActionButton.
            onPressed: () {
              // Update the state to show text fields.
              setState(() {
                _showTextFields = true;
              });
              // Navigate to the CreatePage when the FloatingActionButton is pressed.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePage()),
              );
            },
          ),
          bottomNavigationBar: Container(
            // Set the decoration for the Container to style the bottom navigation bar.
            decoration: BoxDecoration(
              // Set the background color of the Container to white.
              color: Colors.white,
              // Add a boxShadow to the Container for a shadow effect.
              boxShadow: [
                BoxShadow(
                  // Set the blur radius of the shadow.
                  blurRadius: 20,
                  // Set the color of the shadow with opacity.
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            // Use SafeArea to ensure the content is displayed within the safe area boundaries of the screen.
            child: SafeArea(
              // Define the child of the SafeArea widget.
              child: Padding(
                // Add padding around the content to create space at the edges.
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                // Define the child of the Padding widget.
                child: GNav(
                  // Set the ripple color for the navigation bar.
                  rippleColor: Colors.grey[300]!,
                  // Set the hover color for the navigation bar.
                  hoverColor: Colors.grey[100]!,
                  // Set the gap between the icons and text in the navigation bar.
                  gap: 8,
                  // Set the active color for the navigation bar.
                  activeColor: Colors.black,
                  // Set the size of the icons in the navigation bar.
                  iconSize: 24,
                  // Set the padding around the navigation bar.
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  // Set the duration for the transition animations in the navigation bar.
                  duration: const Duration(milliseconds: 400),
                  // Set the background color for the tabs in the navigation bar.
                  tabBackgroundColor: Colors.grey[100]!,
                  // Set the color for the navigation bar.
                  color: Colors.black,
                  // Define the tabs in the navigation bar.
                  tabs: const [
                    GButton(
                      // Set the icon for the Home tab.
                      icon: LineIcons.home,
                      // Set the text for the Home tab.
                      text: 'Home',
                    ),
                    GButton(
                      // Set the icon for the Search tab.
                      icon: LineIcons.search,
                      // Set the text for the Search tab.
                      text: 'Search',
                    ),
                    GButton(
                      // Set the icon for the Profile tab.
                      icon: LineIcons.user,
                      // Set the text for the Profile tab.
                      text: 'Profile',
                    ),
                  ],
                  // Set the index of the currently selected tab.
                  selectedIndex: 1,
                  // Define the callback for when the selected tab changes.
                  onTabChange: (index) {
                    // Use a switch statement to handle navigation based on the selected tab.
                    switch (index) {
                      case 0:
                        // Navigate to the FirstRoute when the Home tab is selected.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FirstRoute()),
                        );
                        break;
                      case 2:
                        // Navigate to the ThirdRoute when the Profile tab is selected.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ThirdRoute()),
                        );
                        break;
                      default:
                        // Handle other cases if needed.
                        break;
                    }
                  },
                ),
              ),
            ),
          ),
        ));
  }
}

class ThirdRoute extends StatefulWidget {
  // Define the constructor for ThirdRoute.
  // Use super.key to pass the key to the superclass constructor.
  const ThirdRoute({super.key});

  // Override the createState method to return an instance of ThirdRouteState.
  @override
  ThirdRouteState createState() => ThirdRouteState();
}

class ThirdRouteState extends State<ThirdRoute> {
  // Override the build method to describe the part of the user interface represented by the ThirdRoute widget.
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold widget to provide a framework for the app's visual layout.
    return Scaffold(
      // Define the AppBar widget for the Scaffold.
      appBar: AppBar(
        // Add a leading IconButton to the AppBar for navigation.
        leading: IconButton(
          // Set the icon for the IconButton to an arrow back icon.
          icon: const Icon(Icons.arrow_back),
          // Define the onPressed callback for the IconButton.
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Define the body of the Scaffold.
      body: Center(
        // Add a child widget to the Center widget.
        child: ElevatedButton(
          // Define the onPressed callback for the ElevatedButton.
          onPressed: () async {
            // Call the signOut function and await its completion.
            await signOut();
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                // Define the builder for the MaterialPageRoute to return a SignInForm widget.
                builder: (context) => const SignInForm(),
              ),
            );
          },
          // Define the style for the ElevatedButton.
          style: ElevatedButton.styleFrom(
            // Set the foreground color (text color) of the ElevatedButton.
            foregroundColor: Colors.white,
            // Set the background color of the ElevatedButton.
            backgroundColor: Colors.blue,
          ),
          // Define the child widget for the ElevatedButton.
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}

Future<String?> signUpWithEmailPassword(String email, String password) async {
  // Try to execute the sign-up process.
  try {
    // Use FirebaseAuth to create a new user with the provided email and password.
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      // Pass the email and password to the createUserWithEmailAndPassword method.
      email: email,
      password: password,
    );
    // If the sign-up is successful, return the user's UID.
    // The userCredential object contains information about the newly created user.
    return userCredential.user?.uid;
  } on FirebaseAuthException catch (e) {
    // Catch any FirebaseAuthException that might be thrown during the sign-up process.
    // This includes errors like invalid email format, weak password, etc.
    // If the app is in debug mode, print the error message for debugging purposes.
    if (kDebugMode) {
      print(e.message);
    }
    // Return null to indicate that the sign-up process did not succeed.
    return null;
  }
}

class SignUpForm extends StatefulWidget {
  // Define the constructor for SignUpForm.
  // Use super.key to pass the key to the superclass constructor.
  const SignUpForm({super.key});

  // Override the createState method to return an instance of SignUpFormState.
  @override
  SignUpFormState createState() => SignUpFormState();
}

// Define the State class for SignUpForm, which extends State<SignUpForm>.
class SignUpFormState extends State<SignUpForm> {
  // Declare a GlobalKey for the Form widget to validate the form.
  final _formKey = GlobalKey<FormState>();
  // Declare TextEditingController instances for the email and password fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Override the build method to describe the part of the user interface represented by the SignUpForm widget.
  @override
  Widget build(BuildContext context) {
    // Return a Material widget to provide a material design visual layout structure.
    return Material(
      // Define the child of the Material widget.
      child: Form(
        // Assign the GlobalKey to the Form widget to validate it.
        key: _formKey,
        // Define the child of the Form widget.
        child: Column(
          // Add children to the Column widget.
          children: [
            // Add a TextFormField for email input.
            TextFormField(
              // Assign the TextEditingController to the TextFormField for email.
              controller: _emailController,
              // Define the decoration for the TextFormField.
              decoration: const InputDecoration(labelText: 'Email'),
              // Define the validator for the TextFormField.
              validator: (value) {
                // Check if the value is null or empty and return an error message if true.
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                // Return null if the value is valid.
                return null;
              },
            ),
            // Add a TextFormField for password input.
            TextFormField(
              // Assign the TextEditingController to the TextFormField for password.
              controller: _passwordController,
              // Define the decoration for the TextFormField.
              decoration: const InputDecoration(labelText: 'Password'),
              // Define the validator for the TextFormField.
              validator: (value) {
                // Check if the value is null or empty and return an error message if true.
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                // Return null if the value is valid.
                return null;
              },
              // Set obscureText to true to hide the password input.
              obscureText: true,
            ),
            // Add an ElevatedButton to submit the form.
            ElevatedButton(
              // Define the onPressed callback for the ElevatedButton.
              onPressed: () {
                // Check if the form is valid by calling the validate method on the FormState.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, navigate to the SignInForm.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInForm()),
                  );
                }
              },
              // Define the child widget for the ElevatedButton.
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
  // void _signUp() async {
  //   String? userId = await signUpWithEmailPassword(
  //     _emailController.text,
  //     _passwordController.text,
  //   );
  //   if (userId != null) {
  //     // Sign-up successful, navigate to the main content
  //     if (mounted) {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => const FirstRoute()),
  //       );
  //     }
  //   } else {
  //     if (mounted) {
  //       // Sign-up failed, show an error message
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Sign-up failed')),
  //       );
  //     }
  //   }
  // }
}

// Define a StatefulWidget named CalendarPage.
class CalendarPage extends StatefulWidget {
  // Define the constructor for CalendarPage.
  // Use super.key to pass the key to the superclass constructor.
  const CalendarPage({super.key});

  // Override the createState method to return an instance of CalendarPageState.
  @override
  CalendarPageState createState() => CalendarPageState();
}

// Define the State class for CalendarPage, which extends State<CalendarPage>.
class CalendarPageState extends State<CalendarPage> {
  // Declare a list to hold DateTime objects representing selected dates.
  List<DateTime> _dates = [];

  // Override the build method to describe the part of the user interface represented by the CalendarPage widget.
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold widget to provide a framework for the app's visual layout.
    return Scaffold(
      // Define the AppBar widget for the Scaffold.
      appBar: AppBar(
        // Set the title of the AppBar.
        title: const Text('Calendar Date Picker 2'),
      ),
      // Define the body of the Scaffold.
      body: Center(
        // Add a child widget to the Center widget.
        child: CalendarDatePicker2(
          // Configure the CalendarDatePicker2 widget.
          config: CalendarDatePicker2Config(),
          // Set the value of the CalendarDatePicker2 widget to the list of selected dates.
          value: _dates,
          // Define the callback for when the value changes.
          onValueChanged: (dates) => setState(() => _dates = _dates),
        ),
      ),
    );
  }
}
