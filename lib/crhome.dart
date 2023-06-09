import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pu_attendance/main.dart';

class CrHomePage extends StatefulWidget {
  const CrHomePage({Key? key}) : super(key: key);

  @override
  State<CrHomePage> createState() => _CrHomePageState();
}

class _CrHomePageState extends State<CrHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CR Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Set this property to false
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text("Hi CR"),
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
}
