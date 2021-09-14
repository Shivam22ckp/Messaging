import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseEmailVerificationListener {

  onEmailUserVerified(User currentUser);

  onError(String message);
}
