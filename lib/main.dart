import 'package:flutter/material.dart';
// import 'package:pu_attendance/crlogin.dart';
// import 'package:pu_attendance/studlogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pu_attendance/crhome.dart';
import 'package:pu_attendance/studhome.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PU Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'M.Sc. Attendance'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

      String loginEmail = userCredential.user!.email!;
      if (loginEmail == '19384104@pondiuni.ac.in') {
        // Navigate to the CR Home page
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => CrHomePage()));
      } else {
        // Navigate to the Student Home page
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => studhomepage()));
      }
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

// import 'package:flutter/material.dart';
// import 'package:pu_attendance/crlogin.dart';
// import 'package:pu_attendance/studlogin.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:pu_attendance/crhome.dart';
// import 'package:firebase_core/firebase_core.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
//   // Your other code goes here.
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PU Attendance',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'M.Sc. Attendance'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String? _email;
//   String? _password;
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
//                   labelText: 'Email',
//                   prefixIcon: Icon(Icons.email),
//                   border: InputBorder.none,
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 onChanged: (value) {
//                   _email = value;
//                 },
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
//                 onChanged: (value) {
//                   _password = value;
//                 },
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
//                 _login();
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
//
//   void _login() async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: _email!,
//         password: _password!,
//       );
//
//       // Navigate to the Chrome page
//       Navigator.push(context, MaterialPageRoute(builder: (_) => CrHomePage()));
//     } catch (e) {
//       // Show an error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//         ),
//       );
//     }
//   }
// }
