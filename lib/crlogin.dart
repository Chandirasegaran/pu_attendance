// import 'package:flutter/material.dart';
// import 'package:pu_attendance/main.dart';
//
// class Crlogin extends StatefulWidget {
//   const Crlogin({Key? key}) : super(key: key);
//
//   @override
//   State<Crlogin> createState() => _CrloginState();
// }
//
// class _CrloginState extends State<Crlogin> {
//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData(
//         useMaterial3: true,
//       ),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('CR Login'),
//           backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         ),
//         body: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.0),
//                   color: Colors.white,
//                 ),
//                 child: TextFormField(
//                   decoration: InputDecoration(
//                     labelText: 'Register Number',
//                     prefixIcon: Icon(Icons.person),
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.0),
//                   color: Colors.white,
//                 ),
//                 child: TextFormField(
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon: Icon(Icons.lock),
//                     border: InputBorder.none,
//                   ),
//                   obscureText: true,
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   // Implement the login logic here
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//                 child: Text(
//                   'Login',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pu_attendance/main.dart';
import 'package:pu_attendance/crhome.dart';

class Crlogin extends StatefulWidget {
  const Crlogin({Key? key}) : super(key: key);

  @override
  State<Crlogin> createState() => _CrloginState();
}

class _CrloginState extends State<Crlogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // User is already logged in, navigate to crhome.dart
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CrHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('CR Login'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: InputBorder.none,
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _login();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Login successful, navigate to crhome.dart
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CrHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError('No user found with this email.');
      } else if (e.code == 'wrong-password') {
        _showError('Wrong password.');
      } else {
        _showError('Error: ${e.code}');
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
