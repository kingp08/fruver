import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fruver/common/models/request.dart';
import 'package:fruver/common/services/firestore_service.dart';
import 'package:fruver/common/widgets/flutter_toast.dart';
import 'package:fruver/global.dart';

import '../../common/models/offer.dart';
import '../home/farmer_home_screen.dart';

class OfferCreationScreen extends StatefulWidget {
  final Request request;

  const OfferCreationScreen({super.key, required this.request});

  @override
  _OfferCreationScreenState createState() => _OfferCreationScreenState();
}

class _OfferCreationScreenState extends State<OfferCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _openToNegotiate = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _priceController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitOffer() {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show();
      DocumentReference newDocRef = FirebaseFirestore.instance.collection('requests').doc();

      final offer = Offer(
        id: newDocRef.id,
        requestId: widget.request.id,
        farmerId: Global.userModel.uid ?? '',
        farmerName: Global.userModel.name ?? '',
        pickupAddress: _addressController.text,
        phoneNumber: _phoneController.text,
        quantity: widget.request.quantity,
        openToNegotiate: _openToNegotiate,
        price: double.parse(_priceController.text),
        status: 'Pending',
      );

      _firestoreService.createOffer(offer).then((result) {
        EasyLoading.dismiss();
        toastInfo(msg: 'Offer created successfully');
        // Navigator.pop(context);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FarmerHomeScreen()), (route) => false);
      }).catchError((error) {
        EasyLoading.dismiss();
        toastInfo(msg: 'Error creating offer: $error');
        print('Error creating offer: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Offer"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Pickup Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: _openToNegotiate,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _openToNegotiate = newValue!;
                      });
                    },
                  ),
                  const Text('Open to Negotiate'),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF70B62C),
                ),
                child: const Text('Submit Offer', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}