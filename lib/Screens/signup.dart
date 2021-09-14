import 'dart:async';
import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zamazingo/Authentications/verifyUser.dart';
import 'package:zamazingo/Screens/Otp.dart';
import 'package:zamazingo/Screens/database.dart';
import 'package:zamazingo/Screens/loginpage.dart';
import 'package:zamazingo/Screens/shared_pref.dart';
import 'package:zamazingo/components/loading_bar.dart';
import 'package:zamazingo/interfaces/firebase_email_listener.dart';
import 'package:zamazingo/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:zamazingo/utils/app_util.dart';
import 'package:zamazingo/interfaces/firebase_listenter.dart';
import 'package:zamazingo/Authentications/firebase_phone_util.dart';

class SignUpPage extends StatefulWidget {
  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage>
    implements FirebaseAuthListener, FirebaseEmailVerificationListener {
  bool loading = false;
  File _image;
  String ImageURL_ = "";
  String emailAddress, passsword, confirm_password, name;
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Users");
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();

  bool isPhoneVerified = false, isEmailVerified = false;
  FirebasePhoneUtil firebasePhoneUtil;
  String UserName, Password, Email, Phone;
  String Image_URL =
      "https://firebasestorage.googleapis.com/v0/b/zm-official-server.appspot.com/o/null_picture.jpg?alt=media&token=351a16e9-9265-4d66-a5b2-b9564e91df1b";

  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp;
  var code;
  var number;
  dynamic userKey;

  @override
  void initState() {
    super.initState();
    firebasePhoneUtil = FirebasePhoneUtil();
    firebasePhoneUtil.setScreenListener(this);
    regExp = new RegExp(pattern);

    getUserData();
  }

  void ChooseImageFromGallery(BuildContext context) async {
    /*await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;*/

    var pic = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      _image = pic;
    });

    Navigator.of(context).pop();
  }

  void ChooseImageUsingCamera(BuildContext context) async {
    var pic = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      _image = pic;
    });
    Navigator.of(context).pop();
  }

  Future<void> ImageOptionChooser(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Choose An Image"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      "With Gallery",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 17.5,
                      ),
                    ),
                    onTap: () {
                      ChooseImageFromGallery(context);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Text(
                      "With Camera",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 17.5,
                      ),
                    ),
                    onTap: () {
                      ChooseImageUsingCamera(context);
                    },
                  )
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

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : SafeArea(
            child: new WillPopScope(
              onWillPop: () async => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                          title: Text('Are you sure you want to quit sign up?'),
                          actions: <Widget>[
                            RaisedButton(
                                child: Text('Confirm'),
                                textColor: Colors.black,
                                color: Colors.white,
                                onPressed: () =>
                                    Navigator.of(context).pop(true)),
                            RaisedButton(
                                child: Text('Cancel'),
                                textColor: Colors.white,
                                color: Colors.redAccent,
                                onPressed: () =>
                                    Navigator.of(context).pop(false)),
                          ])),
              child: Scaffold(
                backgroundColor: Color(0xfff2f3f7),
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.only(
                            bottomLeft: const Radius.circular(70),
                            bottomRight: const Radius.circular(70),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //_buildLogo(),
                        _buildContainer()
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        cursorColor: Colors.redAccent,
        onChanged: (value) {
          emailAddress = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.email,
              color: Colors.redAccent,
            ),
            labelStyle: TextStyle(color: Colors.black54),
            labelText: "E- Mail",
            hintText: "y******@gmail.com",
            hintStyle:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red))),
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter E- Mail Address';
          }
          return null;
        },
      ),
    );
  }

  Widget UserForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildUserNameRow(),
            _buildEmailRow(),
            _buildUserPhoneRow(),
            _buildPasswordRow(),
            _buildConfirmPasswordRow(),
            _buildHaveAccount(),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserNameRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: TextFormField(
        controller: nameController,
        keyboardType: TextInputType.text,
        cursorColor: Colors.redAccent,
        onChanged: (value) {
          name = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: Colors.redAccent,
            ),
            labelStyle: TextStyle(color: Colors.black54),
            labelText: "Full Name",
            hintText: "Yunus Emre Benli",
            hintStyle:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red))),
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter Your Full Name';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildUserPhoneRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: TextFormField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        cursorColor: Colors.redAccent,
        onChanged: (value) {
          name = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.phone,
              color: Colors.redAccent,
            ),
            labelStyle: TextStyle(color: Colors.black54),
            labelText: "Phone Number",
            hintText: "+90**********",
            hintStyle:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red))),
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter Phone Number With Area Code';
          } else if (value.length < 12)
            return 'Your Phone Number Must Occur 12 Digits';
          else if (!regExp.hasMatch(value)) {
            return 'Please Enter Valid Mobile Number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: TextFormField(
        controller: passwordController,
        keyboardType: TextInputType.text,
        obscureText: true,
        cursorColor: Colors.redAccent,
        onChanged: (value) {
          passsword = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.redAccent,
            ),
            labelStyle: TextStyle(color: Colors.black54),
            labelText: "Password",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red))),
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter Password';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: TextFormField(
        controller: confirmpassController,
        cursorColor: Colors.redAccent,
        keyboardType: TextInputType.text,
        obscureText: true,
        onChanged: (value) {
          confirm_password = value;
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.redAccent,
            ),
            labelStyle: TextStyle(color: Colors.black54),
            labelText: "Confirm Password",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red))),
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value.isEmpty) {
            return 'Confirm Password';
          } else if (value.isNotEmpty && value != passwordController.text) {
            return "Password Doesn't Match";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(bottom: 20),
          child: RaisedButton(
            elevation: 3.0,
            color: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                code = phoneController.text.substring(0, 2);
                number = phoneController.text
                    .substring(2, phoneController.text.length);
                register();
              } else {
                Fluttertoast.showToast(
                  msg: "Signed Up Failed",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                );
              }
            },
            child: Text(
              "Sign Up",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 15.0),
                    padding: EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.width / 3,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _image != null
                              ? FileImage(_image)
                              : AssetImage("assets/profile/profile.png")),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 7.5,
                    ),
                    child: FlatButton(
                      textColor: Colors.white,
                      color: Colors.redAccent,
                      padding: EdgeInsets.all(10),
                      height: 30,
                      onPressed: () {
                        ImageOptionChooser(context);
                      },
                      child: Text(
                        'Add Profile Picture',
                        style: TextStyle(
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                  UserForm(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
          child: Text("Have Account?"),
        ),
      ],
    );
  }

  User user;

  void register() async {
    var date;
    setState(() {
      loading = true;
      String str = "";

      int timeInMillis = 1586348737122;
      date = DateTime.now().millisecondsSinceEpoch;
    });

    final _storage = FirebaseStorage.instance;
    final Reference reference = _storage.ref().child("images+$date");
    UploadTask uploadTask = reference.putFile(_image);

    uploadTask.then((res) async {
      String url = await res.ref.getDownloadURL();
      print('url $url');

      ImageURL_ = url;
      SharedPreferenceHelper()
          .saveUserName(emailController.text.replaceAll("@gmail.com", ""));
      SharedPreferenceHelper().saveUserEmail(emailController.text);
      SharedPreferenceHelper().saveDisplayName(nameController.text);
      SharedPreferenceHelper().saveUserProfileUrl(ImageURL_);

      Map<String, dynamic> userInfoMap = {
        "email": emailController.text,
        "username": emailController.text.replaceAll("@gmail.com", ""),
        "name": nameController.text,
        "imgUrl": ImageURL_,
      };
      DatabaseMethods().addUserInfoToDB(userInfoMap).then((value) async {
        await auth
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .then((result) {
          dbRef.push().set({
            "email": emailController.text,
            "name": nameController.text,
            "phone": phoneController.text,
            "password": passwordController.text,
            "profile_picture": ImageURL_,
            "isPhoneVerified": false,
            "isEmailVerified": false,
          }).then((res) async {
            if (result == null) {
              showLoader(false);
            }

            if (result.user != null) await getUserData();

            result.user != null
                ? !result.user.emailVerified
                    ? openEmailVerification()
                    : onEmailUserVerified(result.user)
                : openEmailVerification();
          });
        }).catchError((err) {
          setState(() => loading = false);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Error"),
                  content: Text(err.message),
                  actions: [
                    RaisedButton(
                      child: Text("OK"),
                      color: Colors.redAccent,
                      textColor: Colors.white,
                      onPressed: () {
                        getUserData();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        });
      });
      print('image $ImageURL_');
    }).catchError((onError) {
      print(onError);
    });
  }

  void openEmailVerification() {
    var cerify = VerifyEmail();
    cerify.setScreenListener(this);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => cerify),
    );
  }

  void StoreImageIntoFirebaseStorage() async {
    final _storage = FirebaseStorage.instance;
    final Reference reference = _storage.ref().child("images/");
    UploadTask uploadTask = reference.putFile(_image);

    uploadTask.then((res) async {
      String url = await res.ref.getDownloadURL();
      print('url $url');

      setState(() {
        ImageURL_ = url;
        print('image $ImageURL_');
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpassController.dispose();
  }

  void showLoader(bool showHideLoader) {
    setState(() {
      loading = showHideLoader;
    });
  }

  @override
  onLoginUserVerified() async {
    await getUserData();
    print('signUpOnLoginUserVerified');
    showLoader(true);
    await updateUserInfo('isPhoneVerified');
    showLoader(false);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
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

  @override
  verificationCodeSent(int forceResendingToken) {
    moveOtpVerificationScreen();
  }

  void moveOtpVerificationScreen() {
    print('moveOtpVerificationScreen');
    showLoader(false);
    // parameter.

    Otp otp = Otp(phoneNumber: phoneController.text.toString());
    otp.setScreenListener(this);
    Navigator.push(context, MaterialPageRoute(builder: (context) => otp));
  }

  @override
  onEmailUserVerified(User currentUser) async {
    print('onEmailUserVerified: $user');
    await updateUserInfo('isEmailVerified');
    if (!isPhoneVerified) {
      showLoader(true);
      firebasePhoneUtil.verifyPhoneNumber(phoneController.text.toString());
      showLoader(false);
    } else
      onLoginUserVerified();
  }

  @override
  onErrorCode(String message, String code) {
    showAlert(code);
    print('codeError');
    showLoader(false);
  }

  @override
  onError(String message) {
    showAlert(message);
    print('codeError');
    showLoader(false);
  }

  @override
  void showAlert(String msg) {
    setState(() {
      AppUtil().showAlertNEw(msg, context);
    });
  }

  Future<void> getUserData() async {
    setState(() => loading = true);
    user = await FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    setState(() {
      print('setState');
      Email = user.email;
      Phone = user.phoneNumber;
    });

    DatabaseReference ref = await FirebaseDatabase.instance.reference();
    ref.child('Users').once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var values = snap.value;

      for (var key in keys) {
        String str = values[key]["email"];
        if (str == Email) {
          if (mounted) {
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
                    "https://firebasestorage.googleapis.com/v0/b/zm-official-server.appspot.com/o/null_picture.jpg?alt=media&token=351a16e9-9265-4d66-a5b2-b9564e91df1b";
              }
            });
            onEmailUserVerified(user);
            break;
          }
        }
      }
      if (mounted) setState(() => loading = false);
    });
  }
}
