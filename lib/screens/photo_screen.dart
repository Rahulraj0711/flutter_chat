import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PhotoScreen extends StatelessWidget {
  final String photoUrl;
  final File image;
  PhotoScreen({this.photoUrl, this.image});

  downloadFile() async {
    Dio dio=Dio();
    var directory=await getExternalStorageDirectory();
    await dio.download(photoUrl, "${directory.path}/images.jpg", onReceiveProgress: (rec,total){
      print('$rec , $total');
    }).whenComplete(() {
      Fluttertoast.showToast(msg: 'Download Successful!');
    }).catchError((error) {
      Fluttertoast.showToast(msg: error.toString());
    }) ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        backgroundColor: Colors.black54,
        actions: [
          IconButton(
            icon: Icon(Icons.download_sharp),
            onPressed: downloadFile,
          )
        ],
      ),
      body: photoUrl!=null ?
        Container(
          child: PhotoView(
            imageProvider: NetworkImage(photoUrl),
            filterQuality: FilterQuality.high,
          ),
        ) :
        Container(
          child: PhotoView(
            imageProvider: FileImage(image),
            filterQuality: FilterQuality.high,
          ),
        ),
    );
  }
}