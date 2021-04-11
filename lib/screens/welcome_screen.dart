import 'package:flutter_chat/components/auth_methods.dart';
import 'package:flutter_chat/components/database_methods.dart';
import 'package:flutter_chat/components/helper_functions.dart';
import 'package:flutter_chat/screens/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{

  AnimationController ac;
  Animation ani;
  User _user;
  AuthMethods authMethods=new AuthMethods();
  DatabaseMethods dbMethods=new DatabaseMethods();
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
    ac=AnimationController(
      duration: Duration(seconds: 1),
      vsync: this
    );
    ani=ColorTween(begin: Colors.white, end: Colors.grey).animate(ac);
    ac.forward();
    ac.addListener(() {
      setState(() {
      });
    });
  }

  googleSignIn() async {
    _user=await authMethods.signInWithGoogle();
    if(_user!=null) {
      QuerySnapshot users=await dbMethods.getUid(_user.uid);
      if(users.docs.isEmpty) {
        await HelperFunctions.setUserLoggedInSharedPreference(true);
        await HelperFunctions.setUserNameSharedPreference(_user.displayName);
        await HelperFunctions.setUserEmailSharedPreference(_user.email);
        await HelperFunctions.setUIdSharedPreference(_user.uid);
        await HelperFunctions.setPhotoUrlSharedPreference(_user.photoURL);
        // await HelperFunctions.setPhoneNoSharedPreference(_user.phoneNumber);
        await dbMethods.uploadUserInfoFromGoogle(_user);
        Navigator.pushNamed(context, ChatRoom.id);
      }
      else {
        Navigator.pushNamed(context, ChatRoom.id);
      }
    }
  }

  Future<bool> _onBackPressed(){
    return SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: ani.value,
        body: SingleChildScrollView(
          child: Container(
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage('images/pic4.jpg'),
            //     fit: BoxFit.cover,
            //   )
            // ),
            height: MediaQuery.of(context).size.height,
            child: ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                          tag: 'logo',
                          child: Container(
                            child: Image.asset('images/chat1.png'),
                            height: 60.0,
                          ),
                        ),
                        SizedBox(width: 15,),
                        ColorizeAnimatedTextKit(
                          text: ['Chat'],
                          textStyle: TextStyle(
                            fontSize: 60.0,
                            fontWeight: FontWeight.w900,
                          ),
                          colors: [
                            Colors.white,
                            Colors.purple,
                            Colors.indigo,
                            Colors.blue,
                            Colors.green,
                            Colors.yellow,
                            Colors.orange,
                            Colors.red,
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 60.0,
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue,
                      child: MaterialButton(
                        onPressed: () async {
                          setState(() {
                            isLoading=true;
                          });
                          await googleSignIn();
                        },
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)
                              ),
                              padding: EdgeInsets.all(10),
                              height: 40,
                              width: 40,
                              child: Image(
                                image: AssetImage('images/google.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 40,),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}