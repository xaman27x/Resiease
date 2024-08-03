// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resiease/models/auth.dart';

class AdminData {
  static String adminName = '';
  static String designation = '';
}

Future<void> _retrieveAdminData_Resident() async {
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Residents')
      .where('UserID', isEqualTo: Auth().currentUser!.uid)
      .get();
  final data = querySnapshot.docs.first;
  final String resId = data['ResidenceID'];
  final QuerySnapshot adminQuery = await FirebaseFirestore.instance
      .collection('Admins')
      .where('Residence ID', isEqualTo: resId)
      .get();
  final adminData = adminQuery.docs.first;
  AdminData.adminName = adminData['Name'] + ' ' + adminData['Last Name'];
  AdminData.designation = adminData['Designation'];
}

class ResidentMembersPage extends StatefulWidget {
  const ResidentMembersPage({super.key});

  @override
  State<ResidentMembersPage> createState() => _ResidentMembersPageState();
}

class _ResidentMembersPageState extends State<ResidentMembersPage> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Residents').snapshots();

  @override
  void initState() {
    super.initState();
    _fetchAdminData_Resident();
  }

  Future<void> _fetchAdminData_Resident() async {
    await _retrieveAdminData_Resident();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'SOME ERROR OCCURRED WHILE FETCHING MEMBERS',
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListTile(
                      title: Text(
                        '${AdminData.adminName} / ADMIN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        AdminData.designation,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'MEMBERS',
                      style: TextStyle(
                        color: Color.fromARGB(255, 14, 87, 146),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data = snapshot.data!.docs[index]
                              .data()! as Map<String, dynamic>;
                          return ListTile(
                            mouseCursor: MouseCursor.defer,
                            titleTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            title: Text(
                                '${index + 1}) ${data['Name']} ${data['Last Name']}'),
                            subtitle: const Text(
                              'Position: Member',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
