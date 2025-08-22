import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // 👈 add this
import 'package:ui_satnetcom_customer_services/provider/chat_provider.dart';
import 'package:ui_satnetcom_customer_services/screen/splash/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 👈 makes sure Firebase runs properly

  await Firebase.initializeApp(); // 👈 initialize Firebase

  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Service',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
