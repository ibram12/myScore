import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../Model/PlayerStats.dart';

class PlayerStatsPage extends StatefulWidget {
  const PlayerStatsPage({super.key});

  @override
  _PlayerStatsPageState createState() => _PlayerStatsPageState();
}

class _PlayerStatsPageState extends State<PlayerStatsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<PlayerStats> _playerStats = [];
  final StreamController<List<PlayerStats>> _playerStatsController = StreamController<List<PlayerStats>>();
  List<AmongUsAllDays> amongUsAllDaysList = [];
  DateFormat format = DateFormat('yyyy-MM-dd');
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  Future<void> _loadData() async {
    await getScore();
    _loadPlayerStats();
  }

  Future<void> getScore() async {
    final QuerySnapshot playerscore = await _firestore.collection('amongus').get();

    amongUsAllDaysList.clear();

    await Future.forEach(playerscore.docs, (amongDoc) async {
      List<AmongUsScors> amongUsScorsList = [];
      final QuerySnapshot playersSnapshot = await amongDoc.reference.collection('players').get();

      await Future.forEach(playersSnapshot.docs, (playerDoc) async {
        final score = Score(
          loses: playerDoc.get('loses') ?? 0,
          wins: playerDoc.get('wins') ?? 0,
        );
        final amongUsScors = AmongUsScors(
          name: playerDoc.id,
          score: score,
        );
        amongUsScorsList.add(amongUsScors);
      });
      final amongUsAllDays = AmongUsAllDays(
        amongUsScors: amongUsScorsList,
        date: format.parse(amongDoc.id),
      );

      amongUsAllDaysList.add(amongUsAllDays);
    });
  }

  void _loadPlayerStats() {
    final DateTime now = DateTime.now();
    final String date = '${now.year}-${now.month}-${now.day}';

    _playerStats.clear();

    amongUsAllDaysList.forEach((day) {
      DateTime dateplay = day.date;
      day.amongUsScors.forEach((player) {
        String namePlayer = player.name;
        int loses = player.score.loses;
        int wins = player.score.wins;

        // Check if a player with the same name already exists
        bool playerExists = false;
        for (var i = 0; i < _playerStats.length; i++) {
          if (_playerStats[i].name == namePlayer) {
            // Update the existing player's stats
            // if (dateplay== DateTime.parse(date)) {
              _playerStats[i].losesToday = loses;
              _playerStats[i].winsToday = wins;
              _playerStats[i].totalToday = (loses + wins);
            // }
            _playerStats[i].totalLosesAllDays += loses;
            _playerStats[i].totalWinsAllDays += wins;
            _playerStats[i].totalTotal += (loses + wins);
            playerExists = true;
            break;
          }
        }

        if (!playerExists) {
          // Create a new player's stats
          _playerStats.add(PlayerStats(
            name: namePlayer,
            losesToday: loses,
            winsToday: wins,
            totalToday: (loses + wins),
            totalLosesAllDays: loses,
            totalWinsAllDays: wins,
            totalTotal: (loses + wins),
          ));
        }
      });
    });

    _playerStats.sort((a, b) => b.totalTotal.compareTo(a.totalTotal ));

    // Add the sorted player stats to the stream
    _playerStatsController.add(_playerStats);
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadData(); // Reload data every 10 seconds
    });
  }

  @override
  void dispose() {
    _playerStatsController.close();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Stats'),
      ),
      body: StreamBuilder<List<PlayerStats>>(
        stream: _playerStatsController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading player stats'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No player stats available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final playerStat = snapshot.data![index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Player: ${playerStat.name}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text('Crewmate Today: ${playerStat.losesToday}'),
                                const SizedBox(height: 10),
                                Text('Imposter Today: ${playerStat.winsToday}'),
                                const SizedBox(height: 10),
                                Text('Total Today: ${playerStat.totalToday}'),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Crewmate Total: ${playerStat.totalLosesAllDays}'),
                                const SizedBox(height: 10),
                                Text('Imposter Total: ${playerStat.totalWinsAllDays}'),
                                const SizedBox(height: 10),
                                Text('Total Total: ${playerStat.totalTotal}'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
