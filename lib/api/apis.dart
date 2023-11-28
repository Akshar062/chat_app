import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import '../models/massage.dart';
import '../models/user.dart';

class APIs {

  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static CUser me = CUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  static User get user => auth.currentUser!;

  static Future<void> getFirebaseToken() async {
    await messaging.requestPermission();
    await messaging.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
        log('Push Token: $value');
      }
    });
  }

  static Future<void> sendPushNotification(CUser chatUser, String msg) async {
    try {
      final body = {
        'to': chatUser.pushToken,
        'notification': {
          'title': me.name,
          'body': msg,
          'android_channel_id': 'chats'
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          'screen': 'chat',
          'user': jsonEncode(me.toJson())
        }
      };
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var res = await post(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'key=AAAAfJsFogo:APA91bFf5pvhETP9hU9OS5w6xHkifGWMgWODJa2WhQGOeZ6FlWQUaK_cU6MJCkD2R5sly_mJA_lblkJ_-r95IuCU0ktgTH6FLTjbMC4G53XqmBFGxvUvb8Tx21pktGYhJvUAh843e-57'
      }, body: {
        jsonEncode(body)
      });
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  /// ***** Auth APIs *********

  static Future<bool> userExists() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection("users")
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      log('user exists: ${data.docs.first.data()}');
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection("users")
        .doc(user.uid)
        .collection('contacts')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      CUser chatUser, String msg, String type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('contacts')
        .doc(chatUser.id)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Future<void> getCurrentUser() async {
    await firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        me = CUser.fromJson(value.data()!);
        await getFirebaseToken();
        APIs.updateActiveStatus(true);
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');
    return firestore
        .collection("users")
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
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
      'push_token': me.pushToken,
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
    log('Extension: $extension');
    final reference =
        storage.ref().child('profile_picture/${user.uid}.$extension');
    await reference
        .putFile(file, SettableMetadata(contentType: 'image/$extension'))
        .then((p0) => log('Data Transferred: ${p0.bytesTransferred / 1000} kb'));
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
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == 'text' ? msg : 'image'));
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
    final time = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final reference = storage
        .ref()
        .child('images/${getConversationID(chatUser.id)}/$time.$extension');

    await reference
        .putFile(file, SettableMetadata(contentType: 'image/$extension'))
        .then((p0) => log('Data Transferred: ${p0.bytesTransferred / 1000} kb'));

    final imageUrl = await reference.getDownloadURL();
    await sendMessage(chatUser, imageUrl, 'image');
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toid)}/messages/')
        .doc(message.send)
        .delete();
    if (message.type == 'image') {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(Message message, String msg) async {
    await firestore
        .collection('chats/${getConversationID(message.toid)}/messages/')
        .doc(message.send)
        .update({'msg': msg});
  }
}
