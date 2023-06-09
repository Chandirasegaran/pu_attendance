import 'package:flutter/material.dart';
import 'package:pu_attendance/main.dart';

class CrHomePage extends StatefulWidget {
  const CrHomePage({super.key});

  @override
  State<CrHomePage> createState() => _CrHomePageState();
}

class _CrHomePageState extends State<CrHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CR Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Text("Hi"),
    );
  }
}
