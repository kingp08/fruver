import 'package:flutter/material.dart';
import 'package:fruver/ui/home/farmer_home_screen.dart';

import '../../common/services/auth_service.dart';
import '../../common/widgets/flutter_toast.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneNumberController = TextEditingController();

  String _selectedType = 'Customer';

  List<String> _userTypes = ['Customer', 'Farmer'];

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            DropdownButtonFormField(
              value: _selectedType,
              items: _userTypes.map((String unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'User Type',
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty) {
                  toastInfo(msg: "You need to fill user name");
                  return;
                }
                if (_emailController.text.isEmpty) {
                  toastInfo(msg: "You need to fill email address");
                  return;
                }
                if (_phoneNumberController.text.isEmpty) {
                  toastInfo(msg: "You need to fill number");
                  return;
                }
                if (_passwordController.text.isEmpty) {
                  toastInfo(msg: "You need to fill password");
                  return;
                }
                var userCredential = await _authService.signUp(
                  email: _emailController.text,
                  password: _passwordController.text,
                  name: _nameController.text,
                  userType: _selectedType,
                  phoneNumber: _phoneNumberController.text,
                );
                if (userCredential != null) {
                  if (_selectedType == 'Farmer') {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FarmerHomeScreen()), (route) => false);
                  } else {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                  }
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
