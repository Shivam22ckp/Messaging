import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:zamazingo/components/GroupScreenComponents/group.dart';
import 'package:zamazingo/models/GroupScreenModels/group_users.dart';

/*class ChatsPage extends StatefulWidget{
  @override
  _ChatsPageState createState() => _ChatsPageState();
}
class _ChatsPageState extends State<ChatsPage> {
 */

class GroupPage extends StatefulWidget {
  @override
  GroupPageState createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  List<GroupUsers> groUsers = [
    GroupUsers(
        text: "Welcome to ZM",
        secondaryText: "Rules, informations and more!",
        image: "images/zm_group.png",
        time: "Now"),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Groups",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 2),
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.pink[50],
                        ),
                        child: Row(
                          children: <Widget>[
                            FlatButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/Contacts');
                              },
                              icon: Icon(Icons.add),
                              label: Text('New'),
                            ),

                            //  FlatButton.Icons(onPressed: , icon.add, label: null)
                            //(Icons.add, color: Colors.red, size: 20),
                            // child: IconButton(

                            //icon: Icon(Icons.add),

                            //onPressed: () {

                            // });
                            //SizedBox(
                            //width: 2,
                            // ),
                            //Text(
                            //"New",
                            //style: TextStyle(
                            //  fontSize: 14, fontWeight: FontWeight.bold),
                            //)
                          ],
                        ))
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                  decoration: InputDecoration(
                hintText: "Do you want to search?",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.redAccent.shade400,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.all(8),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.redAccent)),
                focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.redAccent)),
              )),
            ),
            ListView.builder(
              itemCount: groUsers.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GroupUserList(
                  text: groUsers[index].text,
                  secondaryText: groUsers[index].secondaryText,
                  image: groUsers[index].image,
                  time: groUsers[index].time,
                  isMessageRead: (index == 0 || index == 3) ? true : false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
