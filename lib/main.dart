import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zamazingo/Screens/chats.dart';
import 'package:zamazingo/Screens/groups.dart';

import 'package:zamazingo/Screens/globalchat.dart';
import 'package:zamazingo/Screens/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zamazingo/Screens/welcomepage.dart';
import 'package:zamazingo/utils/AppPreferenceUtil.dart';
import 'package:zamazingo/utils/auth.dart';

import 'Screens/onBoarding.dart';
import 'interfaces/show_hide_nav_bar_listener.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //If current user is not null then user is in login state
  final Auth _auth = Auth();
  final bool isLogged = await _auth.isLogged();

  SharedPreferences.getInstance().then((pref) {
    AppPreferenceUtil(pref: pref);
    bool isIntoCmplt = AppPreferenceUtil()
        .readBool(AppPreferenceUtil.isIntroComplete); //intro complete bool
    Zamazingo_Messaging myApp;
    myApp = Zamazingo_Messaging(
      initialRoute: isIntoCmplt
          ? isLogged
              ? '/Home'
              : '/' //welocmepage if page is find no route 
          : '/start', //setting initialRoute: If intro is complete then check if user is login or not otherwise start from intro
    );
    runApp(myApp);
  });
}

class Zamazingo_Messaging extends StatelessWidget {
  final String initialRoute;

  Zamazingo_Messaging({this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      title: 'Zamazingo Messaging',
      //home: OnboardingScreen(),
      initialRoute: initialRoute,
      routes: {
        '/start': (context) => OnboardingScreen(),
        '/Home': (context) => Home(),
        '/Profile': (context) => ProfilePage(),
        //Navigator.pushNamed(ctx, '/Profile', arguments: someObject); route with argument
        '/Chats': (context) => ChatsPage(),
        /*Otp(phoneNumber: "abc@gmail.com"),*/
        '/Global': (context) => GlobalPage(),
        '/': (context) => WelcomePage(),
      },
    );
  }
}

final Future<FirebaseApp> _initialization = Firebase.initializeApp();

@override
Widget build(BuildContext context) {
  return FutureBuilder(
    // Initialize FlutterFire:
    future: _initialization,
    // ignore: missing_return
    builder: (context, snapshot) {
      // Check for errors
      if (snapshot.hasError) {}

      // Once complete, show your application
      if (snapshot.connectionState == ConnectionState.done) {} 

      // Otherwise, show something whilst waiting for initialization to complete
    },
  );
}

class Home extends StatefulWidget {
  @override
  createState() => _HomeState();
}

class _HomeState extends State<Home> implements NavBarListener {
  int current_index = 0;
  var toHide = false;

  Widget listOfFragments(int index) {
    print(index);
    switch (index) {
      case 0:
        {
          ProfilePage profilePage = ProfilePage();
          profilePage.setScreenListener(this);
          return profilePage; //Passing callback as param
        }
      case 1:
        {
          return ChatsPage();
        }
      case 2:
        {
          return GroupPage();
        }

      case 3:
        {
          return GlobalPage();
        }
    }
  }

  Widget showHideNavigationBar() {
    if (!toHide)
      return BottomNavyBar(
        selectedIndex: current_index,
        onItemSelected: (index) {
          setState(() {
            current_index = index;
          });
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              icon: Icon(Icons.person),
              title: Text("Profile"),
              activeColor: Colors.redAccent,
              inactiveColor: Colors.black45),
          BottomNavyBarItem(
              icon: Icon(Icons.chat),
              title: Text("Messages"),
              activeColor: Colors.redAccent,
              inactiveColor: Colors.black45),
          BottomNavyBarItem(
              icon: Icon(Icons.group),
              title: Text("Groups"),
              activeColor: Colors.redAccent,
              inactiveColor: Colors.black45),
          BottomNavyBarItem(
              icon: Icon(Icons.cloud_queue_rounded),
              title: Text("Global Chat"),
              activeColor: Colors.redAccent,
              inactiveColor: Colors.black45),
        ],
      );
    else
      return Container(
        height: 0.0,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          onWillPop: () async => false, child: listOfFragments(current_index)),
      bottomNavigationBar: showHideNavigationBar(),
    );
  }

  @override
  void hideNavBar() {
    print('hideNavBar');
    toHide = true;
    setState(() {});
  }

  @override
  void showNavBar() {
    print('showNavBar');
    toHide = false;
    setState(() {});
  }
}

/*import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zamazingo/test/view/login/login.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primaryColor: const Color(0xFF02BB9F),
        primaryColorDark: const Color(0xFF167F67),
        accentColor: const Color(0xFF167F67),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Firebase',
      home: new LoginPage(),
    );
  }
}*/
