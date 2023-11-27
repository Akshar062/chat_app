import 'dart:io';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/time_formater.dart';
import 'package:chat_app/models/massage.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/widgets/massage_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'info_screen.dart';

class ChatScreen extends StatefulWidget {
  final CUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Message> _list = [];
  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (_showEmoji) {
              setState(() {
                _showEmoji = false;
              });
              return false;
            } else {
              return true;
            }
          },
          child: Scaffold(
              backgroundColor: const Color.fromARGB(255, 80, 80, 80),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                flexibleSpace: _appBar(),
              ),
              body: Column(children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMassage(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox(
                            height: 10,
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                  'Hi there! Send a message to start chatting'),
                            );
                          }
                      }
                    },
                  ),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _isUploading
                            ? const LinearProgressIndicator()
                            : const SizedBox(height: 5))),
                _chatInput(),
                SizedBox(
                  height: _showEmoji ? 300 : 0,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: const Config(
                      bgColor: Colors.black,
                      columns: 7,
                      emojiSizeMax: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
              ])),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InfoScreen(user: widget.user)));

        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final datat = snapshot.data?.docs;
            final list =
                datat?.map((e) => CUser.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              widget.user.isOnline = list[0].isOnline;
            }
            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      list.isNotEmpty ? list[0].image : widget.user.image),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(fontSize: 16)),
                    Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            );
          },
        ));
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showEmoji = !_showEmoji;
                      FocusScope.of(context).unfocus();
                    });
                  },
                  icon: const Icon(Icons.emoji_emotions_outlined),
                ),
                Expanded(
                    child: TextField(
                  controller: _textController,
                  onTap: () {
                    setState(() {
                      _showEmoji = false;
                    });
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                  ),
                )),
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final List<XFile> image = await picker.pickMultiImage(
                      imageQuality: 50,
                    );
                    if (image.isNotEmpty) {
                      for (final XFile img in image) {
                        setState(() {
                          _isUploading = true;
                        });
                        await APIs.sendImage(widget.user, File(img.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.attach_file_outlined),
                ),
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker0 = ImagePicker();
                    final XFile? image = await picker0.pickImage(
                        source: ImageSource.camera, imageQuality: 50);
                    if (image != null) {
                      setState(() {
                        _isUploading = true;
                      });
                      await APIs.sendImage(widget.user, File(image.path));
                      setState(() {
                        _isUploading = false;
                      });
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
              ]),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, 'text');
                _textController.clear();
              }
            },
            padding: const EdgeInsets.all(8),
            minWidth: 0,
            shape: const CircleBorder(),
            color: Colors.blueGrey,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}