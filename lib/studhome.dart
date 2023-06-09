import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pu_attendance/main.dart';
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
              onTap: () {
                _logout();
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                _showAboutDialog();
              },
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
              onPressed: () {
                _markAttendance();
              },
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MyHomePage(title: 'M.Sc. Attendance')),
      (Route<dynamic> route) => false,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About'),
          content: Text('This app was developed by Chandirasegaran.'),
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
      String name = _auth.currentUser?.displayName ?? 'Student';
      String attendanceDetails =
          'Name: $name\nSubject: $selectedSubject\nDate/Time: $currentDateTime';

      // TODO: Store attendanceDetails to Firebase in a table-like structure

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
            content: Text('You are not in the classroom.'),
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

  Future<Position> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:pu_attendance/main.dart';
// import 'package:geolocator/geolocator.dart';
//
// class StudHomePage extends StatefulWidget {
//   const StudHomePage({Key? key}) : super(key: key);
//
//   @override
//   State<StudHomePage> createState() => _StudHomePageState();
// }
//
// class _StudHomePageState extends State<StudHomePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final List<String> subjects = [
//     'ADS Theory',
//     'OT',
//     'MOS',
//     'ADS Theory Lab',
//     'MOS Lab',
//     'Robotics',
//     'Web Accessibility',
//     'Neural Network'
//   ];
//   String selectedSubject = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Student Dashboard'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundImage: AssetImage('images/user.bmp'),
//                   ),
//                   SizedBox(height: 22),
//                   Row(
//                     children: [
//                       Icon(Icons.email, color: Colors.white),
//                       SizedBox(width: 8),
//                       Text(
//                         _auth.currentUser?.email ?? 'Email not found',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.logout),
//               title: Text('Logout'),
//               onTap: () {
//                 _logout();
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.info),
//               title: Text('About'),
//               onTap: () {
//                 _showAboutDialog();
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(height: 0),
//             Row(
//               children: [
//                 Icon(Icons.email, color: Colors.deepPurple),
//                 SizedBox(width: 8),
//                 Text(
//                   '${_auth.currentUser?.email ?? 'Email not found'}',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(Icons.date_range, color: Colors.deepPurple),
//                 SizedBox(width: 8),
//                 Text(
//                   '${DateTime.now().toString().split(' ')[0]}',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             buildRadioButtonList(),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 _markAttendance();
//               },
//               child: Text('Mark Attendance'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildRadioButtonList() {
//     return Column(
//       children: [
//         for (String subject in subjects)
//           RadioListTile<String>(
//             title: Text(subject),
//             value: subject,
//             groupValue: selectedSubject,
//             onChanged: (String? value) {
//               setState(() {
//                 selectedSubject = value ?? '';
//               });
//             },
//           ),
//       ],
//     );
//   }
//
//   void _logout() async {
//     await _auth.signOut();
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => MyHomePage(title: 'M.Sc. Attendance')),
//       (Route<dynamic> route) => false,
//     );
//   }
//
//   void _showAboutDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('About'),
//           content: Text('This app was developed by Chandirasegaran.'),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _markAttendance() async {
//     if (selectedSubject.isEmpty) {
//       // No subject selected
//       return;
//     }
//
//     // Check user location
//     Position position = await _getUserLocation();
//
//     double classroomLatitude = 12.015403;
//     double classroomLongitude = 79.854978;
//     double distanceThreshold = 200; // in meters
//
//     double distanceInMeters = await Geolocator.distanceBetween(
//       position.latitude,
//       position.longitude,
//       classroomLatitude,
//       classroomLongitude,
//     );
//
//     if (distanceInMeters <= distanceThreshold) {
//       // User is within the classroom radius
//       String currentDateTime = '${DateTime.now()}';
//       String name = _auth.currentUser?.displayName ?? 'Student';
//       String attendanceDetails =
//           'Name: $name\nSubject: $selectedSubject\nDate/Time: $currentDateTime';
//
//       // TODO: Store attendanceDetails to Firebase in a table-like structure
//
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Attendance Marked'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('You are present.'),
//                 SizedBox(height: 16),
//                 Text(
//                   'Email: ${_auth.currentUser?.email}',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Subject: $selectedSubject',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Date/Time: $currentDateTime',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             actions: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('Close'),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       // User is not within the classroom radius
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Attendance Not Marked'),
//             content: Text('You are not in the classroom.'),
//             actions: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('Close'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   Future<Position> _getUserLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.deniedForever) {
//       throw Exception(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission != LocationPermission.whileInUse &&
//           permission != LocationPermission.always) {
//         throw Exception(
//             'Location permissions are denied (actual value: $permission).');
//       }
//     }
//
//     return await Geolocator.getCurrentPosition();
//   }
// }
