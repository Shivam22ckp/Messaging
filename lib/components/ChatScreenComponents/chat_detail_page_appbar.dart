import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zamazingo/models/user_model.dart';

class ChatDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  String ID;

  ChatDetailAppBar({Key key, @required this.ID}) : super(key: key);
  static String UserName, Image_URL;

  @override
  Widget build(BuildContext context) {
  //  print("ID" + ID);
    GetAppBarInfo(ID);
   // print(UserName);
    //UID = ModalRoute.of(context).settings.arguments;
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              CircleAvatar(
                backgroundImage: Image_URL!=null?Image_URL.isNotEmpty?NetworkImage(Image_URL):AssetImage("images/1.jpg"):AssetImage("images/1.jpg"),
                maxRadius: 20,
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      UserName!=null?UserName:'',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "Unknown",
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.more_vert,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> GetAppBarInfo(String id) async {
    DatabaseReference refer = await FirebaseDatabase.instance.reference();
    refer.child('Users').orderByValue().once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var values = snap.value;

     // print('values: $values');
      for (var key in keys) {
        String email_str = values[key]["email"];
        if (email_str == id) {
        //  print(email_str);
          UserName = values[key]["name"];
          Image_URL = values[key]["profile_picture"];
        // print(UserName);
        }
      }
    });
  }






  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
