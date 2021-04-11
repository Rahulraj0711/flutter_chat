import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/components/auth_methods.dart';
import 'package:flutter_chat/components/database_methods.dart';
import 'package:flutter_chat/components/helper_functions.dart';
import 'photo_screen.dart';
import 'package:flutter_chat/constants.dart';
import 'package:flutter_chat/screens/aboutme_screen.dart';
import 'package:flutter_chat/screens/search_screen.dart';
import 'package:flutter_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatRoom extends StatefulWidget {
  static const String id='chat_room';
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  final messageTextController=TextEditingController();
  String text;
  DatabaseMethods dbMethods=new DatabaseMethods();
  AuthMethods authMethods=new AuthMethods();
  Stream chatRoomsStream;
  bool isLoading=false;

  getUserInfo() async {
    Constants.myUid=await HelperFunctions.getUIdSharedPreference();
    Constants.myName=await HelperFunctions.getUserNameSharedPreference();
    Constants.myPhotoUrl=await HelperFunctions.getPhotoUrlSharedPreference();
    // Constants.myPhoneNo=await HelperFunctions.getPhoneNoSharedPreference();
    Constants.myEmail=await HelperFunctions.getUserEmailSharedPreference();
    await dbMethods.getChatRooms(Constants.myUid).then((val) {
      setState(() {
        chatRoomsStream=val;
      });
    });
    setState(() {
    });
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData ? ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            List names=snapshot.data.docs[index].get('userNames');
            List photoUrls=snapshot.data.docs[index].get('photos');
            return ChatRoomTile(
              userName: names[0]==Constants.myName ? names[1] : names[0],
              chatRoomId: snapshot.data.docs[index].get('chatRoomId'),
              imageUrl: photoUrls[0]==Constants.myPhotoUrl ? photoUrls[1] : photoUrls[0],
            );
          },
        ) : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  Future<bool> _onBackPressed(){
    return SystemNavigator.pop();
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title=='Sign Out') {
      this.setState(() {
        isLoading=true;
      });
      authMethods.googleSignOut();
      this.setState(() {
        isLoading=false;
      });
      Navigator.popAndPushNamed(context, WelcomeScreen.id);
    } else {
      Navigator.pushNamed(context, AboutMe.id);
    }
  }

  List<Choice> choices = const <Choice>[
    const Choice(title: 'About Me', icon: Icons.info_outline, color: Colors.green),
    const Choice(title: 'Sign Out', icon: Icons.exit_to_app, color: Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              SystemNavigator.pop();
            }
        ),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Row(
                    children: [
                      Icon(
                        choice.icon,
                        color: choice.color,
                      ),
                      SizedBox(width: 10.0,),
                      Text(
                        choice.title,
                        style: TextStyle(color: Color(0xff203152)),
                      ),
                    ],
                  )
                );
              }).toList();
            },
          )
        ],
        title: Text('⚡️Chat'),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.search,
          size: 30,
          color: Colors.red,
        ),
        splashColor: Colors.yellow,
        elevation: 10,
        backgroundColor: Colors.tealAccent,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => SearchScreen())
          );
        },
      ),
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: Stack(
          children:<Widget> [
            chatRoomList(),
            Positioned(
              child: isLoading ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
                color: Color.fromRGBO(89, 178, 85, 1),
              ): Container(),
            )
          ]
        ),
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  ChatRoomTile({this.userName, this.chatRoomId, this.imageUrl});
  final String userName;
  final String chatRoomId;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ChatScreen(chatRoomId,userName,imageUrl)
        ));
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              // width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 225, 98, 0.5),
                borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoScreen(photoUrl: imageUrl)));
                    },
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )
                          ),
                        );
                      },
                      placeholder: (context,url)=>CircularProgressIndicator(),
                      errorWidget: (context,url,error) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    userName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 20
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 2)
        ],
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon, this.color});

  final String title;
  final IconData icon;
  final Color color;
}