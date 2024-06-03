import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fruver/global.dart';

import '../models/offer.dart';
import '../models/request.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Request>> streamUserRequests(String userId) {
    try {
      return _db.collection('requests')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .asyncMap((snapshot) async {
        List<Request> requests = [];
        for (var doc in snapshot.docs) {
          var request = Request.fromFirestore(doc);

          // Fetch offers for each request
          var offersSnapshot = await _db.collection('offers')
              .where('requestId', isEqualTo: request.id)
              .get();

          var offers = offersSnapshot.docs.map((doc) => doc.data()).toList();
          request.offersReceived = offers.length;
          request.lowestOffer = offers.fold(double.infinity, (prev, elem) => elem['price'] < prev ? elem['price'] : prev);

          requests.add(request);
        }
        return requests;
      });
    } catch (e) {
      print(e);
      return Stream.value([]);
    }

  }

  // Stream<List<Request>> streamRequests() {
  //   return _db.collection('requests').snapshots().map((snapshot) =>
  //       snapshot.docs.map((doc) => Request.fromFirestore(doc)).toList());
  // }
  Stream<List<Request>> streamRequests() {
    return _db.collection('requests')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Request> requests = [];
      for (var doc in snapshot.docs) {
        var request = Request.fromFirestore(doc);
        // Fetch offers for each request
        var offersSnapshot = await _db.collection('offers')
            .where('requestId', isEqualTo: request.id)
            .get();

        var offers = offersSnapshot.docs.map((doc) => doc.data()).toList();
        request.offersReceived = offers.length;
        request.lowestOffer = offers.fold(double.infinity, (prev, elem) => elem['price'] < prev ? elem['price'] : prev);

        for (var offer in offers) {
          if (offer['farmerId'] == Global.userModel.uid) {
            request.offerStatus = offer['status'];
            request.offerPrice = offer['price'];
          }
        }

        // Fetch offers for the request by the current user
        // var offersSnapshot = await _db.collection('offers')
        //     .where('requestId', isEqualTo: request.id)
        //     .where('farmerId', isEqualTo: Global.userModel.uid)
        //     .get();
        //
        // var offers = offersSnapshot.docs.map((doc) => Offer.fromFirestore(doc)).toList();
        // if (offers.isNotEmpty) {
        //   var offer = offers.first;
        //   request.offerStatus = offer.status;
        //   request.offerPrice = offer.price;
        // }

        requests.add(request);
      }
      return requests;
    });
  }

  Future<void> createRequest(Request request) async {
    await _db.collection('requests').doc(request.id).set(request.toFirestore());
  }

  Future<void> cancelRequest(String requestId) async {
    DocumentReference offerRef = _db.collection('requests').doc(requestId);
    await offerRef.update({'status': 'Cancelled'});
  }

  Stream<List<Offer>> streamOffers(String requestId) {
    return _db.collection('offers')
        .where('requestId', isEqualTo: requestId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Offer.fromFirestore(doc)).toList());
  }

  // Accept an offer and update other offers' statuses
  Future<void> acceptOffer(String requestId, Offer acceptedOffer) async {
    EasyLoading.show();
    WriteBatch batch = _db.batch();

    // Update the status of the accepted offer to "accepted"
    DocumentReference offerRef = _db.collection('offers').doc(acceptedOffer.id);
    batch.update(offerRef, {'status': 'Accepted'});

    // Assign the accepted offer's ID to the request
    DocumentReference requestRef = _db.collection('requests').doc(requestId);
    batch.update(requestRef, {'acceptedOfferId': acceptedOffer.id});

    // Update the status of all other offers to "cancelled"
    QuerySnapshot otherOffersSnapshot = await _db
        .collection('offers')
        .where('requestId', isEqualTo: requestId)
        .where('status', isEqualTo: 'Pending')
        .get();

    for (DocumentSnapshot doc in otherOffersSnapshot.docs) {
      if (doc.id != acceptedOffer.id) {
        batch.update(doc.reference, {'status': 'Not Accepted'});
      }
    }

    await batch.commit();
    EasyLoading.dismiss();
  }

  // Reject an offer
  Future<void> rejectOffer(Offer rejectedOffer) async {
    DocumentReference offerRef = _db.collection('offers').doc(rejectedOffer.id);
    await offerRef.update({'status': 'Not Accepted'});
  }

  Future<void> createOffer(Offer offer) async {
    await _db.collection('offers').doc(offer.id).set(offer.toFirestore());
  }

  Future<void> completeRequest(String id) async {
    await _db.collection('requests').doc(id).update({'status': 'Completed'});
  }
}
