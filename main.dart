import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:i_need/demo.dart';
import 'package:i_need/trial2.dart';

// import 'Helper.dart';
// import 'SosPage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Helper.requestPermissions();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Helper.locationfetch();
  runApp(const MainApp());
}

class SystemChrome {}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}
