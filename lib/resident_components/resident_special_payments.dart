import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './env.dart' as env;

final _razorpay = Razorpay();
String orderID = '';
String requestID = '';

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

class ResidentSpecialPaymentPage extends StatefulWidget {
  const ResidentSpecialPaymentPage({super.key});

  @override
  State<ResidentSpecialPaymentPage> createState() =>
      _ResidentSpecialPaymentPageState();
}

class _ResidentSpecialPaymentPageState
    extends State<ResidentSpecialPaymentPage> {
  late Stream<QuerySnapshot> _feeDetails = const Stream.empty();

  Future<void> _initializeStream() async {
    setState(() {
      _feeDetails = FirebaseFirestore.instance
          .collection('ResidencySpecialFees')
          .where('UserID', isEqualTo: Auth().currentUser!.uid)
          .snapshots();
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "images/title_2.png",
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _feeDetails,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error while fetching data!');
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator.adaptive());
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Text("No Special Fee Records Found!");
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return Material(
                              type: MaterialType.card,
                              child: ListTile(
                                leading: Icon(Icons.currency_rupee,
                                    color: Colors.amber[700]),
                                title: Text("Reason: ${data['Reason']}"),
                                subtitle: Text('AMOUNT: ${data['Amount']}'),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber[200]),
                                  onPressed: () {
                                    requestID = data['RequestID'];
                                    createOrder(data['Reason'], data['Amount'])
                                        .then((orderID) {
                                      _openCheckout(orderID, data['Amount'],
                                          data['Reason']);
                                    });
                                  },
                                  child: const Text(
                                    "PAY NOW!",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
