import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's ID
  Future<String?> getCurrentUserId() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }
}
