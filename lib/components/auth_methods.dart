import 'package:flutter_chat/components/database_methods.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final GoogleSignIn googleSignIn=GoogleSignIn();
  DatabaseMethods dbMethods=new DatabaseMethods();

  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount=await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication=await googleSignInAccount.authentication;
    final AuthCredential credential=GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken
    );
    final UserCredential authResult=await _auth.signInWithCredential(credential);
    final User user=authResult.user;
    if(user!=null) {
      assert(user.uid!=null);
      assert(user.email!=null);
      assert(user.displayName!=null);
      assert(!user.isAnonymous);
      final User currentUser=_auth.currentUser;
      assert(user.uid==currentUser.uid);
      return user;
    }
    return null;
  }

  Future isCurrentUser() async {
    User currentUser=_auth.currentUser;
    return currentUser;
  }

  Future<void> googleSignOut() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // await preferences.clear();
    await _auth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    print('User Signed Out');
  }

  Future resetPassword(String email) async{
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    }
    catch(e) {print(e.toString());}
  }

  /*Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential=await _auth.signInWithEmailAndPassword(email: email, password: password);
      User firebaseUser=credential.user;
      return _userFromFirebaseUser(firebaseUser);
    }
    catch(e) {print(e.toString());}
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential=await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User firebaseUser=credential.user;
      return _userFromFirebaseUser(firebaseUser);
    }
    catch(e) {print(e.toString());}
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    }
    catch(e) {print(e.toString());}
  }*/

}