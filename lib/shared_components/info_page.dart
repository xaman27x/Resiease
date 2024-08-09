import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/auth.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late Stream<QuerySnapshot> _infoStream = const Stream.empty();

  Future<void> _initializeStream() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Admins')
        .where('UserID', isEqualTo: Auth().currentUser!.uid)
        .get();

    bool isAdmin = querySnapshot.docs.isNotEmpty;

    setState(() {
      _infoStream = isAdmin
          ? FirebaseFirestore.instance
              .collection('Admins')
              .where('UserID', isEqualTo: Auth().currentUser!.uid)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('Residents')
              .where('UserID', isEqualTo: Auth().currentUser!.uid)
              .snapshots();
    });
  }

  @override
  void initState() {
    _initializeStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("images/title_2.png", scale: 3.8),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SizedBox.expand(
        child: Container(
          color: const Color.fromARGB(255, 161, 151, 108),
          child: StreamBuilder<QuerySnapshot>(
            stream: _infoStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var userData =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Name: ${userData['Name']} ${userData['Last Name']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Email ID: ${userData['Email ID'] ?? userData['EmailID']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Residence ID: ${userData['Residence ID'] ?? userData['ResidenceID']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        if (userData.containsKey('Designation')) ...[
                          Text(
                            'Designation: ${userData['Designation']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ] else ...[
                          Text(
                            'Age: ${userData['Age']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
