import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
            .get().then((value) async {
              if(value.exists){
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
        isOnline: true,
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
  static Future<void> updateInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      // 'image': me.image,
      'about': me.about,
    });
  }
  static Future<void> updateImage(XFile uri) async {
    await firestore.collection('user').doc(user.uid).update({
      'image': uri,
    });
  }
}
