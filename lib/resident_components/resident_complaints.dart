import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resiease/models/auth.dart';

String errorMessageComplaints = '';

Widget _displayMessage({required String error, required bool submitted}) {
  if (error == '' && submitted) {
    return const Text(
      'YOUR COMPLAINT HAS BEEN REGISTERED SUCCESSFULLY! IT WILL BE ADDRESSED BY THE ADMIN SHORTLY',
      style: TextStyle(
        color: Color.fromARGB(255, 224, 203, 19),
      ),
    );
  } else if (error != '') {
    return Text(
      errorMessageComplaints,
      style: const TextStyle(
        color: Color.fromARGB(255, 217, 29, 16),
      ),
    );
  } else {
    return const SizedBox();
  }
}

Widget _entryField(
    String title, TextEditingController controller, bool obscureText) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        hintText: title == 'Password' ? 'Enter your Password' : title,
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

class ResidentComplaintPage extends StatefulWidget {
  const ResidentComplaintPage({super.key});

  @override
  State<ResidentComplaintPage> createState() => _ResidentComplaintPageState();
}

class _ResidentComplaintPageState extends State<ResidentComplaintPage> {
  bool isSubmitted = false;

  Future<void> _uploadComplaints({
    required String complaint,
  }) async {
    String resId = '';
    String userID = '';
    String firstName = '';
    String lastName = '';
    dynamic data;
    DateTime currTimeStamp = DateTime.now();
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Residents')
          .where('UserID', isEqualTo: Auth().currentUser!.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        data = querySnapshot.docs.first;
        resId = data['ResidenceID'];
        userID = data['UserID'];
        firstName = data['Name'];
        lastName = data['Last Name'];
      }
      Map<String, dynamic> dataUpload = {
        'ResidenceID': resId,
        'UserID': userID,
        'Complaint': complaint,
        'Time': currTimeStamp,
        'Name': firstName,
        'Last Name': lastName
      };
      CollectionReference ref =
          FirebaseFirestore.instance.collection('ResidencyComplaints');
      await ref.doc().set(
            dataUpload,
            SetOptions(merge: false),
          );
    } on FirebaseException catch (e) {
      setState(() {
        errorMessageComplaints = e.toString();
      });
    }
  }

  final TextEditingController _controllerComplaint = TextEditingController();
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
          child: Column(
            children: [
              const SizedBox(
                height: 60,
              ),
              const Text(
                'So sorry to hear that you faced any troubles! Kindly register your complaint below:',
                style: TextStyle(
                  color: Color.fromARGB(255, 207, 190, 31),
                ),
              ),
              _entryField(
                'Please Type your Complaint',
                _controllerComplaint,
                false,
              ),
              _displayMessage(
                  error: errorMessageComplaints, submitted: isSubmitted),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 40, 39, 39),
                ),
                onPressed: () {
                  _uploadComplaints(complaint: _controllerComplaint.text);
                  setState(() {
                    isSubmitted = true;
                  });
                },
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
