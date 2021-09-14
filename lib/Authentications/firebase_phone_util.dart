import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:zamazingo/interfaces/firebase_listenter.dart';

class FirebasePhoneUtil {
  static final FirebasePhoneUtil _instance = new FirebasePhoneUtil.internal();

  FirebasePhoneUtil.internal();

  factory FirebasePhoneUtil() {
    return _instance;
  }

  FirebaseAuthListener _view;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId;
  User user;

  setScreenListener(FirebaseAuthListener view) {
    _view = view;
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential user) {
      print('verificationCompleted');
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      print('verificationFailed');
      _view.onErrorCode(authException.message, authException.code);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print('codeSent: $forceResendingToken');
      this.verificationId = verificationId;
      _view.verificationCodeSent(forceResendingToken);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print('codeAutoRetrievalTimeout');
      _view.onError("Code Auto Retrieval Timeout");
    };

    print("number: ${phoneNumber}");
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  verifyOtp(String smsCode) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    user = _auth.currentUser;
    await user.linkWithCredential(credential).then((userLinked) async {
     /* print('providerData   ${userLinked}');
      print('providerData   ${user.providerData}');*/
      await user.reload();
      onLoginUserVerified();
    }).catchError((error) {
      _view.onError(error.toString());
    });
  }

  void onLoginUserVerified() {
    _view.onLoginUserVerified();
  }

  onTokenError(String string) {
    print("libs " + string);
  }
}
