import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'details.dart';
import 'jevent.dart';
import 'point.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

String createEvent(String textyInput) {
  List<String> jevents = textyInput.split('#');
  Jevent jevent = Jevent(
    name: jevents[0],
    date: jevents[1],
    location: createPoint(
        jevents[2]), // Assuming createPoint can handle a default value
    hostName: jevents.last,
  );
  if (kDebugMode) {
    print(jevent);
  }
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
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.ltr, child: child!);
      },
      title: 'GNav',
      theme: ThemeData(
        primaryColor: Colors.grey[800],
      ),
      home: const FirstRoute(),
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
        title: const Text('First Route'),
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

    getAllEventData();
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
        widget.allLocs?.add(thingy['location'].toString());

        // Use widget.allJeventNames to access the allJeventNames list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 300, // Set the width of the SizedBox
        height: 500, // Set the height of the SizedBox
        child: Card(
          margin: const EdgeInsets.all(10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.25),
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
                          child: ListTile(
                            title: Text(widget.allJeventNames![index]),
                            subtitle: Text(
                                '${widget.allHosts![index]},${widget.allDates![index]},${widget.allLocs![index]}'),
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

  String userInput = '';
  Point? point;

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
          child: const Text('Please!',
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
                  TextFormField(
                    controller: mc2,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onChanged: (val2) {
                      setState(() {
                        date = val2;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter the date (mm/dd/yyyy)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the date';
                      }
                      // Regular expression to match the date format 'mm/dd/yyyy'
                      final RegExp dateFormat = RegExp(
                          r'^(0[1-9]|1[0-2])/(0[1-9]|1\d|2\d|3[01])/(\d{4})$');
                      if (!dateFormat.hasMatch(value)) {
                        return 'Please enter a valid date in the format mm/dd/yyyy';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: mc3,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onChanged: (val3) {
                      setState(() {
                        place = val3;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter the place (latitude, longitude)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the place';
                      }
                      // Regular expression to match the format (double, double)
                      final RegExp locationFormat =
                          RegExp(r'^\(-?\d+(\.\d+)?,\s?-?\d+(\.\d+)?\)$');
                      if (!locationFormat.hasMatch(value)) {
                        return 'Please enter a valid location in the format (latitude, longitude)';
                      }
                      // Optionally, parse the location into two double values
                      final locationParts =
                          value.substring(1, value.length - 1).split(',');
                      final latitude = double.tryParse(locationParts[0].trim());
                      final longitude =
                          double.tryParse(locationParts[1].trim());
                      if (latitude == null || longitude == null) {
                        return 'Invalid location format';
                      }
                      // If you need to use the parsed latitude and longitude, you can do so here
                      // For example, setting them to state variables or using them directly
                      return null;
                    },
                  ),
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
                    },
                    child: const Text('confirm'),
                  )
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
                  _signUp();
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

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _selectLocation(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
    _convertAddressToCoordinates(location);
  }

  Future<void> _convertAddressToCoordinates(LatLng location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      Placemark place = placemarks[0];
      if (kDebugMode) {
        print(
            'Selected address: ${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.42796133580664, -122.085749655962),
          zoom: 14.4746,
        ),
        onTap: (LatLng location) {
          _selectLocation(location);
        },
      ),
    );
  }
}
