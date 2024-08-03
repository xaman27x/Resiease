import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resiease/models/auth.dart';

class AdminData {
  static String adminName = '';
  static String designation = '';
}

Widget _deleteButton({required String uid}) {
  return FloatingActionButton(
    elevation: 1,
    backgroundColor: const Color.fromARGB(255, 161, 151, 108),
    onPressed: () async {
      try {
        await FirebaseFirestore.instance
            .collection('Residents')
            .doc(uid)
            .delete();
      } catch (e) {
        debugPrint('Error deleting user: $e');
      }
    },
    child: const Icon(
      Icons.delete_forever,
      color: Colors.red,
    ),
  );
}

Future<void> _retrieveAdminData() async {
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Admins')
      .where('UserID', isEqualTo: Auth().currentUser!.uid)
      .get();
  if (querySnapshot.docs.isEmpty) {
    return;
  } else {
    final data = querySnapshot.docs.first;
    AdminData.adminName = data['Name'] + ' ' + data['Last Name'];
    AdminData.designation = data['Designation'];
  }
}

class AdminMembersPage extends StatefulWidget {
  const AdminMembersPage({super.key});

  @override
  State<AdminMembersPage> createState() => _AdminMembersPageState();
}

class _AdminMembersPageState extends State<AdminMembersPage> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Residents').snapshots();

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    await _retrieveAdminData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'SOME ERROR OCCURRED WHILE FETCHING MEMBERS',
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
                            trailing: _deleteButton(
                              uid: data['UserID'],
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
