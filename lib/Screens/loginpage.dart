import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zamazingo/Authentications/reset.dart';
import 'package:zamazingo/Authentications/verifyUser.dart';
import 'package:zamazingo/Screens/shared_pref.dart';
import 'package:zamazingo/Screens/signup.dart';
import 'package:zamazingo/components//loading_bar.dart';
import 'package:zamazingo/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool loading = false;
  String emailAddress, passsword;
  final auth = FirebaseAuth.instance;
  final _loginformKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: emailAddressController,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          emailAddress = value;
        },
        decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(
              Icons.email,
              color: Colors.redAccent,
            ),
            labelText: "E- Mail",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red))),
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter Email Address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Padding(
      padding: EdgeInsets.only(top: 10, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ResetPage()));
            },
            child: Text("Forgot Password?"),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: passwordController,
        keyboardType: TextInputType.text,
        obscureText: true,
        onChanged: (value) {
          passsword = value;
        },
        decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.redAccent,
            ),
            labelText: "Password",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red))),
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter Password';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(top: 20),
          child: RaisedButton(
            elevation: 3.0,
            color: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              Login();
            },
            child: Text(
              "Login",
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

  Widget LoginForm() {
    return Form(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildEmailRow(),
            _buildPasswordRow(),
            _buildForgotPassword(),
            _buildLoginButton(),
            _buildOR(),
            _buildRegisterAccount(),
          ],
        ),
      ),
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
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/profile/profile.png")),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 30,
                      ),
                    )
                  ],
                ),
                LoginForm(),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRegisterAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignUpPage()));
          },
          child: Text("Create an Account",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.redAccent,
              )),
        ),
      ],
    );
  }

  Widget _buildOR() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 20, top: 25),
            child: Text(
              "—OR—",
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : SafeArea(
            child: Scaffold(
              backgroundColor: Color(0xfff2f3f7),
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Container(
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
          );
  }

  void Login() async {
    setState(() => loading = true);
    SharedPreferenceHelper()
        .saveUserName(emailAddressController.text.replaceAll("@gmail.com", ""));
    dynamic result = auth
        .signInWithEmailAndPassword(email: emailAddress, password: passsword)
        .then((result) async {
      if (result == null) {
        setState(() => loading = false);
      }
      User user = auth.currentUser;
      await user.reload();
      user = await auth.currentUser;
      if (user.emailVerified) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => VerifyEmail()));
      }
    }).catchError((err) {
      setState(() => loading = false);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("No User found with the given info."),
              actions: [
                RaisedButton(
                  child: Text("OK"),
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }
}
