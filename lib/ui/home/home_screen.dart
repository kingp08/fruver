import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fruver/common/services/auth_service.dart';
import 'package:fruver/common/values/constants.dart';
import 'package:fruver/global.dart';
import 'package:fruver/main.dart';
import 'package:fruver/ui/offers/offers_screen.dart';
import 'package:fruver/ui/report/create_report_screen.dart';

import '../../common/models/request.dart';
import '../../common/services/firestore_service.dart';
import '../login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Request For Quotation'),
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
        stream: _firestoreService.streamUserRequests(Global.userModel.uid ?? ''),
        builder: (context, AsyncSnapshot<List<Request>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No requests found.'));
          }
          var requests = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                var request = requests[index];

                return requestItem(request);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RequestCreationScreen()));
        },
        backgroundColor: Color(0xFF70B62C),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  requestItem(Request request) {
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
                    request.status == 'Pending' ? buttonWidget(
                          () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => OffersScreen(request: request)));
                          },
                      "View Offers",
                      Colors.grey.shade300,
                      Colors.black
                    ) : Container(),
                    request.status == 'Pending' ? const SizedBox(width: 8) : Container(),
                    request.status == 'Pending' ? buttonWidget(
                            () {
                              _firestoreService.cancelRequest(request.id);
                        },
                        "Cancel Request",
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
                      Text('Time Remaining', style: const TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                      const SizedBox(height: 4.0),
                      Text('$remainingHour hours'),
                    ]
                  ),
                  Column(
                      children: [
                        Text('Offers Received', style: const TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                        const SizedBox(height: 4.0),
                        Text('${request.offersReceived}'),
                      ]
                  ),
                  Column(
                      children: [
                        Text('Lowest Offer', style: const TextStyle(fontFamily: 'Poppinsm', fontSize: 12.0)),
                        const SizedBox(height: 4.0),
                        Text('\$${request.lowestOffer == double.infinity ? 0.0 : request.lowestOffer}', style: const TextStyle(fontFamily: 'Poppinsm')),
                      ]
                  )
                ]
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: request.status == 'Cancelled'
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Text(request.status, style: const TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Poppinsr')),
          ) : request.status == 'Completed'
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: const BoxDecoration(
              color: Color(0xFF70B62C),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Text(request.status, style: const TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Poppinsr')),
          ) : request.acceptedOfferId.isNotEmpty
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: const BoxDecoration(
              color: Color(0xFF70B62C),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.0),
              ),
            ),
            child: const Text("Offer Accepted", style: const TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Poppinsr')),
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
