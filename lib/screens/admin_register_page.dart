import 'package:flutter/material.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resiease/models/auth.dart';
import 'package:resiease/screens/home_page.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerAge = TextEditingController();
  final TextEditingController _controllerDesignation = TextEditingController();
  final TextEditingController _controllerResidenceName =
      TextEditingController();
  final TextEditingController _controllerResidenceCity =
      TextEditingController();
  final TextEditingController _controllerResidencePincode =
      TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  bool isObscure = false;
  String errorMessage = '';
  dynamic residenceID;

  Future<void> createUserWithEmailandPassword(bool isAdmin) async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      String currUserID = Auth().currentUser!.uid;
      String currUserEmail = Auth().currentUser!.email.toString();

      Map<String, dynamic> userdataUpload = {
        'UserID': currUserID,
        'Name': _controllerName.text,
        'Last Name': _controllerLastName,
        'Age': int.parse(_controllerAge.text),
        'EmailID': currUserEmail,
      };
      Auth().users.doc(currUserID).set(userdataUpload);

      if (isAdmin) {
        residenceID = RandomStringGenerator(
                hasSymbols: false,
                alphaCase: AlphaCase.UPPERCASE_ONLY,
                fixedLength: 6)
            .generate();

        Map<String, dynamic> residenceDataUpload = {
          'ID': residenceID.toString(),
          'Residence Name': _controllerResidenceName.text,
          'Residence City': _controllerResidenceCity.text,
          'Pincode': int.parse(_controllerResidencePincode.text),
        };
        Map<String, dynamic> adminDataUpload = {
          'UserID': currUserID,
          'Name': _controllerName.text,
          'Last Name': _controllerLastName.text,
          'Email ID': currUserEmail,
          'Designation': isAdmin ? _controllerDesignation.text : '',
          'isAdmin': isAdmin,
          'Residence ID': residenceID,
        };

        Auth().residencies.doc(residenceID).set(residenceDataUpload);
        Auth().admins.doc(currUserID).set(adminDataUpload);
      } else {
        Map<String, dynamic> residentDataUpload = {
          'UserID': currUserID,
          'Name': _controllerName.text,
          'Last Name': _controllerLastName.text,
          'Email ID': currUserEmail,
          'Age': int.parse(_controllerAge.text),
          'Residence ID': residenceID,
          'isAdmin': false,
        };

        Auth().residents.doc(currUserID).set(residentDataUpload);
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.toString();
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                _entryField('First Name', _controllerName, false),
                _entryField('Last Name', _controllerLastName, false),
                _entryField('Age', _controllerAge, false),
                _entryField('Designation', _controllerDesignation, false),
                _entryField('Residence Name', _controllerResidenceName, false),
                _entryField('Residence City', _controllerResidenceCity, false),
                _entryField(
                    'Residence Pincode', _controllerResidencePincode, false),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Please Enter Your Credentials For Future Login',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _entryField('Email ID', _controllerEmail, false),
                _entryField('Password', _controllerPassword, isObscure),
                FloatingActionButton(
                  backgroundColor: Colors.amber[200],
                  onPressed: () {
                    setState(
                      () {
                        isObscure = !isObscure;
                      },
                    );
                  },
                  child: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[200]),
                  onPressed: () {
                    try {
                      createUserWithEmailandPassword(true);
                      setState(() {});
                    } catch (e) {
                      errorMessage = e.toString();
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminHomePage(),
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
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
