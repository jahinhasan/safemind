import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // ignore: avoid_print
    print('Firebase initialized successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Firebase initialization failed: $e');
  }
  
  runApp(const SafeMindApp());
}
