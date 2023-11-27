import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/massage.dart';
import '../models/user.dart';

class APIs {
  static late CUser me;
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  static Future<bool> userExists() async {
    return (await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  static Future<void> getCurrentUser() async {
    await firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        me = CUser.fromJson(value.data()!);
      } else {
        await createUser().then((value) => getCurrentUser());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final cuser = CUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: 'Hey there! I\'m using Let\'s Chat',
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return (await firestore
        .collection("users")
        .doc(user.uid)
        .set(cuser.toJson()));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      CUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  static Future<void> updateInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateImage(File file) async {
    final extension = file.path.split('.').last;
    final reference =
        storage.ref().child('profile_picture/${user.uid}.$extension');
    await reference
        .putFile(file, SettableMetadata(contentType: 'image/$extension'))
        .then((p0) => log(p0.toString()));
    me.image = await reference.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  /// ***** Chat Screen APIs *********

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMassage(CUser user) {
    return firestore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy('send', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      CUser chatUser, String msg, String type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final message = Message(
        formid: user.uid,
        toid: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        send: time);
    final ref = firestore
        .collection("chats/${getConversationID(chatUser.id)}/messages/");
    ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.formid)}/messages/')
        .doc(message.send)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMassage(
      CUser user) {
    return firestore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy('send', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendImage(CUser chatUser, File file) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final extension = file.path.split('.').last;
    final reference = storage
        .ref()
        .child('chats/${getConversationID(chatUser.id)}/$time.$extension');

    await reference
        .putFile(file, SettableMetadata(contentType: 'image/$extension'))
        .then((p0) => log(p0.toString()));

    final imageUrl = await reference.getDownloadURL();
    await sendMessage(chatUser, imageUrl, 'image');
  }
}
