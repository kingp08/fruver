import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fruver/common/widgets/flutter_toast.dart';

import '../../common/models/request.dart';
import '../../common/services/auth_service.dart';
import '../../common/services/firestore_service.dart';
import '../../common/values/constants.dart';
import '../../global.dart';
import '../login/login_screen.dart';
import '../offers/offer_creation_screen.dart'; // This will be the screen for submitting an offer

class FarmerHomeScreen extends StatefulWidget {
  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        title: const Text("All Requests"),
        actions: [
          IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await _authService.signOut();
                Global.storageService.clear();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
              }
          )
        ],
      ),
      body: StreamBuilder<List<Request>>(
        stream: _firestoreService.streamRequests(),  // This should stream all requests
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No requests available.'));
          }
          var requests = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                Request request = requests[index];
                return requestItem(request);
              },
            ),
          );
        },
      ),
    );
  }

  Widget requestItem(Request request) {
    DateTime datetime = request.date.toDate();
    String date = DateFormat('MMM dd yyyy').format(datetime);
    int remainingHour = datetime.difference(DateTime.now()).inHours;
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
          // child: Row(
          //     children: [
          //       Expanded(
          //           child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text('${request.productName} - ${request.quantity} ${request.unit}'),
          //                 Text(date),
          //               ]
          //           )
          //       ),
          //       request.offerStatus.isEmpty && request.status == 'Pending'
          //           ? GestureDetector(
          //         onTap: () {
          //           Navigator.push(context, MaterialPageRoute(builder: (context) => OfferCreationScreen(request: request)));
          //         },
          //         child: Container(
          //           padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          //           decoration: BoxDecoration(
          //             color: const Color(0xFF70B62C),
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //           child: Text("Give Offer", style: TextStyle(color: Colors.white)),
          //         ),
          //       )
          //           : Container(),
          //     ]
          // ),
          child: Column(
            children: [
              Row(
                  children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${request.quantity} ${request.unit} ${request.productName}',
                                  style: const TextStyle(fontSize: 18.0, fontFamily: 'Poppinssb')),
                              Text(date, style: const TextStyle(fontFamily: 'Poppinsm')),
                            ]
                        )
                    ),
                    if (request.status == 'Pending')
                      request.offerStatus.isEmpty && request.status == 'Pending'
                          ? buttonWidget(
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => OfferCreationScreen(request: request))),
                          "Make Offer",
                          Colors.grey.shade300,
                          Colors.black
                      ) : request.offerStatus == 'Accepted'
                          ? Row(
                        children: [
                          buttonWidget(
                                  () {
                                _firestoreService.completeRequest(request.id).then((value) {
                                  toastInfo(msg: "Request completed successfully.");
                                });
                              },
                              "Complete",
                              Colors.grey.shade300,
                              Colors.black
                          ),
                          const SizedBox(width: 8),
                          buttonWidget(
                                  () {
                                _firestoreService.cancelRequest(request.id).then((value) => toastInfo(msg: "Request cancelled successfully."));
                              },
                              "Cancel",
                              Colors.red,
                              Colors.white
                          )
                        ]
                      )
                          : Container(),
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
                          Text('Time Remaining', style: const TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                          const SizedBox(height: 4.0),
                          Text(remainingHour < 0 ? '0' : '$remainingHour'),
                        ]
                    ),
                    Column(
                        children: [
                          Text('Offers', style: const TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                          const SizedBox(height: 4.0),
                          Text('${request.offersReceived}'),
                        ]
                    ),
                    Column(
                        children: [
                          Text('Lowest', style: const TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                          const SizedBox(height: 4.0),
                          Text('\$${request.lowestOffer == double.infinity ? 0.0 : request.lowestOffer}', style: const TextStyle(fontFamily: 'Poppinsm')),
                        ]
                    ),
                    Column(
                        children: [
                          Text('Your Offer', style: const TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                          const SizedBox(height: 4.0),
                          Text('\$${request.offerPrice == double.infinity ? 0.0 : request.offerPrice}', style: const TextStyle(fontFamily: 'Poppinsm')),
                        ]
                    )
                  ]
              )
            ],
          ),
        ),
        if (request.offerStatus.isNotEmpty && request.status == 'Pending')
          Align(
            alignment: Alignment.topRight,
            child: request.offerStatus == 'Not Accepted'
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Text(request.offerStatus, style: const TextStyle(color: Colors.white, fontSize: 11.0, fontFamily: 'Poppinsr')),
            ) : request.offerStatus == 'Accepted'
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: const BoxDecoration(
                color: Color(0xFF70B62C),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Text(request.offerStatus, style: const TextStyle(color: Colors.white, fontSize: 11.0, fontFamily: 'Poppinsr')),
            ) : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: const BoxDecoration(
                color: Colors.amberAccent,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Text(request.offerStatus, style: const TextStyle(color: Colors.black, fontSize: 11.0, fontFamily: 'Poppinsr')),
            ),
          )
        else if (request.status == 'Cancelled')
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Text("Request Cancelled", style: const TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Poppinsr')),
            ),
          )
        else if (request.status == 'Completed')
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF70B62C),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.0),
                  ),
                ),
                child: Text("Request Completed", style: const TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Poppinsr')),
              ),
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
