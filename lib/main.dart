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
import 'styles.dart';
import 'firebase_options.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:geolocator/geolocator.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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

Future<void> addEvent(Jevent jevent) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentReference userDocRef = firestore.collection('users').doc(userId);

  // Fetch the user's document
  DocumentSnapshot userDocSnapshot = await userDocRef.get();

  // Check if the user's document exists and has an events array
  if (userDocSnapshot.exists &&
      (userDocSnapshot.data() as Map<String, dynamic>).containsKey('events')) {
    // If the events array exists, append the new event
    await userDocRef.update({
      'events': FieldValue.arrayUnion([jevent.toMap()]),
    });
  } else {
    // If the events array does not exist, create it with the new event
    await userDocRef.set({
      'events': [jevent.toMap()],
    }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields
  }
}

Future<void> readPoint() async {
  await firestore.collection('points').get().then((event) {
    Map<String, dynamic> data = event.docs.last.data();
    Point pt = Point.defined(data['x'], data['y']);
    if (kDebugMode) {
      print(pt);
    }
  });
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

  @override
  SecondRouteState createState() => SecondRouteState();
}

class SecondRouteState extends State<SecondRoute> {
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

        // Use widget.allJeventNames to access the allJeventNames list
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
        colorScheme: const ColorScheme.light(secondary: colorGray),
        textTheme: deviceWidth < 5000 ? textThemeSmall : textThemeDefault,
      ),
      child: Scaffold(
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
                        return const ListTile(
                          tileColor: Colors.white,
                          title: Text(
                            'No more events',
                            style: TextStyle(
                              color: Colors.black, // Set text color (optional)
                              fontSize: 16.0, // Set font size (optional)
                              fontWeight:
                                  FontWeight.w500, // Set font weight (optional)
                            ),
                          ),
                          subtitle: Text(
                            '',
                            style: TextStyle(
                              color: Colors.black, // Set text color (optional)
                              fontSize: 16.0, // Set font size (optional)
                              fontWeight:
                                  FontWeight.w500, // Set font weight (optional)
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailPage(
                                        title: widget.allJeventNames![index],
                                        hostName: widget.allHosts![index],
                                        date: widget.allDates![index],
                                        location: widget.allLocs![index])),
                              );
                              // Handle the tap event here
                              if (kDebugMode) {
                                print('ListTile tapped');
                              }
                            },
                            child: Container(
                              color: Colors.white,
                              child: ListTile(
                                tileColor: Colors.white,
                                title: Text(widget.allJeventNames![index]),
                                subtitle: Text(
                                    '${widget.allHosts![index]},${widget.allDates![index]},${widget.allLocs![index]}'),
                                textColor: Colors.black,
                                trailing:
                                    const Icon(Icons.arrow_forward_ios_rounded),
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
          title: const Text('Second Route'),
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
      ),
    );
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
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

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
            padding: const EdgeInsets.all(16),
            child: Form(
              key:
                  _formKey, // Assuming _formKey is defined as GlobalKey<FormState>
              child: Column(
                children: [
                  TextFormField(
                    controller: mc1,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onChanged: (val1) {
                      setState(() {
                        name = val1;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
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
                    child: Text(
                        buttonText), // Assuming buttonText is a variable holding the button text
                  ),

                  // TextFormField(
                  //   controller: mc2,
                  //   textInputAction: TextInputAction.next,
                  //   onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  //   onChanged: (val2) {
                  //     setState(() {
                  //       date = val2;
                  //     });
                  //   },
                  //   decoration: const InputDecoration(
                  //     hintText: 'Enter the date (mm/dd/yyyy)',
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter the date';
                  //     }
                  //     // Regular expression to match the date format 'mm/dd/yyyy'
                  //     final RegExp dateFormat = RegExp(
                  //         r'^(0[1-9]|1[0-2])/(0[1-9]|1\d|2\d|3[01])/(\d{4})$');
                  //     if (!dateFormat.hasMatch(value)) {
                  //       return 'Please enter a valid date in the format mm/dd/yyyy';
                  //     }
                  //     return null;
                  //   },
                  // ),
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
                      child: const Text('wow')),
                  TextFormField(
                    controller: mc4,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    onChanged: (val4) {
                      setState(() {
                        host = val4;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter the host',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the host';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Your existing code for handling the form submission
                        // For example, navigating to another screen or saving the data
                      }
                      final RegExp dateFormat = RegExp(
                          r'^(0[1-9]|1[0-2])/(0[1-9]|1\d|2\d|3[01])/(\d{4})$');
                      // Check if the date matches the format
                      if (dateFormat.hasMatch(buttonText)) {
                        newEvent = Jevent(
                          name: name,
                          date: buttonText,
                          location: createPoint(
                              place!), // Assuming createPoint is a function that converts 'place' to a Point object
                          hostName: host,
                        );
                        _showTextFields = false;
                        if (kDebugMode) {
                          print(newEvent);
                        }
                        String userId = FirebaseAuth
                            .instance.currentUser!.uid; // Get the user ID
                        if (kDebugMode) {
                          print('User ID: $userId');
                        } // Print the user ID
                        addEvent(newEvent!);
                      } else {
                        // Show an error message or handle the invalid date format
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please enter a valid date in the format mm/dd/yyyy')),
                        );
                      }
                    },
                    child: const Text('confirm'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('wow'),
                  ),
                  if (_pickedImage != null)
                    Image.file(
                  
                      _pickedImage!,
                      fit: BoxFit.cover,
                      height: 200, // Adjust the height as needed
                    ),
                ],
              ),
            ),
          )
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

  void _signUp() async {
    String? userId = await signUpWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );
    if (userId != null) {
      // Sign-up successful, navigate to the main content
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FirstRoute()),
        );
      }
    } else {
      if (mounted) {
        // Sign-up failed, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-up failed')),
        );
      }
    }
  }
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
