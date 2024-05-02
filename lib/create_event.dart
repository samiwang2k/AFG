import 'dart:io';

import 'package:afg/signin.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

import 'jevent.dart';
import 'main.dart';
import 'point.dart';

class createPage extends StatefulWidget {
  const createPage({super.key});

  @override
  createPageState createState() => createPageState();
}

class createPageState extends State<createPage> {
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
    
      print(userInput);
    
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
        title: const Text('Event Create Page'),
        automaticallyImplyLeading: true,
      ),
      body: Column(children: [
        
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
         // Correctly placed conditional rendering
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
                              
                                print('Invalid date format');
                              
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
                                      
                                        print(pickedData.latLong.latitude);
                                        print(pickedData.latLong.longitude);
                                        print(pickedData.addressName);
                                      
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