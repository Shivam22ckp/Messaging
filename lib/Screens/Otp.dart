import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zamazingo/Authentications/firebase_phone_util.dart';
import 'package:zamazingo/components/loading_bar.dart';
import 'package:zamazingo/utils/app_util.dart';
import 'package:zamazingo/interfaces/firebase_listenter.dart';

class Otp extends StatefulWidget {
  final String phoneNumber;

  Otp({Key key, @required this.phoneNumber}) : super(key: key);

  FirebaseAuthListener _view;

  setScreenListener(FirebaseAuthListener view) {
    _view = view;
  }

  @override
  _OtpState createState() => new _OtpState();
}

class _OtpState extends State<Otp>
    with SingleTickerProviderStateMixin
    implements FirebaseAuthListener {
  bool _isMobileNumberEnter = false;
  FirebasePhoneUtil presenter;
  bool _isLoading = false;

  // Constants
  final int time = 120;
  AnimationController _controller;

  bool isWrongCode = false;

  final _teOtpDigitOne = TextEditingController();
  final _teOtpDigitTwo = TextEditingController();
  final _teOtpDigitThree = TextEditingController();
  final _teOtpDigitFour = TextEditingController();
  final _teOtpDigitFive = TextEditingController();
  final _teOtpDigitSix = TextEditingController();

  FocusNode _focusNodeDigitOne = new FocusNode();
  FocusNode _focusNodeDigitTwo = new FocusNode();
  FocusNode _focusNodeDigitThree = new FocusNode();
  FocusNode _focusNodeDigitFour = new FocusNode();
  FocusNode _focusNodeDigitFive = new FocusNode();
  FocusNode _focusNodeDigitSix = new FocusNode();

  Timer timer;
  int totalTimeInSeconds;
  bool _hideResendButton;

  String userName = "";
  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;

  // Returns "Appbar"
  get _getAppbar {
    return new AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: new InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: new Icon(
          Icons.arrow_back,
          color: Colors.black54,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
    );
  }

  get _getScreenLogo {
    return new Container(
      width: MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).size.width / 4,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
            fit: BoxFit.cover, image: AssetImage("images/otpCodeThree.jpg")),
      ),
    );
  }

  // Return "Email" label
  get _getEmailLabel {
    return new Text(
      "Verify Your Mobile Number",
      textAlign: TextAlign.center,
      style: new TextStyle(
          fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.w600),
    );
  }

  // Return "OTP" input field
  get _getInputField {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpTextField(_teOtpDigitOne, _focusNodeDigitOne),
        _otpTextField(_teOtpDigitTwo, _focusNodeDigitTwo),
        _otpTextField(_teOtpDigitThree, _focusNodeDigitThree),
        _otpTextField(_teOtpDigitFour, _focusNodeDigitFour),
        _otpTextField(_teOtpDigitFive, _focusNodeDigitFive),
        _otpTextField(_teOtpDigitSix, _focusNodeDigitSix),
      ],
    );
  }

  // Returns "OTP" input part
  get _getInputPart {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(38), child: _getScreenLogo),
              _getEmailLabel
            ]),
        Padding(padding: EdgeInsets.all(10)),
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _getInputField,
              _hideResendButton ? _getTimerText : _getResendButton,
            ]),
        Padding(padding: EdgeInsets.all(10)),
        Padding(padding: EdgeInsets.all(4), child: _getVerifyNowButton)
      ],
    );
  }

  get _getVerifyNowButton {
    return new RaisedButton(
      onPressed: () {
        _submit();
      },
      color: Colors.redAccent,
      padding: EdgeInsets.symmetric(horizontal: 50),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Text(
        "Verify Now",
        style: TextStyle(fontSize: 14, letterSpacing: 2.2, color: Colors.white),
      ),
    );
  }

  // Returns "Timer" label
  get _getTimerText {
    return new Column(children: [
      Padding(padding: EdgeInsets.all(10)),
      Container(
        height: 32,
        child: new Offstage(
          offstage: !_hideResendButton,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                Icons.access_time,
                size: 25,
              ),
              new SizedBox(
                width: 5.0,
              ),
              OtpTimer(_controller, 22.0, Colors.black)
            ],
          ),
        ),
      )
    ]);
  }

  // Returns "Resend" button
  get _getResendButton {
    return new Column(
      children: [
        Padding(padding: EdgeInsets.all(20)),
        new Text(
          "Did not receive OTP?",
          textAlign: TextAlign.center,
          style: new TextStyle(
              fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        Padding(padding: EdgeInsets.all(6)),
        InkWell(
          child: new Container(
            height: 32,
            width: 120,
            decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(32)),
            alignment: Alignment.center,
            child: new Text(
              "Resend OTP",
              style: new TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          onTap: () {
            // Resend you OTP via API or anything
            showLoader();
            presenter.verifyPhoneNumber(widget.phoneNumber);
            resetOTPState();
          },
        )
      ],
    );
  }

  // Overridden methods
  @override
  void initState() {
    totalTimeInSeconds = time;
    super.initState();
    presenter = FirebasePhoneUtil();
    presenter.setScreenListener(this);
    changeFocusListener(_teOtpDigitOne, _focusNodeDigitTwo);
    changeFocusListener(_teOtpDigitTwo, _focusNodeDigitThree);
    changeFocusListener(_teOtpDigitThree, _focusNodeDigitFour);
    changeFocusListener(_teOtpDigitFour, _focusNodeDigitFive);
    changeFocusListener(_teOtpDigitFive, _focusNodeDigitSix);
    changeFocusListener(_teOtpDigitSix, _focusNodeDigitSix);

    checkFiled(_teOtpDigitOne);
    checkFiled(_teOtpDigitTwo);
    checkFiled(_teOtpDigitThree);
    checkFiled(_teOtpDigitFour);
    checkFiled(_teOtpDigitFive);
    checkFiled(_teOtpDigitSix);

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                print('Dismimsstimer: ${_controller.value}');
                _hideResendButton = !_hideResendButton;
              });
            }
          });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
    _startCountdown();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.redAccent,
            body: new WillPopScope(
              onWillPop: () async => false,
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
                            bottomLeft: const Radius.circular(40),
                            bottomRight: const Radius.circular(40),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(20)),
                        _buildContainer(),
                      ],
                    )
                  ],
                ),
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
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Container(
              child: _getInputPart,
            ),
          ),
        ),
      ],
    );
  }

  void showLoader() {
    setState(() => _isLoading = true);
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(TextEditingController field, FocusNode focusNode) {
    return new Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: new TextFormField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        controller: field,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: new TextStyle(
          fontSize: 30.0,
          color: Colors.black,
        ),
      ),
      decoration: BoxDecoration(
//            color: Colors.grey.withOpacity(0.4),
          border: Border(
              bottom: BorderSide(
        width: 2.0,
        color: isWrongCode ? Colors.red : Colors.black,
      ))),
    );
  }

  Future<Null> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });

    print('timer: ${_controller.value}');
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void checkFiled(TextEditingController teController) {
    teController.addListener(() {
      if (!_teOtpDigitOne.text.isEmpty &&
          !_teOtpDigitTwo.text.isEmpty &&
          !_teOtpDigitThree.text.isEmpty &&
          !_teOtpDigitFour.text.isEmpty &&
          !_teOtpDigitFive.text.isEmpty &&
          !_teOtpDigitSix.text.isEmpty) {
        _isMobileNumberEnter = true;
      } else {
        _isMobileNumberEnter = false;
      }
      setState(() {});
    });
  }

  bool firstFocusCheck = false;

  void changeFocusListener(
      TextEditingController teOtpDigitOne, FocusNode focusNodeDigitTwo) {
    teOtpDigitOne.addListener(() {
      firstFocusCheck = false;
      if (_teOtpDigitOne.text.length == 0 && !firstFocusCheck) {
        FocusScope.of(context).requestFocus(_focusNodeDigitOne);
        firstFocusCheck = true;
      } else if (teOtpDigitOne.text.length > 0 && focusNodeDigitTwo != null) {
        FocusScope.of(context).requestFocus(focusNodeDigitTwo);
      }

      setState(() {
        isWrongCode = false;
      });
    });
  }

  void resetOTPState() {
    _teOtpDigitOne.text = "";
    _teOtpDigitTwo.text = "";
    _teOtpDigitThree.text = "";
    _teOtpDigitFour.text = "";
    _teOtpDigitFive.text = "";
    _teOtpDigitSix.text = "";
    setState(() {
      isWrongCode = false;
    });
  }

  @override
  onErrorCode(String message, String code) {
    showAlert(code);
    print('codeError');
    resetOTPState();
    setState(() {
      isWrongCode = false;
      _isLoading = false;
    });
  }

  @override
  onError(String message) {
    showAlert(message);
    print('codeError');
    resetOTPState();
    setState(() {
      isWrongCode = false;
      _isLoading = false;
    });
  }

  @override
  onLoginUserVerified() {
    print('otpOnLoginUserVerified');
    /* Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Home()));*/
    widget._view.onLoginUserVerified();
  }

  @override
  verificationCodeSent(int forceResendingToken) {
    setState(() {
      _isLoading = false;
    });
    resetOTPState();
    _startCountdown();
  }

  void _submit() {
    if (_isMobileNumberEnter) {
      showLoader();
      print('otpSubmit');
      presenter.verifyOtp(_teOtpDigitOne.text +
          _teOtpDigitTwo.text +
          _teOtpDigitThree.text +
          _teOtpDigitFour.text +
          _teOtpDigitFive.text +
          _teOtpDigitSix.text);
    } else {
      print('orpNotValid');
      setState(() {
        isWrongCode = false;
      });
      showAlert("Please enter valid OTP!");
    }
  }

  @override
  void showAlert(String msg) {
    setState(() {
      AppUtil().showAlertNEw(msg, context);
    });
  }
}

class OtpTimer extends StatelessWidget {
  final AnimationController controller;
  double fontSize;
  Color timeColor = Colors.black;

  OtpTimer(this.controller, this.fontSize, this.timeColor);

  String get timerString {
    Duration duration = controller.duration * controller.value;

    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) {
          return new Text(
            timerString,
            style: new TextStyle(
                fontSize: fontSize,
                color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}
