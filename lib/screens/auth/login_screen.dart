import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleLoginButtonClick() {
    final currentContext = context;
    Dialogs.showProgressBar(currentContext);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if(await APIs.userExists()){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (currentContext) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value){
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (currentContext) => const HomeScreen()));
          }).catchError((e){
            log("_handleLoginButtonClick: ${e.toString()}");
            Dialogs.showSnackBar(context, e.toString(), true);
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e){
      log("_signInWithGoogle: ${e.toString()}");
      Dialogs.showSnackBar(context, e.toString(), true);
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: const Text('Welcome to Let\'s Chat'),
        centerTitle: true,
      ),
      // Body
      body: Stack(children: [
        AnimatedPositioned(
          top: mq.height * 0.15,
          width: mq.width * 0.5,
          right: _isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
          duration: const Duration(milliseconds: 1000),
          child: Image.asset(
            'images/logo.png',
          ),
        ),
        Positioned(
            bottom: mq.height * 0.15,
            width: mq.width * 0.9,
            left: mq.width * 0.05,
            height: mq.height * 0.065,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  _handleLoginButtonClick();
                },
                icon: Image.asset("images/google.png", height: 30),
                label: const Text(
                  "Sign in with Google",
                  style: TextStyle(color: Colors.white),
                ))),
      ]),
    );
  }
}
