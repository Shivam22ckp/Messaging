import 'dart:collection';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zamazingo/Screens/chats.dart';
import 'package:zamazingo/Screens/practice.dart';
import 'package:zamazingo/components/ContactComponent/list_contacts.dart';
import 'package:zamazingo/components/loading_bar.dart';
import 'package:zamazingo/main.dart';
import 'package:zamazingo/models/ContactModel//MyContacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MyContactsPage extends StatefulWidget {
  MyContactsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<MyContactsPage> {
  List<Contact> contacts = [];
  List<String> phones = [];
  bool loading = false;

  Map<String, Contacts> contactlist = new HashMap<String, Contacts>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        getPermissions();
      });
    });
  }

  Future<void> getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      contactlist.clear();
      getAllContacts();
      FetchingContactsFromFirebase();
    }
  }

  Future<void> FetchingContactsFromFirebase() async {
    setState(() => loading = true);
    var user = await FirebaseAuth.instance.currentUser;
    String CurrentID = user.email;

    DatabaseReference ref = await FirebaseDatabase.instance.reference();
    ref.child('Users').orderByValue().once().then((DataSnapshot snap) {
      contactlist.clear();
      var keys = snap.value.keys;
      var values = snap.value;
      var loop_i = 0;

      for (var key in keys) {
        String str = values[key]["phone"];
        String email_str = values[key]["email"];

        if (email_str != CurrentID) {
          for (var phn in phones) {
            //print(phn);
            phn = phn.replaceAll(new RegExp(r"\s+"), "");
            str = str.replaceAll(new RegExp(r"\s+"), "");
            if (phn == str) {
              /*DatabaseReference reference = await FirebaseDatabase.instance.reference();
            reference.child('Users').once().then((DataSnapshot snap)
            {*/
              setState(() {
                print("name: " + values[key]["name"]);
                String UserName = values[key]["name"];
                print("email: " + values[key]["email"]);
                String Email = values[key]["email"];
                print("phone: " + values[key]["phone"]);
                String Phone = values[key]["phone"];
                print("profile_picture: " + values[key]["profile_picture"]);
                String Image_URL = values[key]["profile_picture"];
                //if(Image_URL == "" || values[key]["profile_picture"] ==  null) {  Image_URL = "https://firebasestorage.googleapis.com/v0/b/messaging-app-79bbd.appspot.com/o/images%2B2020-04-08%2017%3A25%3A37.122?alt=media&token=7e3fa3e5-c7c9-4aaa-b197-53a1592f0555"; }
                // contactlist.put(Email,);

                contactlist['data' + loop_i.toString()] = Contacts(
                    name: UserName,
                    phone: Phone,
                    image: Image_URL,
                    email: Email);
              });
              loop_i++;
              //});
            }
          }
        }
      }
      phones.clear();
      setState(() => loading = false);
    });
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
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
        print(phone.value);
        phones.add(phone.value);
      });
    });

    setState(() {
      contacts = _contacts;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
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
                            "Contacts",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.home_outlined,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Home()),
                                  ModalRoute.withName("/"));
                            },
                          ),
                          FlatButton.icon(
                            onPressed: () {
                              getPermissions();
                            },
                            icon: Icon(Icons.refresh),
                            label: Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search Contact",
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
                        ),
                      )),
                  contactlist.isEmpty
                      ? Center(child: Text('No Contacts. Please, Refresh'))
                      : ListView.builder(
                          itemCount: contactlist.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 16),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ContactList(
                              name: contactlist['data' + index.toString()].name,
                              phone:
                                  contactlist['data' + index.toString()].phone,
                              image:
                                  contactlist['data' + index.toString()].image,
                              email:
                                  contactlist['data' + index.toString()].email,
                            );
                          },
                        ),
                ],
              ),
            ),
          );
  }
}
