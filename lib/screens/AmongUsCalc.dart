import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AmongUsCalc extends StatefulWidget {
  const AmongUsCalc({super.key});

  @override
  _AmongUsCalcState createState() => _AmongUsCalcState();
}

class _AmongUsCalcState extends State<AmongUsCalc> {
  List<String> _playerGame = [];
  List<bool> _checkBoxValues = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    _playerGame = args['playerGame'];
    _checkBoxValues = List.filled(_playerGame.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Among Us Calc'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: _playerGame.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_playerGame[index]),
                  value: _checkBoxValues[index],
                  onChanged: (value) {
                    setState(() {
                      _checkBoxValues[index] = value!;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _handleWin();
                  },
                  child: const Text('Win'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _handleLose();
                  },
                  child: const Text('Lose'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleWin() async {
    final DateTime now = DateTime.now();
    String dateId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final List<int> winners = _checkBoxValues.asMap().entries.where((element) => element.value).map((e) => e.key + 1).toList();

    final DocumentReference dayDoc = _firestore.collection('amongus').doc(dateId);

    // التأكد من أن المستند يحتوي على حقل التاريخ
    await dayDoc.set({'date': dateId}, SetOptions(merge: true));

    for (int winner in winners) {
      final String winnerName = _playerGame[winner - 1];
      final DocumentReference winnerDoc = dayDoc.collection('players').doc(winnerName);

      final DocumentSnapshot winnerSnapshot = await winnerDoc.get();
      if (winnerSnapshot.exists) {
        Map<String, dynamic> winnerData = winnerSnapshot.data() as Map<String, dynamic>;
        int wins = winnerData['wins'] ?? 0;
        // إضافة فوز جديد وتعيين loses إلى 0
        await winnerDoc.update({'wins': wins + 1, });
      } else {
        // إضافة فوز جديد وتعيين loses إلى 0
        await winnerDoc.set({'wins': 1, 'loses': 0});
      }
    }

    print('Winners: $winners');
  }




  void _handleLose() async {
    final DateTime now = DateTime.now();
    String dateId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final List<int> losers = _checkBoxValues.asMap().entries.where((element) => !element.value).map((e) => e.key + 1).toList();

    final DocumentReference dayDoc = _firestore.collection('amongus').doc(dateId);

    // التأكد من أن المستند يحتوي على حقل التاريخ
    await dayDoc.set({'date': dateId}, SetOptions(merge: true));

    for (int loser in losers) {
      final String loserName = _playerGame[loser - 1];
      final DocumentReference loserDoc = dayDoc.collection('players').doc(loserName);

      final DocumentSnapshot loserSnapshot = await loserDoc.get();
      if (loserSnapshot.exists) {
        Map<String, dynamic> loserData = loserSnapshot.data() as Map<String, dynamic>;
        int loses = loserData['loses'] ?? 0;
        // إضافة خسارة جديدة وتعيين wins إلى 0
        await loserDoc.update({'loses': loses + 1, });
      } else {
        // إضافة خسارة جديدة وتعيين wins إلى 0
        await loserDoc.set({'loses': 1, 'wins': 0});
      }
    }

    print('Losers: $losers');
  }



}