import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zamazingo/components/loading_bar.dart';
import 'package:zamazingo/interfaces/show_hide_nav_bar_listener.dart';
import 'package:zamazingo/models/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zamazingo/Screens/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePageEdit extends StatefulWidget {

  NavBarListener _view;

  setScreenListener(NavBarListener view) {
    _view = view;
  }

  @override
  ProfileEditPageState createState() => ProfileEditPageState();
}

class ProfileEditPageState extends State<ProfilePageEdit> {
  File _image;
  bool loading = false;
  bool showPassword = false;
  bool _isEnable = false;
  bool imageTypeNetwork = true;
  dynamic userKey;
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Users");
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String UserName, Email, Phone, Password, curr_User;
  String Image_URL =
      "https://firebasestorage.googleapis.com/v0/b/messaging-app-79bbd.appspot.com/o/images%2B2020-04-08%2017%3A25%3A37.122?alt=media&token=7e3fa3e5-c7c9-4aaa-b197-53a1592f0555";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    setState(() => loading = true);
    var user = await FirebaseAuth.instance.currentUser;

    setState(() {
      Email = user.email;
      print('Email $Email');
      UserName = user.displayName;
      Phone = user.phoneNumber;
      print('Photo $Image');
    });

    DatabaseReference ref = await FirebaseDatabase.instance.reference();
    ref.child('Users').once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var values = snap.value;

      for (var key in keys) {
        String str = values[key]["email"];
        if (str == Email) {
          nameController.text = values[key]["name"];
          phoneController.text = values[key]["phone"];
          emailController.text = values[key]["email"];
          passwordController.text = values[key]["password"];

          setState(() {
            userKey = key;
            print("name: " + values[key]["name"]);
            UserName = values[key]["name"];

            print("email: " + values[key]["email"]);
            Email = values[key]["email"];
            print("password: " + values[key]["password"]);
            Password = values[key]["password"];
            print("phone: " + values[key]["phone"]);
            Phone = values[key]["phone"];

            print("profile_picture: " + values[key]["profile_picture"]);
            Image_URL = values[key]["profile_picture"];

            if (Image_URL == "" || values[key]["profile_picture"] == null) {
              Image_URL =
                  "https://firebasestorage.googleapis.com/v0/b/messaging-app-79bbd.appspot.com/o/images%2B2020-04-08%2017%3A25%3A37.122?alt=media&token=7e3fa3e5-c7c9-4aaa-b197-53a1592f0555";
            }
          });
        }
      }
      setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.redAccent,
              elevation: 1,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditProfilePage(this.widget._view)),
                      ModalRoute.withName("/Profile"));
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    SettingsPage settingsPage=  SettingsPage();
                    settingsPage.setScreenListener(this.widget._view);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>settingsPage));
                  },
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.only(left: 16, top: 25, right: 16),
              child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: ListView(
                    children: [
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 0,
                      ),
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 4,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        color: Colors.black.withOpacity(0.1),
                                        offset: Offset(0, 10)),
                                  ],
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: imageTypeNetwork
                                          ? NetworkImage(Image_URL)
                                          : FileImage(_image))),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor),
                                  color: Colors.redAccent,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: () {
                                    //Galery opening after click edit icon.
                                    setState(() async {
                                      imageOptionChooser(context);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      buildTextFieldProfile(
                          "Full Name",
                          UserName,
                          false,
                          TextInputType.text,
                          true,
                          TextInputAction.next,
                          nameController),
                      buildTextFieldProfile(
                          "E- Mail",
                          Email,
                          false,
                          TextInputType.emailAddress,
                          false,
                          TextInputAction.next,
                          emailController),
                      buildTextFieldProfile(
                          "Phone Number",
                          Phone,
                          false,
                          TextInputType.phone,
                          true,
                          TextInputAction.done,
                          phoneController),
                      buildTextFieldProfile(
                          "Password",
                          Password,
                          true,
                          TextInputType.text,
                          false,
                          TextInputAction.next,
                          passwordController),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlineButton(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () {
                              ProfilePage profile = new ProfilePage();
                              profile.setScreenListener(this.widget._view);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => profile),
                                  ModalRoute.withName("/Profile"));
                            },
                            child: Text("CANCEL",
                                style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 2.2,
                                    color: Colors.black)),
                          ),
                          RaisedButton(
                            onPressed: () {
                              update();
                            },
                            color: Colors.redAccent,
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              "SAVE",
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.2,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ));
  }

  Widget buildTextFieldProfile(
      String labelText,
      String placeholder,
      bool isPasswordTextField,
      TextInputType textInputType,
      bool isEnableToWrite,
      TextInputAction textInputAction,
      TextEditingController textEditingController) {
    print("value: $placeholder");

    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        // initialValue: placeholder,
        controller: textEditingController,
        textInputAction: textInputAction,
        keyboardType: textInputType,
        cursorColor: Colors.redAccent,
        enabled: isEnableToWrite,
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = showPassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.redAccent,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(bottom: 1),
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.black54),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            /*    hintText: labelText,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),*/
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red))),
      ),
    );
  }

  /// ***************************Upload NewImage *******************/

  void update() async {
    setState(() => loading = true);
    print("isNetwork: $imageTypeNetwork");
    if (!imageTypeNetwork) {
      var date;
      int timeInMillis = 1586348737122;
      date = DateTime.now().millisecondsSinceEpoch;
      final _storage = FirebaseStorage.instance;
      final Reference reference = _storage.ref().child("images+$date");
      UploadTask uploadTask = reference.putFile(_image);
      uploadTask.then((res) async {
        Image_URL = await res.ref.getDownloadURL();
        print('url $Image_URL');
        updateUserInfo();
      }).catchError((onError) {
        print(onError);
      });
    } else {
      updateUserInfo();
    }
  }

  void updateUserInfo() {
    print("updateUserInfo: " + emailController.text);
    Map<String, dynamic> childrenPathValueMap = {};
    childrenPathValueMap['name'] = nameController.text;
    childrenPathValueMap['phone'] = phoneController.text;
    childrenPathValueMap['profile_picture'] = Image_URL;
    dbRef.child(userKey).update(childrenPathValueMap);
    setState(() => loading = false);
  }

  /// ***********************Add New Image*********************/

  void chooseImageFromGallery(BuildContext context) async {
    var pic = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (pic != null)
      this.setState(() {
        imageTypeNetwork = false;
        _image = pic;
      });
    Navigator.of(context).pop();
  }

  void chooseImageUsingCamera(BuildContext context) async {
    var pic = await ImagePicker.pickImage(source: ImageSource.camera);

    if (pic != null)
      this.setState(() {
        imageTypeNetwork = false;
        _image = pic;
      });
    Navigator.of(context).pop();
  }

  Future<void> imageOptionChooser(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Choose Image"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      "Gallery",
                      style: TextStyle(
                        color: Colors.redAccent,
                        letterSpacing: 1,
                        wordSpacing: 10,
                        fontSize: MediaQuery.of(context).size.height / 50,
                      ),
                    ),
                    onTap: () {
                      chooseImageFromGallery(context);
                    },
                  ),
                  GestureDetector(
                    child: Text(
                      "Camera",
                      style: TextStyle(
                        color: Colors.redAccent,
                        letterSpacing: 1,
                        wordSpacing: 10,
                        fontSize: MediaQuery.of(context).size.height / 50,
                      ),
                    ),
                    onTap: () {
                      chooseImageUsingCamera(context);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              RaisedButton(
                child: Text("Cancel"),
                color: Colors.redAccent,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
