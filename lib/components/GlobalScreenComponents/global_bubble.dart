import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zamazingo/Screens/globalchat.dart';
import 'package:zamazingo/models/GlobalScreenModels/global_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class GlobalBubble extends StatefulWidget {
  GlobalMessage globalMessage;

  GlobalBubble({@required this.globalMessage});

  @override
  _GlobalBubbleState createState() => _GlobalBubbleState();
}

class _GlobalBubbleState extends State<GlobalBubble> {
  String UserName = "";

  @override
  void initState() {
    super.initState();
    print('getNames');
  // getUserData();
  }

/*  Future<void> getUserData() async {
    var user = await FirebaseAuth.instance.currentUser;

    if(mounted)
    setState(() {
      UserName = user.displayName;
    });

    DatabaseReference ref = await FirebaseDatabase.instance.reference();
    ref.child('Users').once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var values = snap.value;

      for (var key in keys) {
        {
          if (mounted)
            setState(() {
              UserName = values[key]["name"];
              print("Name11: $UserName");
            });
        }
      }
    });
  }*/

  Widget build(BuildContext context) {
   // print("Name22: $UserName");
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Align(
        alignment: (widget.globalMessage.type == MessageType.Receiver
            ? Alignment.topLeft
            : Alignment.topRight),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 1, bottom: 1),
              alignment: (widget.globalMessage.type == MessageType.Receiver
                  ? Alignment.topLeft
                  : Alignment.topRight),
              child: new Text(widget.globalMessage.name,
                  style: new TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Roboto',
                    color: new Color(0xFFB71C1C),
                  )),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 15),
              alignment: (widget.globalMessage.type == MessageType.Receiver
                  ? Alignment.topLeft
                  : Alignment.topRight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: (widget.globalMessage.type == MessageType.Receiver
                    ? Colors.redAccent[100]
                    : Colors.black12),
              ),
              child: Text(widget.globalMessage.message),
            ),
          ],
        ),
      ),
    );
  }
}
