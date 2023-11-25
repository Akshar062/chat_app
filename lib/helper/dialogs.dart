import 'package:flutter/material.dart';

class Dialogs{
  static void showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(
          color: Colors.white,
        )),
        backgroundColor: Colors.redAccent.withOpacity(0.5),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  static void showProgressBar(BuildContext context){
    showDialog(
      context: context,
      builder: (context){
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}