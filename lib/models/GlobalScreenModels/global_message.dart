import 'package:flutter/cupertino.dart';
import 'package:zamazingo/Screens/globalchat.dart';

class GlobalMessage{
  String message;
  MessageType type;
  var dateTime;
  var name;
  GlobalMessage({@required this.message, @required this.type, @required this.dateTime, @required this.name});

}