import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';

class StudHomePage extends StatefulWidget {
  const StudHomePage({Key? key}) : super(key: key);

  @override
  State<StudHomePage> createState() => _StudHomePageState();
}

class _StudHomePageState extends State<StudHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> subjects = [
    'ADS Theory',
    'OT',
    'MOS',
    'ADS Theory Lab',
    'MOS Lab',
    'Robotics',
    'Web Accessibility',
    'Neural Network'
  ];
  String selectedSubject = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('images/user.bmp'),
                  ),
                  SizedBox(height: 22),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        _auth.currentUser?.email ?? 'Email not found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: _showAboutDialog,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 0),
            Center(
              // Center the email
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text(
                    '${_auth.currentUser?.email ?? 'Email not found'}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Center(
              // Center the date
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.date_range, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text(
                    '${DateTime.now().toString().split(' ')[0]}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            buildRadioButtonList(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _markAttendance,
              child: Text('Mark Attendance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRadioButtonList() {
    return Column(
      children: [
        for (String subject in subjects)
          RadioListTile<String>(
            title: Text(subject),
            value: subject,
            groupValue: selectedSubject,
            onChanged: (String? value) {
              setState(() {
                selectedSubject = value ?? '';
              });
            },
          ),
      ],
    );
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About'),
          content: Text(
              'This app was developed by Chandirasegaran. \nMade with Flutter.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _markAttendance() async {
    if (selectedSubject.isEmpty) {
      // No subject selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please select a subject.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check user location permissions
    bool locationPermissionsGranted = await _checkLocationPermissions();
    if (!locationPermissionsGranted) {
      return;
    }

    // Check user location
    Position position = await _getUserLocation();

    double classroomLatitude = 12.015403;
    double classroomLongitude = 79.854978;
    double distanceThreshold = 200; // in meters

    double distanceInMeters = await Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      classroomLatitude,
      classroomLongitude,
    );

    if (distanceInMeters <= distanceThreshold) {
      // User is within the classroom radius
      String currentDateTime = '${DateTime.now()}';
      String email = _auth.currentUser?.email ?? 'Student';
      String attendanceDetails =
          'Name: $email\nSubject: $selectedSubject\nDate/Time: $currentDateTime';

      // Store attendance details in Firebase Firestore
      await FirebaseFirestore.instance.collection('mscattendance').add({
        'email': _auth.currentUser?.email,
        'subject': selectedSubject,
        'dateTime': currentDateTime,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attendance Marked'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You are present.'),
                SizedBox(height: 16),
                Text(
                  'Email: ${_auth.currentUser?.email}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Subject: $selectedSubject',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Date/Time: $currentDateTime',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      // User is not within the classroom radius
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attendance Not Marked'),
            content: Text(
                'You are not in the classroom.\n\nIf you are continuously getting this error:\n\n1. Check if precise location permission is given.\n2. Open Google Maps once and come back here.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> _checkLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Location Permission Required'),
              content: Text(
                  'This app requires location permission to mark attendance.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
        return false;
      }
    }
    return true;
  }

  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Service Disabled'),
            content:
                Text('Please enable location services to mark attendance.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      throw 'Location services are disabled.';
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    return position;
  }
}
