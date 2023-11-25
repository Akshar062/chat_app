
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user.dart';

class ChatUserCard extends StatefulWidget {
  final CUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(imageUrl: widget.user.image,
              width: mq.width * 0.15,
              height: mq.width * 0.15,
             errorWidget: (context, url, error) => const CircleAvatar(
               child: Icon(Icons.person),
             )
            ),
          ),
          title: Text(widget.user.name),
          subtitle:Text(widget.user.about),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(widget.user.lastActive),
              const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.green,
                child: null
              ),
            ],
          ),
        ),
      ),
    );
  }
}
