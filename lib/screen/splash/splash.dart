import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ui_satnetcom_customer_services/screen/home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkInternetAndNavigate();
  }

  Future<void> _checkInternetAndNavigate() async {
    // Cek koneksi internet
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      setState(() {
        _isConnected = true;
      });
    }

    // Tunggu selama koneksi masih tidak ada
    while (!_isConnected) {
      final result = await Connectivity().checkConnectivity();
      if (result != ConnectivityResult.none) {
        setState(() {
          _isConnected = true;
        });
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    // Setelah koneksi ada, navigasi ke Home
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.6)), // overlay
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "SNC CUSTOMER SERVICE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/icon.png',
                height: 100,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 20),
              Text(
                _isConnected ? "Connected" : "Waiting for connection...",
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
        ],
      ),
    );
  }
}
