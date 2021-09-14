import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:zamazingo/components/GlobalScreenComponents/global_bubble.dart';
import 'package:zamazingo/components/GlobalScreenComponents/global_detail_page_appbar.dart';
import 'package:zamazingo/components/loading_bar.dart';
import 'package:zamazingo/models/GlobalScreenModels/global_message.dart';
import 'package:zamazingo/models/send_menu_items.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum MessageType {
  Sender,
  Receiver,
}

class GlobalPage extends StatefulWidget {
  @override
  GlobalPageState createState() => GlobalPageState();
}

class GlobalPageState extends State<GlobalPage> {
  bool loading = false;
  DatabaseReference db_refGlobal =
      FirebaseDatabase.instance.reference().child("Global");
  final messageFieldController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<GlobalMessage> globalMessage = [];
  var toAnimateList = true;

  List<SendMenuItems> menuItems = [
    SendMenuItems(text: "Gallery", icons: Icons.image, color: Colors.amber),
    SendMenuItems(
        text: "Documents", icons: Icons.insert_drive_file, color: Colors.blue),
    SendMenuItems(text: "Audio", icons: Icons.music_note, color: Colors.orange),
    SendMenuItems(
        text: "Location", icons: Icons.location_on, color: Colors.green),
    SendMenuItems(text: "Contact", icons: Icons.person, color: Colors.purple),
  ];
  var isInitialDataLoaded = false;
  String UserName, Email;
  dynamic userKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenChanges();
    RetreiveGlobalMessages();
    getUserData();
  }

  Future<void> getUserData() async {
    setState(() => loading = true);
    var user = await FirebaseAuth.instance.currentUser;
    setState(() {
      Email = user.email;
    });
    DatabaseReference ref = await FirebaseDatabase.instance.reference();
    ref.child('Users').once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var values = snap.value;
      for (var key in keys) {
        String str = values[key]["email"];
        if (str == Email) {
          userKey = key;
          print("name: " + values[key]["name"]);
          UserName = values[key]["name"];
          print("email: " + values[key]["email"]);
          Email = values[key]["email"];
          break;
        }
      }
      setState(() => loading = false);
    });
  }

  void listenChanges() {
    db_refGlobal.onValue.listen((event) {
      if (mounted)
        setState(() {
          isInitialDataLoaded = true;
        });
    });
  }

  void showModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            color: Color(0xff737373),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    Center(
                      child: Container(
                        height: 4,
                        width: 50,
                        color: Colors.grey.shade200,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                      itemCount: menuItems.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: menuItems[index].color.shade100),
                              height: 50,
                              width: 50,
                              child: Icon(
                                menuItems[index].icons,
                                size: 20,
                                color: menuItems[index].color.shade500,
                              ),
                            ),
                            title: Text(menuItems[index].text),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (globalMessage.isNotEmpty && toAnimateList) {
      // here we set the timer to call the event
      Timer(
          Duration(milliseconds: 250),
          () => scrollController
              .jumpTo(scrollController.position.maxScrollExtent));
    }

    return loading
        ? Loading()
        : Scaffold(
            appBar: GlobalDetailAppBar(),
            body: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.73,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: globalMessage.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    itemBuilder: (context, index) {
                      return GlobalBubble(
                        globalMessage: globalMessage[index],
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.only(left: 16, bottom: 0),
                    height: 50,
                    width: double.infinity,
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            showModal();
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            controller: messageFieldController,
                            decoration: InputDecoration(
                                hintText: "Write something...",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: EdgeInsets.only(right: 15, bottom: 15),
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          SendMessageInGlobalChat(
                              messageFieldController.text.toString());
                        });
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.red,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            )); //Scaffold
  }

  Future<void> SendMessageInGlobalChat(String message) async {
    var user = await FirebaseAuth.instance.currentUser;
    String UID = user.email;
    print(UserName);
    var timeStamp = new DateTime.now().millisecondsSinceEpoch;
    setState(() {
      /*    globalMessage.add(GlobalMessage(
          message: message, type: MessageType.Sender, dateTime: timeStamp));
*/
      toAnimateList = true;
      db_refGlobal.push().set({
        "sender_id": UID.toString(),
        "userName": UserName,
        "message": message,
        "timestamp": timeStamp
      });
      messageFieldController.text = "";
    });
  }

  void handleError() {
    setState(() => loading = false);
  }

  Future<void> RetreiveGlobalMessages() async {
    try {
      var user = await FirebaseAuth.instance.currentUser;
      String UID = user.email;
      globalMessage.clear();
      setState(() => loading = true);

      db_refGlobal.orderByChild('timestamp').onChildAdded.listen((event) {
        if (event.snapshot == null) {
          setState(() => loading = false);
        } else {
          var values = event.snapshot.value;
          String str = values["sender_id"];
          GlobalMessage info;
          var nameUser = values["userName"] != null ? values["userName"] : '';
          if (str == UID) {
            info = GlobalMessage(
                message: values["message"],
                type: MessageType.Sender,
                dateTime: values["timestamp"],
                name: nameUser);
          } else {
            info = GlobalMessage(
                message: values["message"],
                type: MessageType.Receiver,
                dateTime: values["timestamp"],
                name: nameUser);
          }
          globalMessage.add(info);

/*
          if(globalMessage.isNotEmpty){
            globalMessage.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          }
*/

          setState(() => loading = false);
          // toAnimateList = false;
        }
        // }
      }).onError(handleError);

/*     db_refGlobal.once().then((DataSnapshot snap) {
        if (snap == null) {
          setState(() => loading = false);
        } else {
          var keys = snap.value.keys;
          var values = snap.value;

          globalMessage.clear();
          for (var key in keys) {
            String str = values[key]["sender_id"];
          //  var date = DateTime.fromMillisecondsSinceEpoch(values[key]["timestamp"] * 1000);
            GlobalMessage info;

            if (str == UID) {
              info = GlobalMessage(
                  message: values[key]["message"], type: MessageType.Sender,dateTime: values[key]["timestamp"]);
            } else {
              info = GlobalMessage(
                message: values[key]["message"],
                type: MessageType.Receiver,dateTime: values[key]["timestamp"]
              );
            }
            globalMessage.add(info);
          }

          print('scroll: ' + globalMessage.length.toString());
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
          );

          setState(() => loading = false);
        }
      }).catchError((err) {
        setState(() => loading = false);
      });*/
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    messageFieldController.dispose();
    scrollController.dispose();
  }
}
