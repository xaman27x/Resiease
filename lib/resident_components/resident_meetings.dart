// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/auth.dart';

class ResidentMeetingsPage extends StatefulWidget {
  const ResidentMeetingsPage({super.key});

  @override
  State<ResidentMeetingsPage> createState() => _ResidentMeetingsPageState();
}

class _ResidentMeetingsPageState extends State<ResidentMeetingsPage> {
  late Stream<QuerySnapshot> _meetingsStream = const Stream.empty();

  Future<void> _fetchResidenceID() async {
    final uid = Auth().currentUser!.uid;
    final QuerySnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Residents')
        .where('UserID', isEqualTo: uid)
        .get();
    final data = docSnapshot.docs.first;
    setState(() {
      _meetingsStream = FirebaseFirestore.instance
          .collection('ResidencyMeetings')
          .where('ResidenceID', isEqualTo: data['ResidenceID'])
          .snapshots();
    });
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
        backgroundColor: Colors.white,
        title: Image.asset(
          'images/title_2.png',
          scale: 3.8,
        ),
        centerTitle: true,
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
            children: [
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _meetingsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('SOME ERROR OCCURRED!'),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('NO SCHEDULED MEETINGS FOUND!'),
                      );
                    } else {
                      final length = snapshot.data!.docs.length;
                      return ListView.builder(
                        itemCount: length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data = snapshot.data!.docs[index]
                              .data()! as Map<String, dynamic>;
                          return ListTile(
                            leading: const Icon(
                              Icons.person_pin_outlined,
                              color: Colors.blue,
                            ),
                            title: Text(
                              '${'TOPIC: ' + data['Topic']}\n' 'Venue: ' +
                                  data['Venue'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Date- ' + data['Date'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
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
