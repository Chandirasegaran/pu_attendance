// import 'package:flutter/material.dart';
// import 'package:pu_attendance/main.dart';
//
// class StudentLoginPage extends StatefulWidget {
//   const StudentLoginPage({Key? key}) : super(key: key);
//
//   @override
//   State<StudentLoginPage> createState() => _StudentLoginPageState();
// }
//
// class _StudentLoginPageState extends State<StudentLoginPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Student Login'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.account_circle,
//               size: 80,
//               color: Theme.of(context).colorScheme.onBackground,
//             ),
//             SizedBox(height: 20),
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 color: Colors.white,
//               ),
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Register Number',
//                   prefixIcon: Icon(Icons.person),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 color: Colors.white,
//               ),
//               child: TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   prefixIcon: Icon(Icons.lock),
//                   border: InputBorder.none,
//                 ),
//                 obscureText: true,
//               ),
//             ),
//             SizedBox(height: 20),
//             TextButton(
//               onPressed: () {
//                 // Implement the action for the 'Forgot Password' button here
//               },
//               child: Text(
//                 'Forgot Password',
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Implement the login logic here
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//               ),
//               child: Text(
//                 'Login',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pu_attendance/crhome.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({Key? key}) : super(key: key);

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 80,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  _email = value;
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: InputBorder.none,
                ),
                obscureText: true,
                onChanged: (value) {
                  _password = value;
                },
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Implement the action for the 'Forgot Password' button here
              },
              child: Text(
                'Forgot Password',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
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
    );
  }

  void _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email!,
        password: _password!,
      );

      // Navigate to the Chrome page
      Navigator.push(context, MaterialPageRoute(builder: (_) => CrHomePage()));
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}
