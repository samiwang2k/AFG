import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'details.dart';
import 'jevent.dart';
import 'point.dart';
import 'firebase_options.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:geolocator/geolocator.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:great_circle_distance_calculator/great_circle_distance_calculator.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  LocationPermission permission;
  permission = await Geolocator.requestPermission();
  permission = await Geolocator.checkPermission();
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    //nothing
  }
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low);
  return position;
}

final firestore = FirebaseFirestore.instance;

Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    if (kDebugMode) {
      print('User signed out');
    }
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

String? userNumber;

Future<String?> signInWithEmailPassword(String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // The user is signed in, return the user ID
    userNumber = userCredential.user?.uid;
    return userCredential.user?.uid;
  } on FirebaseAuthException catch (e) {
    // Handle sign-in errors
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  }
}

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

Point? createPoint(String inputted) {
  List<String> coordinates = inputted.split(',');
  if (coordinates.length == 2) {
    double x = double.tryParse(coordinates[0]) ?? 0.0;
    double y = double.tryParse(coordinates[1]) ?? 0.0;
    Point rval = Point.defined(x, y);
    return rval;
  }
  return null;
}

Future<String> createEvent(String textyInput, File imageFile) async {
  List<String> jevents = textyInput.split('#');
  Jevent jevent = Jevent(
    name: jevents[0],
    date: jevents[1],
    location: createPoint(
        jevents[2]), // Assuming createPoint can handle a default value
    hostName: jevents.last,
  );

  // Upload the image to Firebase Storage
  final bytes = imageFile.readAsBytesSync();
  var timestamp = DateTime.now();
  final metadata = SettableMetadata(contentType: 'image/jpeg');
  UploadTask task = FirebaseStorage.instance
      .ref('EventImages/$timestamp/${imageFile.path.split('/').last}')
      .putData(bytes, metadata);
  TaskSnapshot downloadUrlSnapshot = await task;

  // Get the download URL of the uploaded image
  String imageUrl = await downloadUrlSnapshot.ref.getDownloadURL();
  jevent.imageUrl = imageUrl; // Set the image URL in the Jevent object

  if (kDebugMode) {
    print(jevent);
  }

  // Save the event details to Firestore
  CollectionReference events = FirebaseFirestore.instance.collection('events');
  await events.add({
    'name': jevent.name,
    'date': jevent.date,
    'location': jevent.location?.toMap(),
    'hostName': jevent.hostName,
    'imageUrl': jevent.imageUrl, // Save the image URL
  });

  return jevent.toString();
}

Future<void> addPoint(Point point) async {
  Map<String, dynamic> pointMap = point.toMap();
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

void nav() => runApp(MaterialApp(
      title: 'GNav',
      home: const FirstRoute(),
      builder: (BuildContext context, Widget? child) {
        // You can perform any additional setup here if needed
        return child!;
      },
    ));

class FirstRoute extends StatefulWidget {
  const FirstRoute({super.key});

  @override
  FirstRouteState createState() => FirstRouteState();
}

class FirstRouteState extends State<FirstRoute> {
  String? please = 'press to work (please)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: 0,
              onTabChange: (index) {
                switch (index) {
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondRoute()),
                    );

                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ThirdRoute()),
                    );
                    break;
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
  SecondRoute({super.key});
  final List<String>? allJeventNames = [];
  final List<String>? allHosts = [];
  final List<String>? allDates = [];
  final List<String>? allLocs = [];
  final List<String>? allUrls = [];
  final List<String> sortedJeventNames = [];
  final List<String> sortedHosts = [];
  final List<String> sortedDates = [];
  final List<String> sortedLocs = [];
  final List<String> sortedUrls = [];
  final distances = [];

  @override
  SecondRouteState createState() => SecondRouteState();
}

class SecondRouteState extends State<SecondRoute> {
  bool _showTextFields = false;

  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation
  String name = '';
  String buttonText = ''; // Assuming variable holds selected date
  String place = '';
  String host = '';
  File? _pickedImage;

  void toggleFormVisibility() {
    setState(() {
      _showTextFields = !_showTextFields;
    });
  }

  Future<void> createEvent(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Check if an image is selected
      if (_pickedImage != null) {
        // Implement image upload logic (replace placeholder)
        String imageUrl = await uploadImage(
            _pickedImage!); // Replace with your upload function
        // Create the Jevent object
        final newEvent = Jevent(
          name: name,
          date: buttonText,
          location: createPoint(
              place), // Assuming createPoint can handle a default value
          hostName: host,
          imageUrl: imageUrl,
        );
        addEvent(newEvent); // Replace with your function to store the event
        // Reset form and image selection
        _formKey.currentState!.reset();
        setState(() {
          _pickedImage = null;
        });
      } else {
        // Show error message if no image selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image for the event'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getPos();

    getAllEventData();
  }

  double lat = 0;
  double long = 0;
  void getPos() async {
    Position? currentPos = await _determinePosition();
    setState(() {
      lat = currentPos.latitude;
      long = currentPos.longitude;
    });
    if (kDebugMode) {
      print(currentPos.latitude);
      print(currentPos.longitude);
    }
  }

  Future<int> getTotalEvents() async {
    int totalJEvents = 0;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('users').get();

    for (var doc in querySnapshot.docs) {
      final List<dynamic> jevents = doc['events'];

      totalJEvents += jevents.length;
    }

    return totalJEvents;
  }

  Future<void> getAllEventData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('users').get();

    for (var doc in querySnapshot.docs) {
      final List<dynamic> jevents = doc['events'];

      for (var thingy in jevents) {
        widget.allJeventNames?.add(thingy['name']);
        widget.allHosts?.add(thingy['hostName']);
        widget.allDates?.add(thingy['date']);

        widget.allLocs
            ?.add('${thingy['location']['x']}, ${thingy['location']['y']}');
        widget.allUrls?.add('${thingy['imageUrl']}');
        final lat1 = lat;
        final lon1 = long;

        final lat2 = thingy['location']['x'];
        final lon2 = thingy['location']['y'];

        var gcd = GreatCircleDistance.fromDegrees(
            latitude1: lat1,
            longitude1: lon1,
            latitude2: lat2,
            longitude2: lon2);
        widget.distances.add(gcd.haversineDistance());

        if (kDebugMode) {
          print(widget.distances);
        }

        // Use widget.allJeventNames to access the allJeventNames list
      }
      List<double> sortedDistances = List.from(widget.distances)..sort();

// Step 3: Reorder other lists based on sorted distances

      for (int i = 0; i < sortedDistances.length; i++) {
        int index = widget.distances.indexOf(sortedDistances[i]);
        widget.sortedJeventNames.add(widget.allJeventNames![index]);
        widget.sortedHosts.add(widget.allHosts![index]);
        widget.sortedDates.add(widget.allDates![index]);
        widget.sortedLocs.add(widget.allLocs![index]);
        widget.sortedUrls.add(widget.allUrls![index]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Theme(
        data: ThemeData(
          primaryColor: Colors.white,
          colorScheme: const ColorScheme.light(secondary: Colors.white),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: deviceWidth, // Set the width of the SizedBox
            height: deviceHeight,
            // Set the height of the SizedBox
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: FutureBuilder<int>(
                future: getTotalEvents(),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final int totalJEvents = snapshot.data!;
                    return ListView.builder(
                      itemCount: totalJEvents,
                      itemBuilder: (BuildContext context, int index) {
                        // Check if the index is within the valid range of the lists
                        if (index >= widget.allJeventNames!.length ||
                            index >= widget.allHosts!.length ||
                            index >= widget.allDates!.length ||
                            index >= widget.allLocs!.length) {
                          // Handle the case where the index is out of range, e.g., return a default widget
                          return ListTile(
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

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                            title:
                                                widget.sortedJeventNames[index],
                                            hostName: widget.sortedHosts[index],
                                            date: widget.sortedDates[index],
                                            location: widget.sortedLocs[index],
                                            imageUrl: widget.sortedUrls[index],
                                          )),
                                );
                                if (kDebugMode) {
                                  print('ListTile tapped');
                                }
                              },
                              child: Container(
                                // Adjust height based on the number of text lines
                                height: 125.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 3.0, // Add a subtle shadow
                                      color: Colors.grey.withOpacity(
                                          0.2), // Light gray shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      16.0), // Adjust padding for spacing
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Event title
                                      Text(
                                        widget.allJeventNames![index],
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .black, // Black text for title
                                        ),
                                      ),
                                      // Host information
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
                                            widget.sortedHosts[index],
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Date on a separate line
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 16.0,
                                              color:
                                                  Colors.black), // Black icon
                                          const SizedBox(width: 5.0),
                                          Text(
                                            widget.sortedDates[index],
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors
                                                  .black, // Black text for date
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Location on a separate line
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 16.0,
                                              color:
                                                  Colors.black), // Black icon
                                          const SizedBox(width: 5.0),
                                          Text(
                                            widget.sortedLocs[index],
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors
                                                  .black, // Black text for location
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (index < totalJEvents - 1) const Divider(),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Upcoming Events',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              setState(() {
                _showTextFields = true;
              });
            },
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 8,
                  activeColor: Colors.black,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.grey[100]!,
                  color: Colors.black,
                  tabs: const [
                    GButton(
                      icon: LineIcons.home,
                      text: 'Home',
                    ),
                    GButton(
                      icon: LineIcons.search,
                      text: 'Search',
                    ),
                    GButton(
                      icon: LineIcons.user,
                      text: 'Profile',
                    ),
                  ],
                  selectedIndex: 1,
                  onTabChange: (index) {
                    switch (index) {
                      case 0:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FirstRoute()),
                        );
                        break;
                      case 2:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ThirdRoute()),
                        );
                        break;
                      default:
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
  const ThirdRoute({super.key});

  @override
  ThirdRouteState createState() => ThirdRouteState();
}

class ThirdRouteState extends State<ThirdRoute> {
  String? please = 'hi';
  TextEditingController mc1 = TextEditingController();
  TextEditingController mc2 = TextEditingController();
  TextEditingController mc3 = TextEditingController();
  TextEditingController mc4 = TextEditingController();
  File? _pickedImage;
  String userInput = '';
  Point? point;
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  void printUserInput() {
    if (kDebugMode) {
      print(userInput);
    }
  }

  Jevent? newEvent;

  String? name;
  String? date;
  String? host;
  String? place;
  bool _showTextFields = false;
  String buttonText = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Route'),
        automaticallyImplyLeading: false,
      ),
      body: Column(children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showTextFields = true;
            });
          },
          child: const Text('Create Event',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
        ),
        ElevatedButton(
          onPressed: () async {
            await signOut();
            // Call the sign-out function
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) =>
                      const SignInForm()), // Navigate to the Sign-In page
            );
          },
          child: const Text('Sign Out'),
        ),
        if (_showTextFields) // Correctly placed conditional rendering
          Padding(
              padding: const EdgeInsets.all(0),
              child: Form(
                key:
                    _formKey, // Assuming _formKey is defined as GlobalKey<FormState>
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: mc1,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () =>
                            FocusScope.of(context).nextFocus(),
                        onChanged: (val1) {
                          setState(() {
                            name = val1;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter the name of the event',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter the name of the event';
                          }
                          return null;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            // Format the picked date into MM/dd/yyyy format
                            final String formattedDate =
                                DateFormat('MM/dd/yyyy').format(pickedDate);

                            // Validate the formatted date against the regular expression
                            final RegExp dateFormat = RegExp(
                                r'^(0[1-9]|1[0-2])/(0[1-9]|1\d|2\d|3[01])/(\d{4})$');
                            if (dateFormat.hasMatch(formattedDate)) {
                              // The date is valid, you can proceed with your logic
                              setState(() {
                                // Assuming you have a variable to hold the button text
                                // Update it with the selected date
                                buttonText = formattedDate;
                              });
                            } else {
                              // The date does not match the required format
                              // Handle this case as needed
                              if (kDebugMode) {
                                print('Invalid date format');
                              }
                            }
                          }
                        },
                        child: const Text(
                            'Select Date'), // Assuming buttonText is a variable holding the button text
                      ),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Select Location'),
                                  content: OpenStreetMapSearchAndPick(
                                    buttonColor: Colors.blue,
                                    buttonText: 'Set Current Location',
                                    onPicked: (pickedData) {
                                      if (kDebugMode) {
                                        print(pickedData.latLong.latitude);
                                        print(pickedData.latLong.longitude);
                                        print(pickedData.addressName);
                                      }
                                      place =
                                          '${pickedData.latLong.latitude},${pickedData.latLong.longitude}';
                                      Navigator.pop(context);
                                    },
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Select Location')),
                      TextFormField(
                        controller: mc4,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () =>
                            FocusScope.of(context).unfocus(),
                        onChanged: (val4) {
                          setState(() {
                            host = val4;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Please enter the name of the host',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the name of the host';
                          }
                          return null;
                        },
                      ),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Pick Image'),
                      ),
                      if (_pickedImage != null)
                        Image.file(
                          _pickedImage!,
                          fit: BoxFit.cover,
                          height: 200, // Adjust the height as needed
                        ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Check if an image is selected
                            if (_pickedImage != null) {
                              // Upload the image and get the URL
                              String imageUrl =
                                  await uploadImage(_pickedImage!);
                              // Create the Jevent object with the image URL
                              final newEvent = Jevent(
                                name: name,
                                date: buttonText,
                                location: createPoint(
                                    place!), // Assuming createPoint can handle a default value
                                hostName: host,
                                imageUrl: imageUrl,
                              );
                              addEvent(newEvent);
                              // Reset form and image selection
                              _formKey.currentState!.reset();
                              setState(() {
                                _pickedImage = null;
                              });
                            } else {
                              // Show error message if no image selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please select an image for the event'),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Create Event'),
                      ),
                    ],
                  ),
                ),
              ))
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: 2,
              onTabChange: (index) {
                switch (index) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FirstRoute()),
                    );
                    break;
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondRoute()),
                    );
                    break;
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

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  SignInFormState createState() => SignInFormState();
}

class SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      // Add Material widget here
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signIn();
                }
              },
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignUpForm()),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    String? userId = await signInWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );
    if (userId != null) {
      if (mounted) {
        // Sign-in successful, navigate to the main content
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FirstRoute()),
        );
      }
    } else {
      if (mounted) {
        // Sign-in failed, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in failed')),
        );
      }
    }
  }
}

Future<String?> signUpWithEmailPassword(String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // The user is signed up, return the user ID
    return userCredential.user?.uid;
  } on FirebaseAuthException catch (e) {
    // Handle sign-up errors
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInForm()),
                  );
                }
              },
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

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  List<DateTime> _dates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Date Picker 2'),
      ),
      body: Center(
        child: CalendarDatePicker2(
          config: CalendarDatePicker2Config(),
          value: _dates,
          onValueChanged: (dates) => setState(() => _dates = _dates),
        ),
      ),
    );
  }
}
