import 'package:flutter/material.dart';
import 'package:fruver/ui/home/farmer_home_screen.dart';

import '../../common/services/auth_service.dart';
import '../home/home_screen.dart';
import '../signup/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                var user = await _authService.signIn(
                  _emailController.text,
                  _passwordController.text,
                );
                if (user != null) {
                  if (user.userType == 'Farmer') {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FarmerHomeScreen()), (route) => false);
                  } else {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                  }
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                // throw Exception();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: const Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}