import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:fruver/common/widgets/flutter_toast.dart';
import 'package:fruver/main.dart';

import '../../common/models/request.dart';
import '../../common/services/firestore_service.dart';
import '../../global.dart'; // For date formatting

class RequestCreationScreen extends StatefulWidget {
  @override
  _RequestCreationScreenState createState() => _RequestCreationScreenState();
}

class _RequestCreationScreenState extends State<RequestCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  String _selectedProduct = 'Onions'; // Default product
  List<String> _products = ['Onions', 'Potatoes', 'Carrots', 'Broccoli', 'Cucumber', 'Tomato', 'Garlic']; // Add more products as needed
  String _selectedUnit = 'KG';
  List<String> _units = ['KG', 'LB'];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show();
      DocumentReference newDocRef = FirebaseFirestore.instance.collection('requests').doc();

      final requestDate = combine(_selectedDate, _selectedTime);

      final request = Request(
        id: newDocRef.id,
        userId: Global.userModel.uid ?? '',
        acceptedOfferId: '',
        productName: _selectedProduct,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        unit: _selectedUnit,
        date: Timestamp.fromDate(requestDate),
        offersReceived: 0,
        lowestOffer: 0.0,
      );
      // Use FirestoreService to save the request
      await _firestoreService.createRequest(request).then((value) => toastInfo(msg: 'Your request has been submitted successfully!'));
      EasyLoading.dismiss();
      Navigator.of(context).pop();
    }
  }

  DateTime combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Request'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField(
                value: _selectedProduct,
                items: _products.map((String product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(product),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProduct = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                ),
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField(
                value: _selectedUnit,
                items: _units.map((String unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnit = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Unit',
                ),
              ),
              ListTile(
                title: const Text('Select Date'),
                subtitle: Text(DateFormat.yMd().format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: const Text('Select Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF70B62C),
                ),
                child: const Text('Submit Request', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}