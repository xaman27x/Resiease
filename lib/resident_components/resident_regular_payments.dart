import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/auth.dart';
import 'package:http/http.dart' as http;
import './env.dart' as env;

String residenceID = '';
String orderID = '';
String requestID = '';
final _razorpay = Razorpay();

Future<void> _openCheckout(String orderid, int amount, String interval) async {
  var options = {
    'key': env.razorpayKey,
    'amount': amount * 100,
    'name': 'ResiEase',
    'order_id': orderid,
    'description': '$interval Maintenance Fees',
    'timeout': 300,
    'prefill': {'contact': '8483811246', 'email': 'amorghade.10@gmail.com'}
  };
  try {
    _razorpay.open(options);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  } catch (e) {
    debugPrint('ERROR IS: ${e.toString()}');
  }
}

void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  try {
    final userId = Auth().currentUser?.uid;

    if (userId == null) {
      debugPrint('User is not logged in.');
      return;
    }
    if (requestID.isEmpty) {
      debugPrint('RequestID is not defined.');
      return;
    }
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('ResidencyFees')
        .where('RequestID', isEqualTo: requestID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      debugPrint('Document ID: ${documentSnapshot.id}');
      debugPrint('Residents before update: ${documentSnapshot['Residents']}');

      await FirebaseFirestore.instance
          .collection('ResidencyFees')
          .doc(documentSnapshot.id)
          .update({
        'Residents': FieldValue.arrayRemove([userId])
      });
      debugPrint('User ID $userId removed from Residents array successfully');
    } else {
      debugPrint('No document found with the specified RequestID');
    }
  } catch (e) {
    debugPrint('An error occurred: $e');
  }
}

void _handlePaymentError(PaymentFailureResponse response) {
  debugPrint('Payment failed: ${response.message}');
}

Future<String> createOrder(String name, int amount) async {
  final int finalAmount = amount * 100;
  final Map<String, dynamic> payload = {
    "name": name,
    "amount": finalAmount,
    "currency": "INR",
    "receipt": "X",
    "notes": {"key1": "X", "key2": "X"}
  };

  try {
    final Uri url = Uri.parse(
        'https://ksjbsggcehhlihtcvsur.supabase.co/functions/v1/createOrder');

    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": "true",
        'Accept': '*/*',
        "Access-Control-Allow-Methods": 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers':
            'Origin, Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token, locale',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      debugPrint('Order created: ${responseData['orderResponse']['id']}');
      orderID = responseData['orderResponse']['id'];
      return responseData['orderResponse']['id'];
    } else {
      debugPrint('Failed to create order: ${response.body}');
      return '';
    }
  } catch (e) {
    debugPrint('An error occurred: $e');
    return '';
  }
}

class ResidentFeesPaymentPage extends StatefulWidget {
  const ResidentFeesPaymentPage({super.key});

  @override
  State<ResidentFeesPaymentPage> createState() =>
      _ResidentFeesPaymentPageState();
}

class _ResidentFeesPaymentPageState extends State<ResidentFeesPaymentPage> {
  late Stream<QuerySnapshot> _feesDetails = const Stream.empty();

  @override
  void initState() {
    super.initState();
    retrieveResID();
  }

  Future<void> retrieveResID() async {
    String userId = Auth().currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Residents')
        .where('UserID', isEqualTo: userId)
        .get();
    final data = querySnapshot.docs.first;
    residenceID = data['ResidenceID'];

    setState(
      () {
        _feesDetails = FirebaseFirestore.instance
            .collection(
              'ResidencyFees',
            )
            .where(
              'ResidenceID',
              isEqualTo: residenceID,
            )
            .where(
              'Residents',
              arrayContains: userId,
            )
            .snapshots();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Image.asset(
          'images/title_2.png',
          scale: 3.8,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: FloatingActionButton(
          onPressed: () => {
            Navigator.pop(context),
          },
          elevation: 0.0,
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 216, 196, 13),
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
        child: Center(
          child: StreamBuilder(
            stream: _feesDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occurred. Please try again later.'),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No fees details available.'),
                );
              } else {
                return Column(
                  children: [
                    const SizedBox(height: 30),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data = snapshot.data!.docs[index]
                              .data()! as Map<String, dynamic>;
                          return ListTile(
                            leading: const Icon(
                              Icons.currency_rupee_rounded,
                              color: Color.fromARGB(255, 227, 42, 29),
                            ),
                            title: Text(
                              'FEES PAYMENT\nAmount: ${data['Amount']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Interval: ${data['Interval']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 44, 44, 44),
                              ),
                              onPressed: () {
                                requestID = data['RequestID'];
                                debugPrint(requestID);
                                createOrder(
                                  'ORDERID',
                                  data['Amount'],
                                ).then((orderId) {
                                  _openCheckout(
                                    orderId,
                                    data['Amount'],
                                    data['Interval'],
                                  );
                                });
                              },
                              child: const Text(
                                'PAY NOW',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 200, 210, 15),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
