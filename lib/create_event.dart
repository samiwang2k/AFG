import 'dart:io';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:afg/signin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

import 'jevent.dart';
import 'main.dart';
import 'point.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  CreatePageState createState() => CreatePageState();
}

class CreatePageState extends State<CreatePage> {
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
      if (kDebugMode) {
        print(userInput);
      }
    }
  }

  Jevent? newEvent;

  String? name;
  String? date;
  String? host;
  String? place;

  String buttonText = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Event Create Page',
            style: TextStyle(color: Colors.black),
          ),
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          elevation: 0.5, // Add a slight shadow for depth
        ),
        body: SingleChildScrollView(
          // Wrap everything in SingleChildScrollView for scrollable content
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to the left
            children: [
              ElevatedButton(
                onPressed: () async {
                  await signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SignInForm(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Use a red color for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Sign Out'),
              ),
              const SizedBox(height: 16.0), // Add spacing between elements
              const Text(
                'Event Details',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: mc1,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                onChanged: (val1) {
                  setState(() {
                    name = val1;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter the name of the event',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the name of the event';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue, // Use a blue color for the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Select Date',
                      style: TextStyle(color: Colors.black),
                    ),
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
                                }
                                if (kDebugMode) {
                                  print(pickedData.latLong.longitude);
                                }
                                if (kDebugMode) {
                                  print(pickedData.addressName);
                                }

                                place =
                                    '${pickedData.latLong.latitude},${pickedData.latLong.longitude}';
                                Navigator.pop(context);
                              },
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue, // Use a green color for the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Select Location',
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Host Details',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
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
                decoration: InputDecoration(
                  hintText: 'Please enter the name of the host',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the host';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Use a grey color for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Pick Image',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              if (_pickedImage != null)
                Image.file(
                  _pickedImage!,
                  fit: BoxFit.cover,
                  height: 200, // Adjust the height as needed
                ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Check if an image is selected
                    if (_pickedImage != null) {
                      // Upload the image and get the URL
                      String imageUrl = await uploadImage(_pickedImage!);
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
                          content: Text('Please select an image for the event'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Use a teal color for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Create Event',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    DatePickerBdaya.showTime12hPicker(context,
                        showTitleActions: true, onChanged: (date) {
                      debugPrint(
                          'change $date in time zone ${date.timeZoneOffset.inHours}');
                    }, onConfirm: (date) {
                      debugPrint('confirm $date');
                    }, currentTime: DateTime.now());
                  },
                  child: const Text(
                    "time",
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          ),
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
                  selectedIndex: 3,
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
                          MaterialPageRoute(
                              builder: (context) => SecondRoute()),
                        );
                        break;
                      default:
                        break;
                    }
                  },
                ),
              ),
            )));
  }
}
