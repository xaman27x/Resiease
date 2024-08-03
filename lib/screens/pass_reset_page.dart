import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/auth.dart';

class DisplayGlobals {
  static String displayMessage = '';
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

class PassResetPage extends StatefulWidget {
  const PassResetPage({super.key});

  @override
  State<PassResetPage> createState() => _PassResetPageState();
}

class _PassResetPageState extends State<PassResetPage> {
  bool isHidden = true;
  final TextEditingController _controllerEmail = TextEditingController();

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await Auth().sendPasswordResetEmail(
        email: email,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        e.toString(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("images/title_2.png", scale: 3.8),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
        child: Column(
          children: [
            _entryField('Email-ID', _controllerEmail, false),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.amber[200]),
              onPressed: () {
                sendPasswordResetEmail(email: _controllerEmail.text);
                setState(() {
                  isHidden = false;
                });
              },
              child: const Text(
                'RESET',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              isHidden
                  ? ""
                  : "A Password Reset Link Has been Sent to the Registered E-mail Address!",
              style: const TextStyle(
                color: Color.fromARGB(255, 71, 71, 71),
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
