import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fruver/ui/home/farmer_home_screen.dart';

import 'global.dart';
import 'ui/home/home_screen.dart';
import 'ui/login/login_screen.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

Future<void> main() async {
  await Global.init();
  runApp(const MyApp());
  // runZonedGuarded(() => runApp(const MyApp()), (error, stack) {
  //   print(stack);
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fruver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppinsl',
        appBarTheme: const AppBarTheme(
          color: Color(0xFF70B62C),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20.0),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: Global.storageService.isLoggedIn() ? Global.userModel.userType == 'Farmer' ? FarmerHomeScreen() : const HomeScreen() : LoginScreen(),
      builder: EasyLoading.init(),
    );
  }
}
