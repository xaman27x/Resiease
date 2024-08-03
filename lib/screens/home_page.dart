import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resiease/models/auth.dart';
import 'package:resiease/resident_components/resident_complaints.dart';
import 'package:resiease/resident_components/resident_meetings.dart';
import 'package:resiease/resident_components/resident_members.dart';
import 'package:resiease/resident_components/resident_regular_payments.dart';
import 'package:resiease/admin_components/admin_complaints.dart';
import 'package:resiease/admin_components/admin_payments.dart';
import 'package:resiease/admin_components/admin_members.dart';
import 'package:resiease/admin_components/admin_meetings.dart';
import 'package:resiease/resident_components/resident_special_payments.dart';
import '../admin_components/admin_alerts.dart';
import 'introduction_page.dart';

class HomeGlobals {
  static String residenceID = '';
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset('images/title_2.png', scale: 3.8),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[100],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IntroPage(),
                ),
              );
              Auth().signOut();
            },
            child: const Text(
              'SIGN OUT',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            width: 30,
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
      ),
      bottomNavigationBar: Container(
        color: Colors.amber[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminAlertsPage(),
                  ),
                );
              },
              color: Colors.amber[100],
              icon: const Icon(
                Icons.add_alert_sharp,
                color: Colors.orange,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminMeetingsPage(),
                  ),
                );
              },
              color: Colors.amber[100],
              icon: const Icon(
                Icons.more_time,
                color: Color.fromARGB(255, 11, 157, 145),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPaymentsPage(),
                  ),
                );
              },
              color: Colors.amber[100],
              icon: const Icon(
                Icons.currency_exchange,
                color: Color.fromARGB(255, 16, 74, 121),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminComplaintPage(),
                  ),
                );
              },
              color: Colors.amber[100],
              icon: const Icon(
                Icons.mark_email_unread_outlined,
                color: Colors.red,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminMembersPage(),
                  ),
                );
              },
              color: Colors.amber[100],
              icon: const Icon(
                Icons.people_alt,
                color: Color.fromARGB(255, 9, 81, 141),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeesTreePage extends StatelessWidget {
  const FeesTreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/title_2.png', scale: 3.8),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[200],
                ),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResidentFeesPaymentPage(),
                    ),
                  )
                },
                child: const Text(
                  "REGULAR FEES ALERT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[200],
                ),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResidentSpecialPaymentPage(),
                    ),
                  )
                },
                child: const Text(
                  "SPECIAL FEES ALERT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResidentHomePage extends StatefulWidget {
  const ResidentHomePage({super.key});

  @override
  State<ResidentHomePage> createState() => _ResidentHomePageState();
}

class _ResidentHomePageState extends State<ResidentHomePage> {
  late Stream<QuerySnapshot> _alertsStream = const Stream.empty();

  Future<void> _fetchResidenceID() async {
    final uid = Auth().currentUser!.uid;
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Residents')
        .where('UserID', isEqualTo: uid)
        .get();
    final data = querySnapshot.docs.first;
    HomeGlobals.residenceID = data['ResidenceID'];
  }

  Future<void> _initializeStream() async {
    await _fetchResidenceID();
    _alertsStream = FirebaseFirestore.instance
        .collection('ResidencyAlerts')
        .where('ResidenceID', isEqualTo: HomeGlobals.residenceID)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _fetchResidenceID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'images/title_2.png',
          scale: 3.8,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[200],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IntroPage(),
                ),
              );
              Auth().signOut();
            },
            child: const Text(
              'SIGN OUT',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            width: 30,
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
      ),
      bottomNavigationBar: Container(
        color: Colors.amber[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FloatingActionButton(
              elevation: 0,
              heroTag: 'Meeting_Resident',
              backgroundColor: Colors.amber[100],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResidentMeetingsPage(),
                  ),
                );
              },
              child: const Icon(Icons.access_time,
                  color: Color.fromARGB(255, 11, 157, 145)),
            ),
            FloatingActionButton(
              elevation: 0.0,
              heroTag: 'Payments_Resident',
              backgroundColor: Colors.amber[100],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeesTreePage(),
                  ),
                );
              },
              child: const Icon(
                Icons.currency_exchange_rounded,
                color: Color.fromARGB(255, 16, 74, 121),
              ),
            ),
            FloatingActionButton(
              elevation: 0.0,
              heroTag: 'Complaints_Resident',
              backgroundColor: Colors.amber[100],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResidentComplaintPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.outgoing_mail,
                color: Colors.red,
              ),
            ),
            FloatingActionButton(
              elevation: 0.0,
              heroTag: 'Members_Resident',
              backgroundColor: Colors.amber[100],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResidentMembersPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.people_alt,
                color: Color.fromARGB(255, 9, 81, 141),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
