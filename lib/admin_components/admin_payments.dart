import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resiease/models/auth.dart';
import 'package:random_string_generator/random_string_generator.dart';

class AdminFeeGlobals {
  static String name = '';
  static String lastName = '';
  static String userID = '';
  static String residenceID = '';
}

Future<void> _uploadRegularPaymentAlert({
  required String value,
  required String interval,
}) async {
  String adminId = Auth().currentUser!.uid;
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Admins')
      .where('UserID', isEqualTo: adminId)
      .get();
  final data = querySnapshot.docs.first;
  final resID = data['Residence ID'];
  QuerySnapshot querySnapshotResidents = await FirebaseFirestore.instance
      .collection('Residents')
      .where('ResidenceID', isEqualTo: resID.toString())
      .get();

  List<String> residentsID = [];
  for (var doc in querySnapshotResidents.docs) {
    residentsID.add(doc['UserID']);
  }

  final gen_8 =
      RandomStringGenerator(hasSymbols: false, fixedLength: 8).generate();

  CollectionReference ref =
      FirebaseFirestore.instance.collection('ResidencyFees');
  Map<String, dynamic> dataUpload = {
    'Interval': interval,
    'Amount': int.parse(value),
    'ResidenceID': resID,
    'Time': DateTime.now(),
    'RequestID': gen_8,
    'Residents': residentsID,
  };
  await ref.add(dataUpload);
}

Future<void> _uploadSpecialPaymentAlert(
    {required String resID,
    required String name,
    required String lastName,
    required String userID,
    required String amount,
    required String reason}) async {
  final amountInt = int.parse(amount);
  final gen_8 =
      RandomStringGenerator(hasSymbols: false, fixedLength: 8).generate();

  Map<String, dynamic> dataUpload = {
    'Name': name,
    'Last Name': lastName,
    'Amount': amountInt,
    'UserID': userID,
    'ResidenceID': resID,
    'Reason': reason,
    'RequestID': gen_8,
  };

  try {
    FirebaseFirestore.instance
        .collection('ResidencySpecialFees')
        .add(dataUpload);
  } on FirebaseException catch (e) {
    debugPrint(
      e.toString(),
    );
  }
}

class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[200],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminRegularFeesPage(),
                    ),
                  );
                },
                child: const Text(
                  'REGULAR MAINTENANCE FEES',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[200],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminSpecialFeesPage(),
                    ),
                  );
                },
                child: const Text(
                  'SPECIAL FEES ALERT',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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

Widget _entryField(String title, TextEditingController controller) {
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
    ),
  );
}

class AdminRegularFeesPage extends StatefulWidget {
  const AdminRegularFeesPage({super.key});

  @override
  State<AdminRegularFeesPage> createState() => _AdminRegularFeesPageState();
}

class _AdminRegularFeesPageState extends State<AdminRegularFeesPage> {
  final TextEditingController _controllerFees = TextEditingController();
  final TextEditingController _controllerInterval = TextEditingController();

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
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
        child: Center(
          child: Column(
            children: [
              DropdownMenu(
                hintText: "TIMEFRAME?",
                controller: _controllerInterval,
                menuStyle: MenuStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.amber[100],
                  ),
                  side: const MaterialStatePropertyAll(
                    BorderSide(
                      width: 2,
                      color: Colors.grey,
                    ),
                  ),
                ),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: Text('1'), label: 'MONTHLY'),
                  DropdownMenuEntry(value: Text('2'), label: 'QUARTERLY'),
                  DropdownMenuEntry(value: Text('3'), label: 'SEMI-ANNUAL'),
                  DropdownMenuEntry(value: Text('4'), label: 'ANNUAL'),
                ],
              ),
              _entryField('Payment Amount', _controllerFees),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[100],
                ),
                onPressed: () {
                  _uploadRegularPaymentAlert(
                      value: _controllerFees.text,
                      interval: _controllerInterval.text);
                },
                child: const Text(
                  'Send Alert',
                  style: TextStyle(
                    color: Color.fromARGB(255, 41, 41, 41),
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

Future<String> _fetchResidenceID() async {
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Admins')
      .where('UserID', isEqualTo: Auth().currentUser!.uid)
      .get();
  final data = querySnapshot.docs.first;
  return data['Residence ID'];
}

class AdminSpecialFeesPage extends StatefulWidget {
  const AdminSpecialFeesPage({super.key});

  @override
  State<AdminSpecialFeesPage> createState() => _AdminSpecialFeesPageState();
}

class _AdminSpecialFeesPageState extends State<AdminSpecialFeesPage> {
  late Stream<QuerySnapshot> _residentStream = const Stream.empty();
  final TextEditingController _controllerReason = TextEditingController();
  final TextEditingController _controlllerFees = TextEditingController();
  Color varColor = const Color.fromARGB(255, 161, 151, 108);

  @override
  void initState() {
    super.initState();
    _initializeResidentStream();
  }

  void _initializeResidentStream() async {
    String residenceID = await _fetchResidenceID();
    setState(() {
      AdminFeeGlobals.residenceID = residenceID;
      _residentStream = FirebaseFirestore.instance
          .collection('Residents')
          .where('ResidenceID', isEqualTo: AdminFeeGlobals.residenceID)
          .snapshots();
    });
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
        leading: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 0.0,
          onPressed: () => {
            Navigator.pop(context),
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 204, 185, 17),
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 161, 151, 108),
        child: Center(
          child: Column(
            children: [
              _entryField('Reason', _controllerReason),
              const Text(
                'SELECT THE APPLICABLE MEMBER',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _residentStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child:
                            Text('An Error Occurred. Please try again later.'),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 30),
                          Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> data =
                                    snapshot.data!.docs[index].data()!
                                        as Map<String, dynamic>;
                                return Material(
                                  type: MaterialType.card,
                                  child: ListTile(
                                    onTap: () {
                                      AdminFeeGlobals.name = data['Name'];
                                      AdminFeeGlobals.lastName =
                                          data['Last Name'];
                                      AdminFeeGlobals.userID = data['UserID'];
                                    },
                                    leading: const Icon(
                                      Icons.person_pin_outlined,
                                      color: Color.fromARGB(255, 23, 120, 205),
                                    ),
                                    title: Text(
                                      'Name: ${data['Name'] + ' ' + data['Last Name']}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Email-ID: ${data['EmailID']}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    trailing: const Text(
                                      'Tap to Select',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          _entryField('Amount', _controlllerFees),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[100],
                            ),
                            onPressed: () {
                              _uploadSpecialPaymentAlert(
                                  resID: AdminFeeGlobals.residenceID,
                                  name: AdminFeeGlobals.name,
                                  lastName: AdminFeeGlobals.lastName,
                                  userID: AdminFeeGlobals.userID,
                                  amount: _controlllerFees.text,
                                  reason: _controllerReason.text);
                            },
                            child: const Text(
                              'CONFIRM',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
