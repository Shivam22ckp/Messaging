import 'package:flutter/material.dart';
import 'package:zamazingo/models/GroupScreenModels/group_detail_page.dart';
class GroupUserList extends StatefulWidget{
  String text;
  String secondaryText;
  String image;
  String time;
  bool isMessageRead;

  GroupUserList({@required this.text, @required this.secondaryText, @required this.image, @required this.time, @required this.isMessageRead});
  @override
  _GroupUserListState createState() => _GroupUserListState();
}

class _GroupUserListState extends State<GroupUserList> {
  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return GroupDetailPage();
        }));
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top:10, bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.image),
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
                          Text(widget.secondaryText, style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(widget.time, style: TextStyle(fontSize: 12, color: widget.isMessageRead?Colors.redAccent:Colors.grey.shade500),),

          ],
        ),
      ),
    );
  }
}