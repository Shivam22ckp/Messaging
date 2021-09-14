

import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';

class AppUtil {
  static final AppUtil _instance = new AppUtil.internal();
  static bool networkStatus;

  AppUtil.internal();

  factory AppUtil() {
    return _instance;
  }


  bool isNetworkWorking() {
    return networkStatus;
  }

  void showAlertNEw(String msg,BuildContext context) {
    print('toastMessage: '+msg);
    Toast.show(msg, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
  }

  void showAlert(String msg) {
    print('toastMessage: '+msg);
  }


}
