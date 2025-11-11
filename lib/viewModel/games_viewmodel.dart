import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_my_pickle/model/game_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class GameViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<GameModel> _upcomingGames = [];
  bool _isLoading = false;
  String? _currentCourtId;

  List<GameModel> get upcomingGames => _upcomingGames;
  bool get isLoading => _isLoading;

  Future<void> joinGame({
    required String courtId,
    required String courtName,
    required DateTime gameDateTime,
    int maxPlayers = 4,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    _isLoading = true;
    notifyListeners();

    try {
      // Get user profile data - create if doesn't exist
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() ?? {};
      
      // If user document doesn't exist, create basic user data
      if (!userDoc.exists) {
        userData = {
          'displayName': user.displayName ?? user.email?.split('@').first ?? 'Player',
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('users').doc(user.uid).set(userData);
      }

      String? profileImageUrl;
      try {
        final profileRef = _storage.ref().child("users/${user.uid}/profile.jpg");
        profileImageUrl = await profileRef.getDownloadURL();
      } catch (e) {
        profileImageUrl = null;
      }

      final player = Player(
        userId: user.uid,
        userName: userData['displayName'] ?? user.email?.split('@').first ?? 'Player',
        profileImageUrl: profileImageUrl,
        joinedAt: DateTime.now(),
      );

      final gameId = '${courtId}_${gameDateTime.millisecondsSinceEpoch}';
      final gameDoc = await _firestore.collection('gameSessions').doc(gameId).get();

      if (gameDoc.exists) {
        final gameData = gameDoc.data()!;
        final players = (gameData['players'] as List<dynamic>? ?? [])
            .map((p) => Player.fromMap(p as Map<String, dynamic>))
            .toList();
        
        if (players.any((p) => p.userId == user.uid)) {
          throw Exception('You have already joined this game');
        }
        
        if (players.length >= (gameData['maxPlayers'] ?? 4)) {
          throw Exception('This game session is full');
        }
        
        players.add(player);

        await _firestore.collection('gameSessions').doc(gameId).update({
          'players': players.map((p) => p.toMap()).toList(),
        });
      } else {
        final newGame = GameModel(
          id: gameId,
          courtId: courtId,
          courtName: courtName,
          gameDateTime: gameDateTime,
          players: [player],
          maxPlayers: maxPlayers,
          createdBy: user.uid,
        );

        await _firestore.collection('gameSessions').doc(gameId).set(newGame.toFirestore());
      }

      // Reload games for this court after joining
      await loadUpcomingGamesForCourt(courtId);
      
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveGame(String gameId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final gameDoc = await _firestore.collection('gameSessions').doc(gameId).get();
      if (!gameDoc.exists) return;

      final gameData = gameDoc.data()!;
      final players = (gameData['players'] as List<dynamic>? ?? [])
          .map((p) => Player.fromMap(p as Map<String, dynamic>))
          .toList();

      players.removeWhere((player) => player.userId == user.uid);

      if (players.isEmpty) {
        await _firestore.collection('gameSessions').doc(gameId).delete();
      } else {
        await _firestore.collection('gameSessions').doc(gameId).update({
          'players': players.map((p) => p.toMap()).toList(),
        });
      }
      
      // Reload games after leaving
      if (_currentCourtId != null) {
        await loadUpcomingGamesForCourt(_currentCourtId!);
      }
      
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load upcoming games for a court
  Future<void> loadUpcomingGamesForCourt(String courtId) async {
    _isLoading = true;
    _currentCourtId = courtId;
    notifyListeners();

    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection('gameSessions')
          .where('courtId', isEqualTo: courtId)
          .where('gameDateTime', isGreaterThanOrEqualTo: now)
          .orderBy('gameDateTime')
          .get();

      _upcomingGames = snapshot.docs
          .map((doc) => GameModel.fromFirestore(doc.data(), doc.id))
          .toList();
          
      print('Loaded ${_upcomingGames.length} games for court $courtId');
          
    } catch (e) {
      print('Error loading games: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if current user is in a game
  bool isUserInGame(GameModel game) {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    return game.players.any((player) => player.userId == user.uid);
  }

  // Stream for real-time updates
  Stream<List<GameModel>> getGameSessionsStream(String courtId) {
    final now = Timestamp.now();
    return _firestore
        .collection('gameSessions')
        .where('courtId', isEqualTo: courtId)
        .where('gameDateTime', isGreaterThanOrEqualTo: now)
        .orderBy('gameDateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}