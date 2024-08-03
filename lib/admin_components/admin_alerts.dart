import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/auth.dart';

class AdminAlertsPage extends StatefulWidget {
  const AdminAlertsPage({super.key});

  @override
  State<AdminAlertsPage> createState() => _AdminAlertsPageState();
}

Widget _entryField(
    String title, TextEditingController controller, bool obscureText) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        hintText:
            title == 'Password' ? 'Enter your Password' : 'Enter your $title',
        filled: true,
        fillColor: const Color.fromARGB(193, 255, 255, 255).withOpacity(0.1),
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Color.fromARGB(174, 255, 255, 255)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
    ),
  );
}

Future<void> _uploadAlerts({required String alert}) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Admins')
      .where('UserID', isEqualTo: Auth().currentUser!.uid)
      .get();
  final data = querySnapshot.docs.first;
  Map<String, dynamic> dataUpload = {
    'Alert': alert,
    'ResidenceID': data['Residence ID'],
    'Timestamp': DateTime.now(),
  };
  await FirebaseFirestore.instance
      .collection('ResidencyAlerts')
      .add(dataUpload);
}

class _AdminAlertsPageState extends State<AdminAlertsPage> {
  final TextEditingController _controllerAlert = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/title_2.png',
          scale: 3.8,
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: FloatingActionButton(
          elevation: 0.0,
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
            children: [
              _entryField('Alert', _controllerAlert, false),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 23, 23),
                ),
                onPressed: () {
                  _uploadAlerts(alert: _controllerAlert.text);
                },
                child: const Text(
                  'ALERT',
                  style: TextStyle(
                    color: Color.fromARGB(255, 232, 209, 9),
                    fontSize: 20,
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
