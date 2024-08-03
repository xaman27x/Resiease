import 'package:flutter/material.dart';
import 'package:resiease/models/auth.dart';
import 'package:resiease/screens/home_page.dart';
import 'package:resiease/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> _checkAdminExists({required String uid}) async {
  DocumentSnapshot document =
      await FirebaseFirestore.instance.collection('Admins').doc(uid).get();
  return document.exists;
}

class LoginTreePage extends StatefulWidget {
  const LoginTreePage({super.key});

  @override
  State<LoginTreePage> createState() => _LoginTreePageState();
}

class _LoginTreePageState extends State<LoginTreePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (authSnapshot.hasData) {
          final uid = authSnapshot.data!.uid;
          return FutureBuilder(
            future: _checkAdminExists(uid: uid),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (adminSnapshot.hasData) {
                bool isAdmin = adminSnapshot.data!;
                if (isAdmin) {
                  return const AdminHomePage();
                } else {
                  return const ResidentHomePage();
                }
              } else if (adminSnapshot.hasError) {
                return const Center(child: Text('An error occurred'));
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
