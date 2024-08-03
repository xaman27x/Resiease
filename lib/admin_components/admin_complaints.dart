import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resiease/models/auth.dart';

class AdminComplaintPage extends StatefulWidget {
  const AdminComplaintPage({super.key});

  @override
  State<AdminComplaintPage> createState() => _AdminComplaintPageState();
}

Future<String> _retrieveResID() async {
  final String userId = Auth().currentUser!.uid;
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Admins')
      .where('UserID', isEqualTo: userId)
      .get();

  final data = querySnapshot.docs.first;
  return data['Residence ID'];
}

class _AdminComplaintPageState extends State<AdminComplaintPage> {
  String resId = '';
  Stream<QuerySnapshot>? _complaintStream;

  @override
  void initState() {
    super.initState();
    _fetchResID();
  }

  Future<void> _fetchResID() async {
    resId = await _retrieveResID();
    setState(() {
      _complaintStream = FirebaseFirestore.instance
          .collection('ResidencyComplaints')
          .where('ResidenceID', isEqualTo: resId)
          .snapshots();
    });
  }

  Widget _buildComplaintItem(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    double severity = double.tryParse(data['Severity']) ?? 0.0;
    debugPrint('Severity: $severity');
    return ListTile(
      title: Text(
        data['Complaint'],
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        data['Name'] + ' ' + data['Last Name'],
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Image.asset('images/title_2.png', scale: 3.8),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: FloatingActionButton(
          elevation: 0.00,
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 214, 194, 13),
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _complaintStream == null
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _complaintStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'SOME ERROR OCCURRED WHILE FETCHING COMPLAINTS',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'NO COMPLAINTS FOUND',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return _buildComplaintItem(
                                context, snapshot.data!.docs[index]);
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
