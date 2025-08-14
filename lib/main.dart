import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_satnetcom_customer_services/provider/chat_provider.dart';
import 'package:ui_satnetcom_customer_services/screen/splash/splash.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MyApp(),
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
