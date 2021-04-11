import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/components/database_methods.dart';
import 'photo_screen.dart';
import 'package:flutter_chat/screens/chat_room.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/screens/videoplayer_screen.dart';
import 'package:video_player/video_player.dart';
import '../constants.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final String photoUrl;
  ChatScreen(this.chatRoomId, this.userName, this.photoUrl);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

Stream chatMessagesStream;

class _ChatScreenState extends State<ChatScreen> {

  DatabaseMethods dbMethods=new DatabaseMethods();
  TextEditingController messageTextController=TextEditingController();
  File image;
  Image thumbnail;
  String imageUrl;
  List<File> imageFiles;
  String videoUrl;
  List<File> videoFiles;
  bool isLoading;
  FocusNode myFocus;

  sendMessages(String content,int type) {
    if(content.isNotEmpty) {
      var now=DateTime.now().toLocal();
      var formatter=DateFormat('dd-MMM-yyy hh:mm a');
      String timeStamp=formatter.format(now);
      Map<String,dynamic> chatMap= {
        'content': content,
        'sender': Constants.myUid,
        'receiver': widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
        'timeStamp': timeStamp,
        'type': type
      };
      dbMethods.addConversationMessages(widget.chatRoomId, chatMap);
      messageTextController.clear();
    }
  }

  getVideoFiles() async {
    FilePickerResult result=await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true);
    if(result!=null) {
      videoFiles=result.paths.map((path) => File(path)).toList();
      setState(() {
        isLoading=true;
      });
      uploadVideoFile();
    }
  }

  uploadVideoFile() async {
    for(var file in  videoFiles){
      String fileName=DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference=FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask=reference.putFile(file);
      TaskSnapshot snapshot=await uploadTask;
      snapshot.ref.getDownloadURL().then((downloadUrl) {
        videoUrl=downloadUrl;
        setState(() {
          isLoading=false;
          sendMessages(videoUrl,2);
        });
      }, onError: (err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not video');
      });
    }
  }

  getImageFiles() async {
    FilePickerResult result=await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
    if(result!=null) {
      imageFiles=result.paths.map((path) => File(path)).toList();
      setState(() {
        isLoading=true;
      });
      uploadImageFile();
    }
  }

  getImage() async {
    ImagePicker picker=ImagePicker();
    var pickedImage=await picker.getImage(source: ImageSource.gallery);
    image=File(pickedImage.path);
    if(image!=null) {
      setState(() {
        isLoading=true;
      });
      uploadImageFile();
    }
  }

  uploadImageFile() async {
    for(var file in imageFiles) {
      String fileName=DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference=FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask=reference.putFile(file);
      TaskSnapshot snapshot=await uploadTask;
      snapshot.ref.getDownloadURL().then((downloadUrl) {
        imageUrl=downloadUrl;
        setState(() {
          isLoading=false;
          sendMessages(imageUrl,1);
        });
      }, onError: (err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      });
    }
  }


  @override
  void initState() {
    dbMethods.getConversationMessages(widget.chatRoomId).then((val) {
      setState(() {
        chatMessagesStream=val;
      });
    });
    isLoading=false;
    imageUrl='';
    myFocus=FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, ChatRoom.id);
            }
        ),
        title: Container(
          child: Row(
            children: [
              Container(
                height: 35,
                width: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    image: DecorationImage(
                      image: NetworkImage(widget.photoUrl),
                      fit: BoxFit.cover,
                    )
                ),
              ),
              SizedBox(width: 10,),
              Text(widget.userName),
            ],
          ),
        ),
        backgroundColor: Colors.black54,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height-90,
                  child: Column(
                    children: [
                      MessagesStream(),
                      Container(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          color: themeColor,
                          child: Row(
                            children: <Widget>[
                              // Button send image
                              GestureDetector(
                                onTap: getImageFiles,
                                child: Container(
                                  child: Icon(
                                    Icons.image,
                                  )
                                ),
                              ),
                              SizedBox(width: 2,),
                              // Edit text
                              Expanded(
                                child: Container(
                                  child: TextField(
                                    textInputAction: TextInputAction.newline,
                                    enableSuggestions: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintText: 'Type your message here...',
                                      border: InputBorder.none,
                                    ),
                                    controller: messageTextController,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor
                                    ),
                                    focusNode: myFocus,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: getVideoFiles,
                                child: Container(
                                    child: Icon(
                                      Icons.attach_file,
                                    ),
                                ),
                              ),
                              SizedBox(width: 8,),
                              // Button send message
                              GestureDetector(
                                onTap: () {
                                  sendMessages(messageTextController.text, 0);
                                },
                                child: Container(
                                    child: Icon(Icons.send,
                                      size: 25,
                                    )
                                ),
                              ),
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
      )
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: chatMessagesStream,
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages=snapshot.data.docs.reversed;
        List<MessageBubble> messageBubbles=[];
        for(var message in messages) {
          final messageText=message.get('content');
          final messageSender=message.get('sender');
          final timeStamp=message.get('timeStamp');
          final type=message.get('type');
          final messageBubble=MessageBubble(
            messageText,
            type,
            messageSender==Constants.myUid,
            timeStamp
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: Scrollbar(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              children: messageBubbles,
            ),
          ),
        );
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble(this.text, this.type, this.isMe, this.timeStamp);
  final String text;
  final int type;
  final bool isMe;
  final String timeStamp;

  @override
  Widget build(BuildContext context) {
    if(type==0) {
      return GestureDetector(
        onLongPress: () {
          FlutterClipboard.copy(text).then((value) {
            Fluttertoast.showToast(msg: 'Copied to Clipboard!');
          });
        },
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Material(
                borderRadius: isMe
                    ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                    : BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                elevation: 4.0,
                color: isMe ? Colors.lightBlueAccent : Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.0,),
              Text(
                timeStamp,
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                ),
              ),
              SizedBox(height: 8,)
            ],
          ),
        ),
      );
    }
    else if(type==1) {
      return Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoScreen(photoUrl: text)));
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black,width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                clipBehavior: Clip.hardEdge,
                child: CachedNetworkImage(
                  imageUrl: text,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      padding: EdgeInsets.all(70.0),
                      decoration: BoxDecoration(
                        color: greyColor2,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    );
                  },
                  errorWidget: (context,url,error) => Icon(Icons.error),
                ),
              ),
            ),
          ),
          SizedBox(height: 2,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              timeStamp,
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w300,
                  fontSize: 12
              ),
            ),
          ),
          SizedBox(height: 8,)
        ],
      );
    }
    else {
      return Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Video(text),
          SizedBox(height: 2,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              timeStamp,
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w300,
                  fontSize: 12
              ),
            ),
          ),
          SizedBox(height: 8,)
        ],
      );
    }
  }
}

class Video extends StatefulWidget {
  Video(this.url);
  final String url;

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller=VideoPlayerController.network(widget.url)..initialize().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized ?
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            child: VideoPlayer(_controller),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(widget.url)));
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.withOpacity(0.5),
              ),
              child: Icon(Icons.play_arrow),
            ),
          )
        ],
      ) :
      Center(
        child: CircularProgressIndicator(),
      );
  }
}
