import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:zamazingo/components/ChatScreenComponents/chat_bubble.dart';
import 'package:zamazingo/components/ChatScreenComponents/chat_detail_page_appbar.dart';
import 'package:flutter/material.dart';
import 'package:zamazingo/components/loading_bar.dart';
import 'package:zamazingo/models/ChatScreenModels/chat_message.dart';
import 'package:zamazingo/models/send_menu_items.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum MessageType {
  Sender,
  Receiver,
}

class ChatDetailPage extends StatefulWidget {
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  String UID = "";
  bool loading = false;
  DatabaseReference db_refPrivate =
      FirebaseDatabase.instance.reference().child("Private");
  final messageFieldController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  var toAnimateList = true;

  List<ChatMessage> chatMessage = [];

  List<SendMenuItems> menuItems = [
    SendMenuItems(text: "Gallery", icons: Icons.image, color: Colors.amber),
    SendMenuItems(
        text: "Documents", icons: Icons.insert_drive_file, color: Colors.blue),
    SendMenuItems(text: "Audio", icons: Icons.music_note, color: Colors.orange),
    SendMenuItems(
        text: "Location", icons: Icons.location_on, color: Colors.green),
    SendMenuItems(text: "Contact", icons: Icons.person, color: Colors.purple),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        UID = ModalRoute.of(context).settings.arguments;
        print("UID $UID");
      });
    });
    RetreiveChatMessages();
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
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //UID = ModalRoute.of(context).settings.arguments;
    //print(UID);
    if (chatMessage.isNotEmpty && toAnimateList) {
      // here we set the timer to call the event
      Timer(
          Duration(milliseconds: 250),
          () => scrollController
              .jumpTo(scrollController.position.maxScrollExtent));
    }

    return loading
        ? Loading()
        : Scaffold(
            appBar: ChatDetailAppBar(
              ID: UID,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.78,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: chatMessage.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    itemBuilder: (context, index) {
                      return ChatBubble(
                        chatMessage: chatMessage[index],
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.only(left: 16, bottom: 10),
                    height: 80,
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
                              size: 21,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 16,
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
                          SendMessageInPrivateChat(
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

  Future<void> SendMessageInPrivateChat(String message) async {
    var user = await FirebaseAuth.instance.currentUser;
    String SenderID = user.email;

    setState(() {
      // chatMessage.add(ChatMessage(message: message, type: MessageType.Sender));
      toAnimateList = true;
      db_refPrivate.push().set({
        "sender_id": SenderID.toString(),
        "receiver_id": UID.toString(),
        "message": message,
        "timestamp": new DateTime.now().millisecondsSinceEpoch
      });
      messageFieldController.text = "";
    });
  }

  Future<void> RetreiveChatMessages() async {
    try {
      var user = await FirebaseAuth.instance.currentUser;
      String SenderID = user.email;
      chatMessage.clear();
      setState(() => loading = true);
      DatabaseReference ref =
          await FirebaseDatabase.instance.reference().child("Private");
      ref.orderByChild('timestamp').onChildAdded.listen((event) {
        if (event.snapshot == null) {
          setState(() => loading = false);
        } else {
          var values = event.snapshot.value;
          String str = values["sender_id"];
          ChatMessage info;
          print('add');
          if (str == SenderID && values["receiver_id"] == UID) {
            info = ChatMessage(
                message: values["message"], type: MessageType.Sender);
            chatMessage.add(info);
          } else if (str == UID) {
            info = ChatMessage(
                message: values["message"], type: MessageType.Receiver);
            chatMessage.add(info);
          }
          setState(() => loading = false);
        }
      }).onError(handleError);
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void handleError() {
    setState(() => loading = false);
  }

  /*Future<void> RetreiveChatMessages() async {
    try {
      var user = await FirebaseAuth.instance.currentUser;
      String SenderID = user.email;

      setState(() => loading = true);
      DatabaseReference ref =
          await FirebaseDatabase.instance.reference().child("Private");
      ref.once().then((DataSnapshot snap) {
        if (snap == null) {
          setState(() => loading = false);
        } else {
          var keys = snap.value.keys;
          var values = snap.value;

          chatMessage.clear();
          for (var key in keys) {
            setState(() {
              String str = values[key]["sender_id"];
              ChatMessage info;

              if (str == SenderID && values[key]["receiver_id"] == UID) {
                info = ChatMessage(
                    message: values[key]["message"], type: MessageType.Sender);
                chatMessage.add(info);
              } else if (str == UID) {
                info = ChatMessage(
                    message: values[key]["message"],
                    type: MessageType.Receiver);
                chatMessage.add(info);
              }
            });
          }
          setState(() => loading = false);
        }
      }).catchError((err) {
        setState(() => loading = false);
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }*/

  @override
  void dispose() {
    super.dispose();
    messageFieldController.dispose();
    scrollController.dispose();
  }
}
