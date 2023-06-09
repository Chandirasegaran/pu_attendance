import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pu_attendance/main.dart';

class StudHomePage extends StatefulWidget {
  const StudHomePage({Key? key}) : super(key: key);

  @override
  State<StudHomePage> createState() => _StudHomePageState();
}

class _StudHomePageState extends State<StudHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  _showAboutDialog();
                },
              ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  _logout();
                },
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Text("Hi Students"),
      ),
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
}
