// model.dart

class Player {
  String name;
  bool isPlayer;

  Player({required this.name, this.isPlayer = false});

  // factory Player.fromJson(Map<String, dynamic> json) {
  //   return Player(
  //     name: json['name'],
  //     isImposter: json['isImposter'] ?? false,
  //   );
  // }
  //
  // Map<String, dynamic> toJson() {
  //   return {
  //     'name': name,
  //     'isImposter': isImposter,
  //   };
  // }
}