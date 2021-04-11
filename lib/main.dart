import 'package:flutter_chat/components/auth_methods.dart';
import 'package:flutter_chat/screens/aboutme_screen.dart';
import 'package:flutter_chat/screens/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/welcome_screen.dart';
import 'package:flutter_chat/screens/chat_room.dart';

AuthMethods authMethods=new AuthMethods();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User user=await authMethods.isCurrentUser();
  Widget _defaultHomeScreen() {
    return  user!=null ? ChatRoom() : WelcomeScreen();
  }

  runApp(
       MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChatApp',
        home: _defaultHomeScreen(),
        routes: {
          WelcomeScreen.id: (context) => WelcomeScreen(),
          ChatRoom.id: (context) => ChatRoom(),
          SearchScreen.id: (context) => SearchScreen(),
          AboutMe.id: (context) => AboutMe(),
        },
      )
  );
}


