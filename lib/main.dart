import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:study_mate/credentials/login.dart';
import 'package:study_mate/pages/Mainpage.dart';
import 'package:study_mate/utilities/color_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
      print("granted");
    }

    var status2 = await Permission.manageExternalStorage.request();
    if (!status2.isGranted) {
      await Permission.manageExternalStorage.request();
      print("not granted");
    }
  }

  requestStoragePermission();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.darkTheme,
      home: (FirebaseAuth.instance.currentUser) != null ? Mainpage() : Login(),
    );
  }
}
