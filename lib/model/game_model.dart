import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String id;
  final String courtId;
  final String courtName;
  final DateTime gameDateTime;
  final List<Player> players;
  final int maxPlayers;
  final String createdBy;

  GameModel({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.gameDateTime,
    required this.players,
    required this.maxPlayers,
    required this.createdBy,
  });

  factory GameModel.fromFirestore(Map<String, dynamic> data, String id) {
    return GameModel(
      id: id,
      courtId: data['courtId'] ?? '',
      courtName: data['courtName'] ?? '',
      gameDateTime: (data['gameDateTime'] as Timestamp).toDate(),
      players: (data['players'] as List<dynamic>? ?? [])
          .map((player) => Player.fromMap(player as Map<String, dynamic>))
          .toList(),
      maxPlayers: data['maxPlayers'] ?? 4,
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courtId': courtId,
      'courtName': courtName,
      'gameDateTime': Timestamp.fromDate(gameDateTime),
      'players': players.map((player) => player.toMap()).toList(), // Fixed: lowercase 'p'
      'maxPlayers': maxPlayers,
      'createdBy': createdBy,
    };
  }

  bool get isFull => players.length >= maxPlayers;
  int get spotsLeft => maxPlayers - players.length;
}

class Player {
  final String userId;
  final String userName;
  final String? profileImageUrl;
  final DateTime joinedAt;

  Player({
    required this.userId,
    required this.userName,
    this.profileImageUrl,
    required this.joinedAt,
  });

  factory Player.fromMap(Map<String, dynamic> data) {
    return Player(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      profileImageUrl: data['profileImageUrl'],
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}