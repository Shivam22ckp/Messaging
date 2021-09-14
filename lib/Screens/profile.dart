import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zamazingo/Authentications/firebase_phone_util.dart';
import 'package:zamazingo/Authentications/verifyUser.dart';
import 'package:zamazingo/components/loading_bar.dart';
import 'package:zamazingo/interfaces/firebase_email_listener.dart';
import 'package:zamazingo/interfaces/show_hide_nav_bar_listener.dart';
import 'package:zamazingo/models/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zamazingo/utils/app_util.dart';
import 'package:zamazingo/interfaces/firebase_listenter.dart';
import '../main.dart';
import 'Otp.dart';
import 'edit_profile.dart';

class ProfilePage extends StatelessWidget {
 /* Function callbackHide;
  Function callbackShow;*/



 /* ProfilePage(this.callbackHide, this.callbackShow);*/

  NavBarListener _view;

  setScreenListener(NavBarListener view) {
    _view = view;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      title: "Profile",
      home: EditProfilePage(_view),
    );
  }
}

class EditProfilePage extends StatefulWidget {
/*  Function callbackHide;
  Function callbackShow;

  EditProfilePage(this.callbackHide, this.callbackShow);*/

  NavBarListener _view;

  EditProfilePage(NavBarListener view) {
    _view = view;
  }


  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    implements FirebaseEmailVerificationListener, FirebaseAuthListener,NavBarListener {
  FirebasePhoneUtil firebasePhoneUtil;
  bool loading = false;
  bool showPassword = false;
  bool _isEnable = false;
  String UserName, Email, Phone, Password, curr_User;
  bool isEmailVerified = false;
  bool isPhoneVerified = false;
  dynamic userKey;
  String Image_URL =
      "https://firebasestorage.googleapis.com/v0/b/messaging-app-79bbd.appspot.com/o/images%2B2020-04-08%2017%3A25%3A37.122?alt=media&token=7e3fa3e5-c7c9-4aaa-b197-53a1592f0555";
  User user;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Users");
  FirebaseAuth auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();

    getUserData();
  }

  Future<void> getUserData() async {
    setState(() => loading = true);
    user = await FirebaseAuth.instance.currentUser;
    await user.reload();

    setState(() {
      Email = user.email;
      print('Email $Email');
      UserName = user.displayName;
      Phone = user.phoneNumber;
      print('Photo $Image');
    });

    dbRef.once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var values = snap.value;

      for (var key in keys) {
        String str = values[key]["email"];

        if (str == Email) {
          if (mounted)
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

              print("isPhoneVerified: ${values[key]["isPhoneVerified"]}");
              isPhoneVerified = values[key]["isPhoneVerified"];

              print("isEmailVerified: ${values[key]["isEmailVerified"]}");
              isEmailVerified = values[key]["isEmailVerified"];

              if (Image_URL == "" || values[key]["profile_picture"] == null) {
                Image_URL =
                    "https://firebasestorage.googleapis.com/v0/b/messaging-app-79bbd.appspot.com/o/images%2B2020-04-08%2017%3A25%3A37.122?alt=media&token=7e3fa3e5-c7c9-4aaa-b197-53a1592f0555";
              }
            });
        }
      }
      if (mounted) setState(() => loading = false);

      if (!isEmailVerified) {
        firebasePhoneUtil = FirebasePhoneUtil();
        firebasePhoneUtil.setScreenListener(this);
        hideNavBar();
        openEmailVerification();
      } else if (!isPhoneVerified) {
        firebasePhoneUtil = FirebasePhoneUtil();
        firebasePhoneUtil.setScreenListener(this);
        hideNavBar();
        showLoader(true);
        firebasePhoneUtil.verifyPhoneNumber(Phone);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.redAccent,
              elevation: 1,
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
                        "Profile",
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
                                      image: NetworkImage(Image_URL))),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      buildTextFieldProfile("Full Name", UserName, false),
                      buildTextFieldProfile("E- Mail", Email, false),
                      buildTextFieldProfile("Phone Number", Phone, false),
                      buildTextFieldProfile("Password", Password, true),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              ProfilePageEdit profileEdit = ProfilePageEdit();
                              profileEdit.setScreenListener(this.widget._view);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => profileEdit),
                                  ModalRoute.withName("/Profile"));
                            },
                            color: Colors.redAccent,
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              "EDIT",
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
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        enabled: _isEnable,
        obscureText: isPasswordTextField ? showPassword : true,
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
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red))),
      ),
    );
  }

  void openEmailVerification() {
    print('openEmailVerification: isEmailVerified');
    if (!isEmailVerified) {
      var cerify = VerifyEmail();
      cerify.setScreenListener(this);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => cerify),
      );
    }
  }

  @override
  onEmailUserVerified(User currentUser) async {
    print('onEmailUserVerified: $isEmailVerified');
    await updateUserInfo('isEmailVerified');
    if (!isPhoneVerified) {
      showLoader(true);
      firebasePhoneUtil.verifyPhoneNumber(Phone);
    } else
      onLoginUserVerified();
  }

  @override
  onError(String message) {
    showAlert(message);
    print('codeError');
  }

  Future<void> updateUserInfo(String verification) async {
    setState(() => loading = true);
    Map<String, dynamic> childrenPathValueMap = {};
    childrenPathValueMap[verification] = true;
    dbRef.child(userKey).update(childrenPathValueMap);
    user = auth.currentUser;
    await user.reload();
    setState(() => loading = false);
  }

  void showAlert(String msg) {
    setState(() {
      AppUtil().showAlertNEw(msg, context);
    });
  }

  @override
  onLoginUserVerified() async {
    if (!isEmailVerified || !isPhoneVerified) {
      print('signUpOnLoginUserVerified');
      showLoader(true);
      await updateUserInfo('isPhoneVerified');
      showLoader(false);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
    }
  }

  @override
  verificationCodeSent(int forceResendingToken) {
    moveOtpVerificationScreen();
  }

  void moveOtpVerificationScreen() {
    print('moveOtpVerificationScreen');
    showLoader(false);
    // parameter.
    Otp otp = Otp(phoneNumber: Phone);
    otp.setScreenListener(this);
    Navigator.push(context, MaterialPageRoute(builder: (context) => otp));
  }

  void showLoader(bool showHideLoader) {
    setState(() {
      loading = showHideLoader;
    });
  }

  @override
  onErrorCode(String message, String code) {
    showAlert(code);
    print('codeError');
    showLoader(false);
    showNavBar();
  }

  @override
  void hideNavBar() {
   this.widget._view.hideNavBar();
  }

  @override
  void showNavBar() {
    this.widget._view.showNavBar();
  }
}
