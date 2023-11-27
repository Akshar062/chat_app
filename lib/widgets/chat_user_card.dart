import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/time_formater.dart';
import 'package:chat_app/models/massage.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final CUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMassage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                message = list[0];
              }
              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                        imageUrl: widget.user.image,
                        width: mq.width * 0.15,
                        height: mq.width * 0.15,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              child: Icon(Icons.person),
                            )),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(
                  message != null
                      ? message!.type == 'text'
                          ? message!.msg
                          : 'Image'
                      : widget.user.about,
                  maxLines: 1,
                ),
                trailing: message == null
                    ? null
                    : message!.read.isEmpty && message!.formid != APIs.user.uid
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.green,
                                  child: null),
                            ],
                          )
                        : Text(MyDateUtil.getLastMessageTime(
                            context: context,
                            time: message!.send,
                            showYear: false)),
              );
            },
          )),
    );
  }
}
