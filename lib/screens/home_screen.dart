import 'package:chat_app/api/apis.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (APIs.auth.currentUser != null) {
        if (msg == AppLifecycleState.resumed.toString()) {
          await APIs.getCurrentUser();
          await APIs.updateActiveStatus(true);
        }
        if (msg == AppLifecycleState.paused.toString()) {
          await APIs.updateActiveStatus(false);
        }
      }
      return Future.value(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          // AppBar
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
            ),
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
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
              },
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.chat),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something Went Wrong!'),
                    );
                  } else {
                    final data = snapshot.data?.docs;
                    _list =
                        data?.map((e) => CUser.fromJson(e.data())).toList() ??
                            [];
                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        itemCount:
                            _isSearching ? _searchList.length : _list.length,
                        itemBuilder: (context, index) {
                          return ChatUserCard(user: _list[index]);
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('No User Found!'),
                      );
                    }
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
