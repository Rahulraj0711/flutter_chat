import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/components/database_methods.dart';
import 'package:flutter_chat/components/helper_functions.dart';
import 'photo_screen.dart';
import 'package:flutter_chat/components/userinfo_container.dart';
import 'package:flutter_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AboutMe extends StatelessWidget {
  static const String id='aboutme_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(89, 178, 85, 1),
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      body: DetailsScreen(),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {

  TextEditingController controllerUserName;
  File displayImage;
  bool isLoading=false;
  final FocusNode focusNodeUserName=FocusNode();
  DatabaseMethods dbMethods=DatabaseMethods();
  String uid='';
  String name='';
  String photoUrl='';
  String email='';

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    uid=await HelperFunctions.getUIdSharedPreference() ?? '';
    name=await HelperFunctions.getUserNameSharedPreference() ?? '';
    photoUrl=await HelperFunctions.getPhotoUrlSharedPreference() ?? '';
    email=await HelperFunctions.getUserEmailSharedPreference() ?? '';

    controllerUserName=TextEditingController(text: name);

    setState(() {});
  }

  getChatRoomId(String a, String b) {
    if(a.hashCode<=b.hashCode) {
      return "$a\_$b";
    }
    else {
      return "$b\_$a";
    }
  }

  createChatRoom() async {
    String userName, userUid, photo;
    QuerySnapshot chatRooms;
    await dbMethods.getChatRoomsForUpdate(Constants.myUid).then((val) {
      chatRooms=val;
    });
    Iterator<QueryDocumentSnapshot> itr=chatRooms.docs.iterator;
    while(itr.moveNext()) {
      List names=itr.current.get('userNames');
      List ids=itr.current.get('userIds'); 
      List urls=itr.current.get('photos');
      userName= names[0]==Constants.myName ? names[1] : names[0];
      userUid= ids[0]==Constants.myUid ? ids[1] : ids[0];
      photo= urls[0]==Constants.myPhotoUrl ? urls[1]: urls[0];
      String chatRoomId=getChatRoomId(userUid, uid);
      List<String> userIds=[userUid, uid];
      List<String> users=[userName, name];
      List<String> photos=[photo, photoUrl];
      Map<String, dynamic> chatRoomMap= {
        'chatRoomId': chatRoomId,
        'userIds': userIds,
        'userNames': users,
        'photos': photos,
      };
      await dbMethods.createChatRoom(chatRoomId, chatRoomMap);
    }
  }

  getImage() async {
    final picker=ImagePicker();
    var pickedFile=await picker.getImage(source: ImageSource.gallery);
    File image=File(pickedFile.path);

    if(image!=null) {
      setState(() {
        displayImage=image;
        isLoading=true;
      });
    }
    uploadFile();
  }

  uploadFile() async {
    String fileName=uid;
    Reference reference=FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask=reference.putFile(displayImage);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value) {
      if(value==null) {
        storageTaskSnapshot=value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl=downloadUrl;
          dbMethods.updateUserDetails(uid, name, photoUrl).then((data) async {
            await HelperFunctions.setPhotoUrlSharedPreference(photoUrl);
            setState(() {
              isLoading=false;
            });
            Fluttertoast.showToast(msg: 'Upload Success');
          }).catchError((error) {
            setState(() {
              isLoading=false;
            });
            Fluttertoast.showToast(msg: error.toString());
          });
        }, onError: (error) {
          setState(() {
            isLoading=false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      }
      else {
        setState(() {
          isLoading=false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError:(error) {
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: error.toString());
    });
  }

  void handleUpdateData() {
    focusNodeUserName.unfocus();

    setState(() {
      isLoading=true;
    });

    dbMethods.updateUserDetails(uid, name, photoUrl).then((data) async {
      await HelperFunctions.setUserNameSharedPreference(name);
      await HelperFunctions.setPhotoUrlSharedPreference(photoUrl);
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: 'Update Success');
    }).catchError((error) {
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                (displayImage==null) ?
                (photoUrl!='' ?
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoScreen(photoUrl: photoUrl)));
                  },
                  child: Container(
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      filterQuality: FilterQuality.high,
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          height: 150,
                          width: 150,
                          child: GestureDetector(
                            onTap: () async {
                              getImage();
                            },
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey,
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80),
                              border: Border(
                                  top: BorderSide(width: 2.0,color: Colors.yellow),
                                  bottom: BorderSide(width: 2.0,color: Colors.yellow),
                                  left: BorderSide(width: 2.0,color: Colors.yellow),
                                  right: BorderSide(width: 2.0,color: Colors.yellow)
                              ),
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
                ) :
                Container(
                  height: 150,
                  width: 150,
                  child: Icon(
                    Icons.account_circle,
                    color: Colors.grey,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80)
                  ),
                )) :
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoScreen(image: displayImage)));
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    child: GestureDetector(
                      onTap: () async {
                        getImage();
                        createChatRoom();
                      },
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                        border: Border(
                            top: BorderSide(width: 2.0,color: Colors.yellow),
                            bottom: BorderSide(width: 2.0,color: Colors.yellow),
                            left: BorderSide(width: 2.0,color: Colors.yellow),
                            right: BorderSide(width: 2.0,color: Colors.yellow)
                        ),
                      image: DecorationImage(
                        image: FileImage(displayImage),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  color: Colors.black12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.red)
                              )
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name',
                                style: TextStyle(
                                    fontSize: 14
                                ),
                              ),
                              SizedBox(height: 8,),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter new name',
                                  enabledBorder: InputBorder.none,
                                  border: InputBorder.none,
                                ),
                                controller: controllerUserName,
                                onChanged: (value) {
                                  name=value;
                                },
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20
                                ),
                                focusNode: focusNodeUserName,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                UserinfoContainer(
                  icon: Icons.email,
                  labelText: 'Email',
                  data: email,
                ),
                SizedBox(height: 20,),
                Material(
                  elevation: 10,
                  child: GestureDetector(
                    onTap: () async {
                      handleUpdateData();
                      createChatRoom();
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Text('Update'),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
        ),
        Positioned(
          child: isLoading ?
          Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
            color: Colors.white.withOpacity(0.8),
          ) :
          Container(),
        ),
      ],
    );
  }
}

