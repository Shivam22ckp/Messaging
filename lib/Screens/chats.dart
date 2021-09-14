import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zamazingo/Screens/chatscreen.dart';
import 'package:zamazingo/Screens/contacts.dart';
import 'package:zamazingo/Screens/database.dart';
import 'package:zamazingo/Screens/shared_pref.dart';
import 'package:zamazingo/components/ChatScreenComponents/chat.dart';
import 'package:zamazingo/components/loading_bar.dart';
import 'package:zamazingo/models/ChatScreenModels/chat_users.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zamazingo/models/ContactModel/MyContacts.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  bool loading = false;
  List<String> ids = new List<String>();
  List<ChatUsers> chaUsers = [];
  List<Contacts> contactlist = [];
  List<Contact> contacts = [];
  List<String> phones = [];
  String myName, myProfilePic, myUserName, myEmail;
  Stream chatRoomsStream;

  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
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
                              "Chats",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
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
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MyContactsPage()),
                                            ModalRoute.withName("/Contacts"));
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text('New'),
                                    ),

                                    //Icon(Icons.add,color: Colors.red, size: 20),
                                    //SizedBox(width: 2,),
                                    //Text ("New", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
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
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                            focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                          ),
                        )),
                    /*chaUsers.isEmpty ? Center(child: Text('No Chats to show')) :*/
                    // ListView.builder(
                    //   itemCount: chaUsers.length,
                    //   shrinkWrap: true,
                    //   padding: EdgeInsets.only(top: 16),
                    //   physics: NeverScrollableScrollPhysics(),
                    //   itemBuilder: (context, index) {
                    //     return ChatUserList(
                    //       text: chaUsers[index].text,
                    //       email: chaUsers[index].email,
                    //       secondaryText: chaUsers[index].secondaryText,
                    //       image: chaUsers[index].image,
                    //       time: chaUsers[index].time,
                    //       isMessageRead:
                    //           (index == 0 || index == 3) ? true : false,
                    //     );
                    //   },
                    // ),
                    chatRoomsList(),
                  ],
                ),
              ),
            ),
          );
  }

  Future<void> FindUniqueChats() async {
    try {
      var user = await FirebaseAuth.instance.currentUser;
      String UID = user.email;

      setState(() => loading = true);
      DatabaseReference ref_ =
          await FirebaseDatabase.instance.reference().child("Private");
      ref_.once().then((DataSnapshot snap) {
        if (snap == null) {
          setState(() => loading = false);
        } else {
          var keys = snap.value.keys;
          var values = snap.value;

          for (var key in keys) {
            String str = values[key]["receiver_id"];

            if (str != UID) {
              bool condition = CheckifAlreadyInserted(str, ids);

              if (condition == false) {
                ids.add(str);
              }
            }
          }
          setState(() => loading = false);
        }
      }).catchError((err) {
        setState(() => loading = false);
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  bool CheckifAlreadyInserted(String str, List<String> lst) {
    for (int i = 0; i < lst.length; i++) {
      if (str == lst[i]) {
        return true;
      }
    }

    return false;
  }

  Future<void> RetreiveUniqueChats() async {
    try {
      var user = await FirebaseAuth.instance.currentUser;
      String UID = user.email;

      setState(() => loading = true);
      DatabaseReference refer =
          await FirebaseDatabase.instance.reference().child("Users");
      refer.once().then((DataSnapshot snap) {
        if (snap == null) {
          setState(() => loading = false);
        } else {
          var keys = snap.value.keys;
          var values = snap.value;

          chaUsers.clear();
          for (var key in keys) {
            String str = values[key]["email"];
            String str_phone = values[key]["phone"];

            ChatUsers info;

            setState(() {
              if (str != UID) {
                for (int i = 0; i < ids.length; i++) {
                  if (str == ids[i]) {
                    for (int j = 0; j < phones.length; j++) {
                      if (str_phone == phones[j]) {
                        info = ChatUsers(
                            text: values[key]["name"].toString(),
                            email: ids[i].toString(),
                            secondaryText: "Tape to View Conversation",
                            image: values[key]["profile_picture"].toString(),
                            time: "Now");
                        chaUsers.add(info);
                      }
                    }
                  }
                }
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
  }

  Future<void> RetreiveChats() async {
    try {
      var user = await FirebaseAuth.instance.currentUser;
      String UID = user.email;

      setState(() => loading = true);
      DatabaseReference ref =
          await FirebaseDatabase.instance.reference().child("Users");
      ref.once().then((DataSnapshot snap) {
        if (snap == null) {
          setState(() => loading = false);
        } else {
          var keys = snap.value.keys;
          var values = snap.value;

          chaUsers.clear();
          for (var key in keys) {
            String str = values[key]["email"];

            ChatUsers info;

            if (str != UID) {
              info = ChatUsers(
                  text: values[key]["name"].toString(),
                  email: str,
                  secondaryText: "Tape to View Conversation",
                  image: values[key]["profile_picture"].toString(),
                  time: "Now");
              chaUsers.add(info);
            }
          }
          setState(() => loading = false);
        }
      }).catchError((err) {
        setState(() => loading = false);
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> getAllContacts() async {
    setState(() => loading = true);
    List<Contact> _contacts = (await ContactsService.getContacts(
      withThumbnails: false,
      photoHighResolution: false,
    ))
        .toList();
    _contacts.forEach((contact) {
      contact.phones.toSet().forEach((phone) {
        phones.add(phone.value);
      });
    });

    setState(() {
      contacts = _contacts;
      loading = false;
    });
  }

  Future<void> getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      contactlist.clear();
      getAllContacts();
    }
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    print(
        "something bla bla ${querySnapshot.docs[0].id} ${querySnapshot.docs[0]["name"]}  ${querySnapshot.docs[0]["imgUrl"]}");
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                profilePicUrl,
                height: 60,
                width: 60,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 5),
                Text(
                  widget.lastMessage,
                  style: TextStyle(fontSize: 15.0),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
