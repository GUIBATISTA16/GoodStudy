import 'dart:async';
import 'package:projeto_goodstudy/objects/explicador.dart';
import 'package:projeto_goodstudy/objects/explicando.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_goodstudy/services/userdatabase.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  FUser? fuserFromUser (User user){
    return user != null ? FUser(uid: user.uid,isAnonymous: user.isAnonymous) : null;
  }

  Future signInEmailPassword(String email, String password) async {
    try{
      UserCredential result = await auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return fuserFromUser(user!);
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return null;
      } else if (e.code == 'wrong-password') {
        return null;
      }
    }
  }

  Future registerEmailPassword(String email, String password, Explicador? explicador, Explicando? explicando) async {
    try{
      UserCredential result = await auth.createUserWithEmailAndPassword(email: email, password: password);
      await auth.signOut();
      User? user = result.user;

      if(result != null){
        if(explicador != null && explicando == null){
          await UserDatabaseService(uid: user!.uid).updateExplicadorData(explicador);
        }
        else if(explicador == null && explicando != null){
          await UserDatabaseService(uid: user!.uid).updateExplicandoData(explicando);
        }
      }


      return fuserFromUser(user!);
    }
    catch(e){
      return null;
    }
  }

  Future signInAnon() async {
    try{
      UserCredential result = await auth.signInAnonymously();
      User? user = result.user;
      return fuserFromUser(user!);
    }
    catch(e){
      return null;
    }
  }


  Future signOut() async {
    try{
      return await auth.signOut();
    }
    catch(e){
      return null;
    }
  }

  Stream<User?>get streamLogin{
    return auth.authStateChanges();
  }

}