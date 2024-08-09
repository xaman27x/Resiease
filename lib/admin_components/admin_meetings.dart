import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/auth.dart';

class AdminMeetingsPage extends StatefulWidget {
  const AdminMeetingsPage({super.key});

  @override
  State<AdminMeetingsPage> createState() => _AdminMeetingsPageState();
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

class _AdminMeetingsPageState extends State<AdminMeetingsPage> {
  // ignore: non_constant_identifier_names
  String resi_id = '';
  final TextEditingController _controllerTopic = TextEditingController();
  final TextEditingController _controllerDate = TextEditingController();
  final TextEditingController _controllerVenue = TextEditingController();

  Future<void> _fetchResID() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Admins')
        .where('UserID', isEqualTo: Auth().currentUser!.uid)
        .get();
    final data = querySnapshot.docs.first;
    resi_id = data['Residence ID'];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _controllerDate.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _uploadMeetingSchedule(
      {required String topic,
      required String date,
      required String venue,
      required String resID}) async {
    CollectionReference ref =
        FirebaseFirestore.instance.collection('ResidencyMeetings');

    Map<String, dynamic> dataUpload = {
      'Topic': topic,
      'Venue': venue,
      'Date': date,
      'ResidenceID': resID,
    };
    try {
      await ref.add(dataUpload);
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _dateField(
      String title, TextEditingController controller, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          hintText: 'Select a $title',
          filled: true,
          fillColor: const Color.fromARGB(193, 255, 255, 255).withOpacity(0.1),
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: const TextStyle(color: Color.fromARGB(174, 255, 255, 255)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        readOnly: true,
        onTap: onTap,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchResID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        child: Center(
          child: Column(
            children: [
              _entryField(
                'Topic',
                _controllerTopic,
                false,
              ),
              _dateField(
                'Date',
                _controllerDate,
                () => _selectDate(context),
              ),
              _entryField(
                'Venue',
                _controllerVenue,
                false,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[100],
                ),
                onPressed: () {
                  _uploadMeetingSchedule(
                    topic: _controllerTopic.text,
                    date: _controllerDate.text,
                    venue: _controllerVenue.text,
                    resID: resi_id,
                  );
                },
                child: const Text(
                  'SEND ALERT',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
