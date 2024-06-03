import 'package:flutter/material.dart';
import 'package:fruver/common/models/request.dart';
import 'package:fruver/common/widgets/flutter_toast.dart';

import '../../common/models/offer.dart';
import '../../common/services/firestore_service.dart';
import '../home/home_screen.dart';

class OffersScreen extends StatefulWidget {
  final Request request;

  OffersScreen({required this.request});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Offers'),
      ),
      body: StreamBuilder<List<Offer>>(
        stream: _firestoreService.streamOffers(widget.request.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No offers yet.'));
          }

          List<Offer> offers = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                Offer offer = offers[index];
                return offerItem(offer);
              },
            ),
          );
        },
      ),
    );
  }

  offerItem(Offer offer) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                )
              ]
          ),
          child: Column(
            children: [
              Row(
                  children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offer.farmerName, style: const TextStyle(fontFamily: 'Poppinssb', fontSize: 18.0)),
                              Text('Pickup From: ${offer.pickupAddress}', style: const TextStyle(fontFamily: 'Poppinsr')),
                              Text('Phone Number: ${offer.phoneNumber}', style: const TextStyle(fontFamily: 'Poppinsr')),
                            ]
                        )
                    ),
                    widget.request.acceptedOfferId.isEmpty ? buttonWidget(
                            () async {
                              await _firestoreService.acceptOffer(widget.request.id, offer).then((value) {
                                toastInfo(msg: "Offer accepted successfully.");
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                              });
                        },
                        "Accept Offer",
                        Colors.grey.shade300,
                        Colors.black
                    ) : Container(),
                    widget.request.acceptedOfferId.isEmpty ? const SizedBox(width: 8) : Container(),
                    widget.request.acceptedOfferId.isEmpty ? buttonWidget(
                            () {
                              _firestoreService.rejectOffer(offer).then((value) => toastInfo(msg: "Offer rejected successfully."));
                            },
                        "Reject Offer",
                        Colors.red,
                        Colors.white
                    ) : Container(),
                  ]
              ),
              const SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey.shade200,
                // height: 5,
              ),
              const SizedBox(height: 8),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        children: [
                          const Text('Quantity', style: TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                          const SizedBox(height: 4.0),
                          Text('${offer.quantity} ${widget.request.unit}'),
                        ]
                    ),
                    Column(
                        children: [
                          const Text('Open To Negotiate', style: TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                          const SizedBox(height: 4.0),
                          Text('${offer.openToNegotiate ? 'Yes' : 'No'}'),
                        ]
                    ),
                    Column(
                        children: [
                          const Text('Offer', style: TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                          const SizedBox(height: 4.0),
                          Text('\$${offer.price}', style: const TextStyle(fontFamily: 'Poppinsm')),
                        ]
                    )
                  ]
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: offer.status == 'Not Accepted'
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Text(offer.status, style: const TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Poppinsr')),
          ) : offer.status == 'Accepted'
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: const BoxDecoration(
              color: Color(0xFF70B62C),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Text(offer.status, style: const TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Poppinsr')),
          ) : const SizedBox.shrink(),
        )
      ],
    );
  }

  buttonWidget(Function()? onTap, String text, Color color, Color textColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(text, style: TextStyle(color: textColor, fontSize: 10.0)),
      ),
    );
  }
}