import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  
  getChatRoomId(String chatRoomId) async {
    return await FirebaseFirestore.instance.collection('ChatRoom').where('chatRoomId',isEqualTo: chatRoomId).get();
  }
  
  getUserNameByUid(String uid) async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  getUsers(String name) async {
    return await FirebaseFirestore.instance.collection('users').where('userName', isGreaterThanOrEqualTo: name).get();
  }

  getUid(String uid) async {
    return await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: uid).get();
  }

  getUserIdByEmail(String userEmail) async {
    return await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userEmail).get();
  }

  uploadUserInfo(userMap) {
    FirebaseFirestore.instance.collection('users').add(userMap);
  }

  uploadUserInfoFromGoogle(User user) {
    FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'userName': user.displayName,
      'email': user.email,
      'photoUrl': user.photoURL,
      'uid': user.uid,
      'time': DateTime.now().toLocal()
    });
  }

  createChatRoom(String chatRoomId, chatRoomMap) async{
    return await FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoomId).set(chatRoomMap);
  }

  addConversationMessages(String chatRoomId, chatMap) {
    FirebaseFirestore.instance.collection('messages').doc(chatRoomId).collection('chats').add(chatMap);
  }
  
  getConversationMessages(String chatRoomId) async {
    return FirebaseFirestore.instance.collection('messages').doc(chatRoomId).collection('chats').orderBy('time', descending: false).snapshots();
  }

  getChatRooms(String uid) async {
    return FirebaseFirestore.instance.collection('ChatRoom').where('userIds', arrayContains: uid).snapshots();
  }

  getImageUrl(String uid) async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  updateUserDetails(String uid, String name, String photoUrl) async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'userName': name,
      'photoUrl': photoUrl,
    });
  }

  getChatRoomsForUpdate(String uid) async {
    return await FirebaseFirestore.instance.collection('ChatRoom').where('userIds', arrayContains: uid).get();
  }

}