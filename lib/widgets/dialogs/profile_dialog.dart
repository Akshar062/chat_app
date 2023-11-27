import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../screens/info_screen.dart';

class ProfileDialog extends StatefulWidget {
  final CUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.grey[900],
      content: SizedBox(
        width: mq.width * 0.4,
        height: mq.height * 0.4,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  widget.user.image,
                  width: mq.width * 0.5,
                  height: mq.width * 0.5,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: mq.width * 0.05,
              top: mq.height * 0.02,
              width: mq.width * 0.4,
              child: Text(
                widget.user.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Positioned(
              right: 8,
              top: 6,
              child:  MaterialButton(
                onPressed:(){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>InfoScreen(user: widget.user)));
                },
                padding: EdgeInsets.zero,
                minWidth: 0,
                shape: const CircleBorder(),
                child: const Icon(Icons.info_outline,color: Colors.white,),

              ),
            )
          ],
        ),
      ),
    );
  }
}
