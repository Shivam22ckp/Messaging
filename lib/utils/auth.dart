import 'package:firebase_auth/firebase_auth.dart';
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<bool> isLogged() async {
    try {
      final User user = await _firebaseAuth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }
}

