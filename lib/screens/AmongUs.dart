import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/Player.dart';

class AmongUsPage extends StatefulWidget {
  const AmongUsPage({super.key});

  @override
  _AmongUsPageState createState() => _AmongUsPageState();
}

class _AmongUsPageState extends State<AmongUsPage> {
  List<Player> players = [
    Player(name: 'ibram'),
    Player(name: 'bebo'),
    Player(name: 'doc bebo'),
    Player(name: 'doc'),
    Player(name: 'Mikee'),
    Player(name: 'kero'),
    Player(name: 'mt'),
    Player(name: 'Michelle'),
  ];

  final Map<String, bool> _checkboxValues = {};

  @override
  void initState() {
    super.initState();
    _loadCheckboxStates();
  }

  _loadCheckboxStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (Player player in players) {
        _checkboxValues[player.name] = prefs.getBool(player.name) ?? false;
      }
    });
  }

  _saveCheckboxStates() async {
    final prefs = await SharedPreferences.getInstance();
    for (String key in _checkboxValues.keys) {
      prefs.setBool(key, _checkboxValues[key]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Among Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            for (Player player in players)
              CheckboxListTile(
                title: Text(player.name),
                value: _checkboxValues[player.name],
                onChanged: (value) {
                  setState(() {
                    _checkboxValues[player.name] = value!;
                  });
                  _saveCheckboxStates();
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            'amonguscalc',
            arguments: {
              'playerGame': _checkboxValues.keys.where((key) => _checkboxValues[key]!).toList(),
            },
          );
        },
        child: const Icon(Icons.arrow_forward_outlined),
      ),
    );
  }
}