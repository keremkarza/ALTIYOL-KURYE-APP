import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'home_screen.dart';
import 'login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash-screen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        if (mounted) {
          if (user == null) {
            Navigator.pushReplacementNamed(context, LoginScreen.id);
          } else {
            Navigator.pushReplacementNamed(context, HomeScreen.id);
          }
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Hero(
                  child:
                      Image.asset("images/ALTIYOL_LOGO_RENK_TRANSPARENT.png"),
                  tag: 'logo',
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "ALTIYOL KURYE",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 25,
                  ),
                ),
                SpinKitWave(
                  color: Colors.black87,
                  size: 50.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
