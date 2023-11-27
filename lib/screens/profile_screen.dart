import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final CUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.extended(
            onPressed: () async {
              await APIs.updateActiveStatus(false);
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
            },
            backgroundColor: Colors.blueGrey,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.05,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                File(_image!),
                                width: mq.width * 0.3,
                                height: mq.width * 0.3,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                  imageUrl: widget.user.image,
                                  width: mq.width * 0.3,
                                  height: mq.width * 0.3,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                        child: Icon(Icons.person),
                                      )),
                            ),
                      Positioned(
                        bottom: -10,
                        right: -25,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: const CircleBorder(),
                          color: Colors.blueGrey,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.02,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.05,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (value) => APIs.me.name = value ?? '',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Enter your name',
                    ),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (value) => APIs.me.about = value ?? '',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter about';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'About',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: Icon(Icons.info_outline),
                      hintText: "Enter your about",
                    ),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.05,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setState(() {
                          Dialogs.showProgressBar(context);
                          APIs.updateInfo().then((value) {
                            Navigator.pop(context);
                          });
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('UPDATE',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        )),
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      minimumSize: Size(mq.width * 0.5, mq.height * 0.06),
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            children: [
              const Center(
                child: Text(
                  'Choose Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      log(" image path ${image.path}");
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateImage(File(_image!));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: Colors.blueGrey,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * 0.4, mq.height * 0.1),
                  ),
                  child: const Icon(
                    Icons.camera,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
                    );
                    if (image != null) {
                      log(" image path ${image.path}");
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateImage(File(_image!));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: Colors.blueGrey,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * 0.4, mq.height * 0.1),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                ),
              ]),
            ],
          );
        });
  }
}
