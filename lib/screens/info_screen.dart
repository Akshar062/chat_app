
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';

import '../helper/time_formater.dart';
import '../main.dart';

class InfoScreen extends StatefulWidget {
  final CUser user;
  const InfoScreen({super.key , required this.user});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // AppBar
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Joined On: ',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(
              MyDateUtil.getLastMessageTime(context: context, time : widget.user.createdAt,showYear: true),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.05,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child:CachedNetworkImage(
                      imageUrl: widget.user.image,
                      width: mq.width * 0.3,
                      height: mq.width * 0.3,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const CircleAvatar(
                            child: Icon(Icons.person),
                          )),
                ),
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.02,
                ),
                Text(
                  widget.user.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.001,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About: ',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      widget.user.about,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.02,
                ),
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.05,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
