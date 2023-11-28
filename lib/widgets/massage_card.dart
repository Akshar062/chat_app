import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/helper/time_formater.dart';
import 'package:chat_app/models/massage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../main.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.formid;
    return InkWell(
      child: isMe ? _greenMessage() : _blueMessage(),
      onLongPress: () {
        _showBottomSheet(isMe);
      },
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
              padding: EdgeInsets.all(widget.message.type == 'text' ? 10 : 4),
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(200, 221, 245, 255), width: 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: const Color.fromARGB(200, 221, 245, 255),
              ),
              child: widget.message.type == 'text'
                  ? Text(
                      widget.message.msg,
                      style: const TextStyle(color: Colors.black),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.blue,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    )),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.send),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 18,
              ),
            const SizedBox(
              width: 3,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.send),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == 'text' ? 10 : 4),
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(250, 218, 255, 176), width: 1),
              borderRadius: widget.message.type == 'text'
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
              color: const Color.fromARGB(250, 218, 255, 176),
            ),
            child: widget.message.type == 'text'
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(color: Colors.black),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Colors.green,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        backgroundColor: Colors.grey[800],
        context: context,
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 5,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.015, horizontal: mq.width * 0.4),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              widget.message.type == 'text'
                  ? _OptionItem(
                      icon: const Icon(
                        Icons.content_copy,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: "Copy Text",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackBar(
                            context,
                            "Text Copied",
                            false,
                          );
                        });
                      },
                    )
                  : _OptionItem(
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: "Download Image",
                      onTap: () async {
                        try {
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: "Let's Chat")
                              .then((value) {
                            Navigator.pop(context);
                            if (value != null && value) {
                              Dialogs.showSnackBar(
                                context,
                                "Image Saved",
                                false,
                              );
                            }
                          });
                        } on Exception catch (e) {
                          Dialogs.showSnackBar(
                            context,
                            e.toString(),
                            true,
                          );
                        }
                      },
                    ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                indent: mq.width * 0.05,
                endIndent: mq.width * 0.05,
              ),
              // edit option
              if (widget.message.type == "text" && isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 28,
                  ),
                  title: "Edit",
                  onTap: () {
                    Navigator.pop(context);
                    _showUpdateMessageDialog();
                  },
                ),
              // delete option
              if (isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                  title: widget.message.type == 'text'
                      ? "Delete Message"
                      : "Delete Image",
                  onTap: () async {
                    await APIs.deleteMessage(widget.message).then((value) {
                      Navigator.pop(context);
                    });
                  },
                ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                indent: mq.width * 0.05,
                endIndent: mq.width * 0.05,
              ),
              _OptionItem(
                icon: const Icon(
                  Icons.done_all_rounded,
                  color: Colors.white,
                ),
                title: "Send At : ${MyDateUtil.getMessageTime(
                  context: context,
                  time: widget.message.send,
                )}",
                onTap: () {},
              ),
              //read time
              _OptionItem(
                icon: Icon(
                  Icons.done_all_rounded,
                  color: widget.message.read.isNotEmpty
                      ? Colors.blue
                      : Colors.grey,
                ),
                title: widget.message.read.isNotEmpty
                    ? "Read At : ${MyDateUtil.getMessageTime(
                        context: context,
                        time: widget.message.read,
                      )}"
                    : "Unseen",
                onTap: () {},
              ),
              // send time
            ],
          );
        });
  }

  void _showUpdateMessageDialog() {
    String message = widget.message.msg;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              contentPadding: const EdgeInsets.only(right: 20, left: 20, top: 10),
              backgroundColor: Colors.grey[800],
              title: const Row(
                children: [
                  Icon(
                    Icons.chat,
                    color: Colors.blue,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Edit Message"),
                ],
              ),
              content: TextFormField(
                cursorColor: Colors.blue,
                initialValue: message,
                maxLines: null,
                onChanged: (value) {
                  message = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                ),
                autofocus: true,
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue),
                    )),
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if(message.isNotEmpty) {
                        APIs.updateMessage(widget.message, message);
                      } else {
                        Dialogs.showSnackBar(
                          context,
                          "Message can't be empty",
                          true,
                        );
                      }
                    },
                    child: const Text(
                      "Update",
                      style: TextStyle(color: Colors.blue),
                    )),
              ]);
        });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String title;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * 0.05,
            top: mq.height * 0.015,
            bottom: mq.height * 0.015),
        child: Row(
          children: [
            icon,
            Text(
              ("  $title"),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
