import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  final String id;
  final String requestId;
  final String farmerId;
  final String farmerName;
  final String pickupAddress;
  final String phoneNumber;
  final int quantity;
  final bool openToNegotiate;
  final double price;
  String status;

  Offer({
    required this.id,
    required this.requestId,
    required this.farmerId,
    required this.farmerName,
    required this.pickupAddress,
    required this.phoneNumber,
    required this.quantity,
    required this.openToNegotiate,
    required this.price,
    this.status = 'Pending', // Default status
  });

  factory Offer.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Offer(
      id: doc.id,
      requestId: data['requestId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? '',
      pickupAddress: data['pickupAddress'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      quantity: data['quantity'] != null ? data['quantity'].toInt() : 0,
      openToNegotiate: data['openToNegotiate'] ?? false,
      price: data['price'] ?? 0.0,
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requestId': requestId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'pickupAddress': pickupAddress,
      'phoneNumber': phoneNumber,
      'quantity': quantity,
      'openToNegotiate': openToNegotiate,
      'price': price,
      'status': status,
    };
  }
}