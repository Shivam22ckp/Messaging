import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zamazingo/models/GroupScreenModels/group_detail_page.dart';
import 'package:zamazingo/models/GroupScreenModels/group_message.dart';


class GroupBubble extends StatefulWidget{
  GroupMessage groupMessage;
  GroupBubble({@required this.groupMessage});

  @override
  _GroupBubbleState createState() => _GroupBubbleState();
}

class _GroupBubbleState extends State<GroupBubble> {
  @override
  Widget build(BuildContext context){
    return Container(
        padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
        child: Align(
            alignment: (widget.groupMessage.type == MessageType.Receiver?Alignment.topLeft: Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: (widget.groupMessage.type == MessageType.Receiver?Colors.redAccent[100]:Colors.black12),
              ),
              padding: EdgeInsets.all(16),

              child: Text(widget.groupMessage.message),
            )
        )
    );
  }
}