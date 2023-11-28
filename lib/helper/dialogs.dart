import 'package:flutter/material.dart';

class Dialogs{
  static void showSnackBar(BuildContext context, String message , bool isError){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(
          color: Colors.white,
        )),
        backgroundColor: isError ? Colors.redAccent.withOpacity(0.5) : Colors.white70.withOpacity(0.5),
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