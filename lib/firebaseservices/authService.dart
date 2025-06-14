import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with email and password
  static Future<User?> login(String email, String pass) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print(e);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sign up with email and password
  static Future<User?> signup(String email, String pass) async {
     
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuth Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("❌ General Signup Error: $e");
      return null;
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("✅ User signed out from all providers.");
    } catch (e) {
      print("❌ Sign-out error: $e");
    }
  }
}
