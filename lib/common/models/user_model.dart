import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String? name;
  final String? userType;
  final String? email;
  final String? number;

  UserModel({
    this.uid,
    this.name,
    this.userType,
    this.email,
    this.number,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      userType: json['userType'],
      email: json['email'],
      number: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'userType': userType,
      'email': email,
      'phoneNumber': number,
    };
  }

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserModel(
      uid: data?['uid'],
      name: data?['name'],
      userType: data?['userType'],
      email: data?['email'],
      number: data?['phoneNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (uid != null) "uid": uid,
      if (name != null) "name": name,
      if (userType != null) "userType": userType,
      if (email != null) "email": email,
      if (number != null) "phoneNumber": number,
    };
  }
}