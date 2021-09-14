import 'package:flutter/material.dart';
import 'package:zamazingo/Screens/chatscreen.dart';
import 'package:zamazingo/Screens/database.dart';
import 'package:zamazingo/Screens/shared_pref.dart';
import 'package:zamazingo/models/ChatScreenModels/chat_detail_page.dart';

class ContactList extends StatefulWidget {
  String name;
  String phone;
  String image;
  String email;

  ContactList(
      {@required this.name,
      @required this.phone,
      @required this.image,
      @required this.email});
  @override
  _ContactListPage createState() => _ContactListPage();
}

class _ContactListPage extends State<ContactList> {
  String myUserName;

  getMyInfoFromSharedPreference() async {
    myUserName = await SharedPreferenceHelper().getUserName();

    setState(() {});
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreference();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName, widget.name);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, widget.name]
        };
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(widget.name, myUserName)));
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
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
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.name),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.phone,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500),
                          ),
                          Visibility(
                            child: Text(
                              widget.email,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade500),
                            ),
                            visible: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
