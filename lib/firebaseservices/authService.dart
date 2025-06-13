import 'package:firebase_auth/firebase_auth.dart';

class Authservice {
  
  static void login(String email,String pass) async {
      print("object");
      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: email,
              password: pass,
            );
        print(userCredential);
      } catch (e) {
        print("Unable to Login $e");
      }
    }
}