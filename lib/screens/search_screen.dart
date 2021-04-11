import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_chat/components/database_methods.dart';
import 'package:flutter_chat/components/helper_functions.dart';
import 'package:flutter_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchScreen extends StatefulWidget {
  static const String id='search_screen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  DatabaseMethods dbMethods=new DatabaseMethods();
  TextEditingController searchController=new TextEditingController();
  QuerySnapshot searchSnapshot;

  startSearch() {
    if(searchController.text.isNotEmpty) {
      dbMethods.getUsers(searchController.text).then((val) {
        setState(() {
          searchSnapshot=val;
        });
      });
    }
  }

  Widget searchList() {
    return searchSnapshot!=null ? ListView.builder(
        shrinkWrap: true,
        itemCount: searchSnapshot.docs.length,
        itemBuilder: (context,index) {
          return searchSnapshot.docs[index].get('uid')!=Constants.myUid ? searchTile(
            userName: searchSnapshot.docs[index].get('userName'),
            userEmail: searchSnapshot.docs[index].get('email'),
            userUid: searchSnapshot.docs[index].get('uid'),
            photoUrl: searchSnapshot.docs[index].get('photoUrl'),
          ) : Container();
        }) : Container();
  }

  Widget searchTile({String userName, String userEmail, String userUid, String photoUrl}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.teal)
        )
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: photoUrl,
            imageBuilder: (context, imageProvider) {
              return Container(
                height: 50,
                width: 50,
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
          SizedBox(width: 20,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await createChatRoom(userName, userUid, photoUrl);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25.0)
              ),
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              child: Text(
                "Add",
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  createChatRoom(String userName, String userUid, String photoUrl) async {
    String chatRoomId=getChatRoomId(userUid, Constants.myUid);
    List<String> userIds=[userUid, Constants.myUid];
    List<String> users=[userName, Constants.myName];
    List<String> photos=[photoUrl, Constants.myPhotoUrl];
    Map<String, dynamic> chatRoomMap= {
      'chatRoomId': chatRoomId,
      'userIds': userIds,
      'userNames': users,
      'photos': photos,
    };
    dbMethods.createChatRoom(chatRoomId, chatRoomMap).then((data) async {
      Fluttertoast.showToast(msg: 'User Successfully Added!');
    }).catchError((error) {
      Fluttertoast.showToast(msg: error.toString());
    });
  }

  getUserInfo() async {
    Constants.myName=await HelperFunctions.getUserNameSharedPreference();
    Constants.myUid=await HelperFunctions.getUIdSharedPreference();
    setState(() {
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text('⚡️Search'),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                color: Colors.blueGrey,
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        controller: searchController,
                        decoration: InputDecoration(
                            hintText:'Search your friend here',
                            hintStyle: TextStyle(
                              color: Colors.white
                            ),
                            border: InputBorder.none
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if(searchController.text.isNotEmpty) {
                          startSearch();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(25.0)
                        ),
                        child: Icon(
                            Icons.search,
                            color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              searchList(),
            ],
          ),
        ),
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if(a.hashCode<=b.hashCode) {
    return "$a\_$b";
  }
  else {
    return "$b\_$a";
  }
}
