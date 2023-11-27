import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/time_formater.dart';
import 'package:chat_app/models/massage.dart';
import 'package:flutter/material.dart';

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
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      print('updateMassageReadStatus');
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
}
