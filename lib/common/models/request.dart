import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Request {
  String id;
  String userId;
  String acceptedOfferId;
  String productName;
  int quantity;
  String unit;
  Timestamp date;
  int offersReceived;
  double lowestOffer;
  String status;
  String offerStatus;
  double offerPrice;

  Request({
    required this.id,
    required this.userId,
    required this.acceptedOfferId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.date,
    required this.offersReceived,
    required this.lowestOffer,
    this.status = 'Pending',
    this.offerStatus = '',
    this.offerPrice = 0.0,
  });

  factory Request.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Request(
      id: doc.id,
      userId: data['userId'] ?? '',
      acceptedOfferId: data['acceptedOfferId'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] != null ? data['quantity'].toInt() : 0,
      unit: data['unit'] ?? '',
      date: data['date'] ?? 0,
      offersReceived: data['offersReceived'] ?? 0,
      lowestOffer: data['lowestOffer'] ?? 0.0,
      status: data['status'] ?? 'Pending',
      offerStatus: '',
      offerPrice: 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'acceptedOfferId': acceptedOfferId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'date': date,
      'offersReceived': offersReceived,
      'lowestOffer': lowestOffer,
      'status': status,
    };
  }
}