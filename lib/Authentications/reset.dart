import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zamazingo/Screens/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPage extends StatefulWidget
{
  @override
  ResetPageState createState() => ResetPageState();
}

class ResetPageState extends State<ResetPage>
{
  String emailAddress;
  final auth = FirebaseAuth.instance;
  final _resetformKey = GlobalKey<FormState>();
  TextEditingController _emailAddressController = TextEditingController();

  Widget _buildEmailRow()
  {
    return Padding(
      padding: EdgeInsets.only(top: 30, left: 10, right: 10),
      child: TextFormField(
        controller: _emailAddressController,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value)
        {
          emailAddress = value;
        },
        decoration: InputDecoration(
          labelStyle: TextStyle(
              color:  Colors.black54
          ),
            prefixIcon: Icon(Icons.email, color: Colors.redAccent,),
            labelText: "E- Mail",
  enabledBorder: UnderlineInputBorder
  (borderSide: BorderSide(color: Colors.deepOrange)),
  focusedBorder: UnderlineInputBorder(
  borderSide: BorderSide(color: Colors.red)
        ),
        ),
        validator: (value)
        {
          if (value.isEmpty)
          {
            return 'Enter Email Address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResetButton()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height/20),
          width: 5 * (MediaQuery.of(context).size.width/10),
          margin: EdgeInsets.only(bottom: 20, top: 30),
          child: RaisedButton(
            elevation: 3.0,
            color: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: ()
            {
              if (_resetformKey.currentState.validate())
              {
                auth.sendPasswordResetEmail(email: _emailAddressController.text).then((res) {
                  Navigator.of(context).pop();
                })
                  .catchError((err) {
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
                  onPressed: ()
                  {
                  Navigator.of(context).pop();
                  },
                  )
                  ],
                  );
                  });
                  });
              }
            },
            child:
            Text("Reset",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height/40,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBackButton()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height/20),
          width: 5 * (MediaQuery.of(context).size.width/10),
          margin: EdgeInsets.only(bottom: 20),
          child: RaisedButton(
            elevation: 3.0,
            color: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: ()
            {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>LoginPage()));
            },
            child:
            Text("Back",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height/40,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget ResetForm()
  {
    return Form(
      child: SingleChildScrollView(
        child: Column(children: <Widget>[
          _buildEmailRow(),
          _buildResetButton(),
          _buildBackButton(),
        ],
        ),
      ),
    );
  }

  Widget _buildContainer()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height*0.6,
            width: MediaQuery.of(context).size.width*0.8,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/profile/profile.png")
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Recover Password",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height/40,
                      ),)
                  ],
                ),
                ResetForm(),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return SafeArea(
      child: new WillPopScope(
        onWillPop: () async => false,
      child: Scaffold(
      backgroundColor: Color(0xfff2f3f7),
      resizeToAvoidBottomInset: false,
      body:Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height*0.7,
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
}