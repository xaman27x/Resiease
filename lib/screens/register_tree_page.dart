import 'package:flutter/material.dart';
import 'package:resiease/models/auth.dart';
import 'package:resiease/screens/home_page.dart';
import 'package:resiease/screens/register_page.dart';

class RegisterTreePage extends StatefulWidget {
  const RegisterTreePage({super.key});

  @override
  State<RegisterTreePage> createState() => _RegisterTreePageState();
}

class _RegisterTreePageState extends State<RegisterTreePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const AdminHomePage();
        } else {
          return const RegisterPage();
        }
      },
    );
  }
}
