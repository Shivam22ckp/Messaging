import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zamazingo/models/ChatScreenModels/chat_detail_page.dart';
import 'package:zamazingo/models/ChatScreenModels/chat_message.dart';

class ChatBubble extends StatefulWidget
{
  ChatMessage chatMessage;
  ChatBubble({@required this.chatMessage});

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
{
  @override
  Widget build(BuildContext context){

    return Container(
      padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
      child: Align(
        alignment: (widget.chatMessage!=null?widget.chatMessage.type == MessageType.Receiver?Alignment.topLeft: Alignment.topRight:Alignment.topLeft),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
              color: (widget.chatMessage!=null?widget.chatMessage.type == MessageType.Receiver?Colors.redAccent[100]:Colors.black12:Colors.transparent),
          ),
          padding: EdgeInsets.all(16),

          child: Text(widget.chatMessage!=null?widget.chatMessage.message:''),
        )
      )
    );
  }
}