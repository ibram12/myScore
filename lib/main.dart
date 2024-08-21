import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/AmongUs.dart';
import 'screens/LoginPage.dart';
import 'screens/AmongUsCalc.dart';
import 'screens/PlayerStatsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Check if user is already logged in
  final User? user = FirebaseAuth.instance.currentUser;

  runApp(MyApp(initialRoute: user != null ? '/' : 'LoginPage'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Points',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const MyHomePage(),
        'LoginPage': (context) => const LoginPage(),
        'amongus': (context) => const AmongUsPage(),
        'amonguscalc': (context) => const AmongUsCalc(),
        'PlayerStatsPage': (context) => const PlayerStatsPage(),
      },
    );
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Future<String?> _getUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Points'),
      ),
      body: FutureBuilder<String?>(
        future: _getUserUid(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading user data'));
          }

          final String? uid = snapshot.data;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Among Us"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (uid == "aDjjCq5iwfZ3SbV8fKpvwwyaayn1") ...[
                    ElevatedButton(
                      onPressed: () async {
                        // Navigate to Among Us points page
                        Navigator.pushNamed(context, 'amongus');
                      },
                      child: const Text('Add Points'),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: () async {
                      // Navigate to Player Stats page
                      Navigator.pushNamed(context, 'PlayerStatsPage');
                    },
                    child: const Text('My Score'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
