class PlayerStats {
  late String name;
  late int losesToday;
  late int winsToday;
  late int totalToday;
  late int totalLosesAllDays;
  late int totalWinsAllDays;
  late int totalTotal;

  PlayerStats({
    required this.name,
    required this.losesToday,
    required this.winsToday,
    required this.totalToday,
    required this.totalLosesAllDays,
    required this.totalWinsAllDays,
    required this.totalTotal,
  });
}
class AmongUsAllDays{
  final List<AmongUsScors> amongUsScors;
  final DateTime date;

  AmongUsAllDays({required this.amongUsScors, required this.date});
}
class AmongUsScors{
  final String name;
  final Score score;

  AmongUsScors({required this.name, required this.score});
}
class Score {
  final int loses;
  final int wins;

  Score({required this.loses, required this.wins});
}
