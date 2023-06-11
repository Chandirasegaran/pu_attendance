import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pu_attendance/main.dart';
import 'package:pu_attendance/studhome.dart';
import 'package:pu_attendance/subjectname.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class CrHomePage extends StatefulWidget {
  const CrHomePage({Key? key}) : super(key: key);

  @override
  State<CrHomePage> createState() => _CrHomePageState();
}

class _CrHomePageState extends State<CrHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedSubject = '';
  late DateTime selectedDate;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late String selectedDateFormat;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    startTime = TimeOfDay.now();
    endTime = TimeOfDay.now();
    selectedSubject = 'OT'; // Set default selection to 'OT'
    selectedDateFormat = DateFormat('yyyy-M-d').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CR Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedSubject,
                items: [
                  for (String subject in SubjectData.subjects)
                    DropdownMenuItem(child: Text(subject), value: subject),
                ],
                onChanged: (String? value) {
                  setState(() {
                    selectedSubject = value!;
                  });
                },
                hint: Text('Select Subject'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _selectDate,
                child: Text('Select Date'),
              ),
              Text('Selected Date: ${selectedDate.toString().split(' ')[0]}'),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _selectStartTime,
                child: Text('Select Start Time'),
              ),
              Text('Selected Start Time: ${_formatTimeOfDay(startTime)}'),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _selectEndTime,
                child: Text('Select End Time'),
              ),
              Text('Selected End Time: ${_formatTimeOfDay(endTime)}'),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _generateAttendanceCSV,
                child: Text('View Attendance'),
              ),
            ],
          ),
        ),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedDateFormat = DateFormat('yyyy-M-d').format(selectedDate);
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (picked != null) {
      setState(() {
        endTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        // Permission already granted, return true
        return true;
      } else {
        // Permission not granted, request permission
        var status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      }
    } else {
      // For other platforms, continue with the existing storage permission logic
      return await Permission.storage.isGranted;
    }
  }

  Future<void> _generateAttendanceCSV() async {
    // Check if permission is granted
    if (await _checkStoragePermission()) {
      // Permission already granted, continue with generating the CSV file
      _createCSVFile();
    } else {
      // Permission denied, show an error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Permission Denied'),
            content: Text('Please grant permission to manage all files.'),
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

  // void _createCSVFile() async {
  //   final fileName =
  //       '${selectedSubject}_${selectedDateFormat}_${_formatTimeOfDay(startTime)}-${_formatTimeOfDay(endTime)}.csv';
  //
  //   final directory = await getExternalStorageDirectory();
  //   final path = '${directory!.path}/PU Attendance/$fileName';
  //
  //   // Retrieve attendance data from Firestore
  //   final attendanceData = await FirebaseFirestore.instance
  //       .collection('mscattendance')
  //       .where('subject', isEqualTo: selectedSubject)
  //       .where('date', isEqualTo: selectedDateFormat)
  //       .where('time', isGreaterThanOrEqualTo: _formatTimeOfDay(startTime))
  //       .where('time', isLessThanOrEqualTo: _formatTimeOfDay(endTime))
  //       .get();
  //
  //   // Convert attendance data to CSV format
  //   List<List<dynamic>> csvData = [];
  //   csvData.add(['Email', 'Subject', 'Date', 'Time']); // Header row
  //
  //   attendanceData.docs.forEach((doc) {
  //     final email = doc['email'];
  //     final subject = doc['subject'];
  //     final date = doc['date'];
  //     final time = doc['time'];
  //     csvData.add([email, subject, date, time]);
  //   });
  //
  //   // Generate CSV file
  //   String csvString = const ListToCsvConverter().convert(csvData);
  //   File csvFile = File(path);
  //   await csvFile.create(recursive: true);
  //   await csvFile.writeAsString(csvString);
  //
  //   // Show a dialog to inform the user about the download
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Attendance CSV'),
  //         content: Text(
  //             'Attendance has been saved as $fileName in PU Attendance directory.'),
  //         actions: [
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  void _createCSVFile() async {
    final fileName =
        '${selectedSubject}_${selectedDateFormat}_${_formatTimeOfDay(startTime)}-${_formatTimeOfDay(endTime)}.csv';

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/PU Attendance/$fileName';

    // Retrieve attendance data from Firestore
    final attendanceData = await FirebaseFirestore.instance
        .collection('mscattendance')
        .where('subject', isEqualTo: selectedSubject)
        .where('date', isEqualTo: selectedDateFormat)
        .where('time', isGreaterThanOrEqualTo: _formatTimeOfDay24(startTime))
        .where('time', isLessThanOrEqualTo: _formatTimeOfDay24(endTime))
        .get();

    // Convert attendance data to CSV format
    List<List<dynamic>> csvData = [];
    csvData.add(['Email', 'Subject', 'Date', 'Time']); // Header row

    attendanceData.docs.forEach((doc) {
      final email = doc['email'];
      final subject = doc['subject'];
      final date = doc['date'];
      final time = doc['time'];
      csvData.add([email, subject, date, time]);
    });

    // Generate CSV file
    String csvString = const ListToCsvConverter().convert(csvData);
    File csvFile = File(path);
    await csvFile.create(recursive: true);
    await csvFile.writeAsString(csvString);

    // Show a dialog to inform the user about the download
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Attendance CSV'),
          content: Text(
              'Attendance has been saved as $fileName in PU Attendance directory.'),
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

  String _formatTimeOfDay24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
