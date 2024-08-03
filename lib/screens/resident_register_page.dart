import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resiease/screens/home_page.dart';
import 'package:resiease/models/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfirmationGlobals {
  static String residenceID = '';
  static String firstName = '';
  static String lastName = '';
  static String uid = '';
  static String emailId = '';
  static String password = '';
  static dynamic age;
}

String errormessage = '';

class ResidentRegisterPage extends StatefulWidget {
  const ResidentRegisterPage({super.key});

  @override
  State<ResidentRegisterPage> createState() => _ResidentRegisterPageState();
}

Future<void> registerResidentWithEmailandPassword(bool isAdmin,
    {required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String age,
    required String residenceId}) async {
  try {
    await Auth()
        .createUserWithEmailAndPassword(email: email, password: password);
    String currUserID = Auth().currentUser!.uid;

    Map<String, dynamic> residentdataUpload = {
      'UserID': currUserID,
      'Name': firstName,
      'Last Name': lastName,
      'Age': age,
      'EmailID': email,
      'ResidenceID': residenceId,
    };
    Auth().residents.doc(currUserID).set(residentdataUpload);
  } on FirebaseAuthException catch (e) {
    errormessage = e.toString();
    log(e.toString());
  }
}

class _ResidentRegisterPageState extends State<ResidentRegisterPage> {
  final TextEditingController _controllerResidenceID = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerAge = TextEditingController();
  final TextEditingController _controllerEmailID = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  bool isObscure = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/title_2.png', scale: 3.8),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
        child: Center(
          child: Column(
            children: [
              _entryField('Residence ID', _controllerResidenceID, false),
              _entryField('First Name', _controllerName, false),
              _entryField('Last Name', _controllerLastName, false),
              _entryField('Age', _controllerAge, false),
              const SizedBox(
                height: 20,
              ),
              _entryField('Email ID', _controllerEmailID, false),
              _entryField('Password', _controllerPassword, isObscure),
              FloatingActionButton(
                backgroundColor: Colors.amber[200],
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                child: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 25.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[200]),
                onPressed: () {
                  ConfirmationGlobals.residenceID = _controllerResidenceID.text;
                  ConfirmationGlobals.firstName = _controllerName.text;
                  ConfirmationGlobals.lastName = _controllerLastName.text;
                  ConfirmationGlobals.emailId = _controllerEmailID.text;
                  ConfirmationGlobals.password = _controllerPassword.text;
                  ConfirmationGlobals.age = _controllerAge.text;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RetrievalDecisionPage(),
                    ),
                  );
                },
                child: const Text(
                  'REGISTER',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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

class RetrievalDecisionPage extends StatefulWidget {
  const RetrievalDecisionPage({super.key});

  @override
  State<RetrievalDecisionPage> createState() => _RetrievalDecisionPageState();
}

class _RetrievalDecisionPageState extends State<RetrievalDecisionPage> {
  @override
  void initState() {
    super.initState();
    _fetchResidenceData();
  }

  Future<void> _fetchResidenceData() async {
    final residenceID = ConfirmationGlobals.residenceID;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Residencies')
        .where('ID', isEqualTo: residenceID)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return;
    }
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final residenceData = {
        'name': doc['Residence Name'],
        'city': doc['Residence City'],
        'pincode': doc['Pincode'],
      };

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationPage(
            residenceData: residenceData,
          ),
        ),
      );
    } else {
      debugPrint('No residence found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/title_2.png',
          scale: 3.8,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () => {
              Navigator.pop(context),
            },
            icon: const Icon(Icons.arrow_back_ios),
          )
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
        child: const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}

class ConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> residenceData;

  const ConfirmationPage({super.key, required this.residenceData});

  @override
  Widget build(BuildContext context) {
    final residenceName = residenceData['name'];
    final residenceCity = residenceData['city'];
    final pincode = residenceData['pincode'];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/title_2.png', scale: 3.8),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: const Color.fromARGB(255, 161, 151, 108),
          onPressed: () => {
            Navigator.pop(context),
            Navigator.pop(context),
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'CONFIRMATION',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                'DO YOU WISH TO JOIN THE FOLLOWING RESIDENCY?\nName: $residenceName\nCity: $residenceCity\nPincode: $pincode',
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[100],
                    ),
                    onPressed: () {
                      registerResidentWithEmailandPassword(
                        false,
                        email: ConfirmationGlobals.emailId,
                        password: ConfirmationGlobals.password,
                        firstName: ConfirmationGlobals.firstName,
                        lastName: ConfirmationGlobals.lastName,
                        age: ConfirmationGlobals.age,
                        residenceId: ConfirmationGlobals.residenceID,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResidentHomePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'CONFIRM',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 35),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[100],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResidentRegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'DENY',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
