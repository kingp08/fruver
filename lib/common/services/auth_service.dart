import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fruver/global.dart';
import 'package:fruver/main.dart';

import '../models/user_model.dart';
import '../values/constants.dart';
import '../widgets/flutter_toast.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    required String phoneNumber,
  }) async {
    EasyLoading.show();
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);

        await _firestore.collection('users').doc(result.user?.uid).set({
          'uid': user.uid,
          'name': name,
          'userType': userType,
          'phoneNumber': phoneNumber,
          'email': email,
        });
        DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(user.uid).get();
        UserModel userModel = UserModel.fromFirestore(userDoc);

        Global.userModel = userModel;

        Global.storageService.setBool(AppConstants.IS_LOGGED_IN, true);
        String jsonString = jsonEncode(userModel.toJson());
        Global.storageService.setString(AppConstants.STORAGE_USER_PROFILE_KEY, jsonString);
        EasyLoading.dismiss();
        return result;
      } else {
        EasyLoading.dismiss();
        toastInfo(msg: "Currently, you are not a user of this app");
        return null;
      }
    } on FirebaseAuthException catch (exception) {
      EasyLoading.dismiss();
      if (exception.code == 'weak-password') {
        toastInfo(msg: "The password provided is too weak.");
        return null;
      } else if (exception.code == 'email-already-in-use') {
        toastInfo(msg: "The account already exists for that email.");
        return null;
      } else {
        toastInfo(msg: "An error occurred. Please try again later.");
        return null;
      }
    } catch (error) {
      print(error);
      EasyLoading.dismiss();
      toastInfo(msg: "An error occurred. Please try again later.");
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    EasyLoading.show();
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(user.uid).get();

        UserModel userModel = UserModel.fromFirestore(userDoc);

        Global.userModel = userModel;

        Global.storageService.setBool(AppConstants.IS_LOGGED_IN, true);
        String jsonString = jsonEncode(userModel.toJson());
        Global.storageService.setString(AppConstants.STORAGE_USER_PROFILE_KEY, jsonString);
        EasyLoading.dismiss();
        return userModel;
      } else {
        toastInfo(msg: "No user found for that email and password.");
        EasyLoading.dismiss();
        return null;
      }
    } on FirebaseAuthException catch (exception) {
      EasyLoading.dismiss();
      if (exception.code == 'user-not-found') {
        toastInfo(msg: "No user found for that email.");
      } else if (exception.code == 'wrong-password') {
        toastInfo(msg: "Wrong password provided for that user.");
      } else {
        toastInfo(msg: "An error occurred. Please try again later.");
      }
      return null;
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
      toastInfo(msg: "An unexpected error occurred. Please try again later.");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}