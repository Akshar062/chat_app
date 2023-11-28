import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print("Splash Screen ,  init called ............");
    Future.delayed(const Duration(seconds: 2), () {
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

      print('User: ${APIs.auth.currentUser}');

      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        //navigate to home screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        //navigate to login screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      // Body
      body: Stack(children: [
        Positioned(
          top: mq.height * 0.15,
          width: mq.width * 0.5,
          left: mq.width * 0.25,
          child: Image.asset(
            'images/logo.png',
          ),
        ),
      ]),
    );
  }
}
