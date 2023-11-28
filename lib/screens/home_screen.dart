import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CUser> _list = [];
  final List<CUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getCurrentUser();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          // AppBar
          appBar: AppBar(
            leading: const Icon(Icons.home),
            title: _isSearching
                ? TextField(
                    onChanged: (value) {
                      _searchList.clear();
                      for (var element in _list) {
                        if (element.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            element.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(element);
                        }
                      }
                      setState(() {
                        _searchList;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                    autofocus: true,
                  )
                : const Text('Let\'s Chat'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching ? Icons.close : Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                                user: APIs.me,
                              )));
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          // Body
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () async {
                _showAddDialog();
              },
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.chat),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => CUser.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              padding: const EdgeInsets.all(10),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _isSearching
                                  ? _searchList.length
                                  : _list.length,
                              itemBuilder: (context, index) {
                                return ChatUserCard(
                                    user: _isSearching
                                        ? _searchList[index]
                                        : _list[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('No User Found!'),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    String email = "";
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              contentPadding:
                  const EdgeInsets.only(right: 20, left: 20, top: 10),
              backgroundColor: Colors.grey[800],
              title: const Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Add Contect", style: TextStyle(fontSize: 16)),
                ],
              ),
              content: TextFormField(
                cursorColor: Colors.blue,
                maxLines: null,
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(
                  hintText: "Enter Email",
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.grey,
                  ),
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
                    onPressed: () async {
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Not Found')));
                          }
                        });
                      }
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(color: Colors.blue),
                    )),
              ]);
        });
  }
}
