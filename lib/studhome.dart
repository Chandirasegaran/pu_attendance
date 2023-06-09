import 'package:flutter/material.dart';

class studhomepage extends StatefulWidget {
  const studhomepage({super.key});

  @override
  State<studhomepage> createState() => _studhomepageState();
}

class _studhomepageState extends State<studhomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Text("Hi"),
    );
  }
}
