import 'package:flutter/material.dart';
import 'package:zamazingo/models/ChatScreenModels/chat_detail_page.dart';
class ChatUserList extends StatefulWidget
{
  String text;
  String email;
  String secondaryText;
  String image;
  String time;
  bool isMessageRead;

  ChatUserList({@required this.text, @required this.email, @required this.secondaryText, @required this.image, @required this.time, @required this.isMessageRead, });
  @override
  _ChatUserListState createState() => _ChatUserListState();
}

class _ChatUserListState extends State<ChatUserList> {
  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: ()
      {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailPage(),
              settings: RouteSettings(
                  arguments: widget.email
              ),
            )
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top:10, bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.redAccent, //here
                  backgroundImage: NetworkImage(widget.image),
                  maxRadius: 30,
                ),
               SizedBox(width: 16,),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.text),
                          SizedBox(height: 6,),
                          Visibility(
                            child: Text(widget.email, style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                            visible: false,
                          ),
                          Text(widget.secondaryText, style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(widget.time, style: TextStyle(fontSize: 12, color: widget.isMessageRead?Colors.redAccent:Colors.black),),

          ],
        ),
      ),
    );
  }
}