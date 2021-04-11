import 'package:flutter/material.dart';

class UserinfoContainer extends StatefulWidget {
  UserinfoContainer({this.icon, this.labelText, this.data});
  final IconData icon;
  final String labelText;
  final String data;

  @override
  _UserinfoContainerState createState() => _UserinfoContainerState();
}

class _UserinfoContainerState extends State<UserinfoContainer> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(widget.icon),
          SizedBox(width: 10,),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.red)
                  )
              ),
              padding: EdgeInsets.symmetric(horizontal: 15,vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.labelText,
                    style: TextStyle(
                        fontSize: 14
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    widget.data,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}