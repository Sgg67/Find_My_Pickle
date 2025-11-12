import 'package:find_my_pickle/model/game_model.dart';
import 'package:find_my_pickle/viewModel/games_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADD THIS IMPORT
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinAGame extends StatefulWidget {
  final Map<String, dynamic> court;

  const JoinAGame({super.key, required this.court});

  @override
  _JoinAGameState createState() => _JoinAGameState();
}

class _JoinAGameState extends State<JoinAGame> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<int> _availableHours = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];

  // ADD THIS METHOD TO CHECK IF USER IS GUEST
  bool _isGuestUser() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.isAnonymous;
  }

  // ADD THIS METHOD TO SHOW GUEST USER ERROR
  void _showGuestUserError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guest users cannot join games. Please create an account to join games.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load upcoming games for this court initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameViewModel>(context, listen: false)
          .loadUpcomingGamesForCourt(widget.court['place_id'] ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameViewModel = Provider.of<GameViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Game'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create New Game Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create New Game',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Court Name Display
                    ListTile(
                      leading: const Icon(Icons.sports_tennis, color: Colors.blue),
                      title: const Text('Court'),
                      subtitle: Text(
                        widget.court['name'] ?? 'Unknown Court',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date Selection
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.blue),
                      title: const Text('Select Date'),
                      subtitle: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                            : "Tap to choose a date",
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: _selectDate,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Time Selection
                    ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.blue),
                      title: const Text('Select Time'),
                      subtitle: Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : "Tap to choose a time",
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: _selectedDate != null ? _selectTime : null,
                    ),

                    const SizedBox(height: 16),

                    if (_selectedDate != null && _selectedTime != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: gameViewModel.isLoading ? null : () => _joinGame(gameViewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: gameViewModel.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Create & Join Game",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Upcoming Games Section with Real-time Updates
            Row(
              children: [
                const Text(
                  'Upcoming Games',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Eastern Time',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<List<GameModel>>(
                stream: gameViewModel.getGameSessionsStream(widget.court['place_id'] ?? ''),
                builder: (context, snapshot) {
                  // Show loading indicator while connecting to stream
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Show error if stream has error
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading games: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              gameViewModel.loadUpcomingGamesForCourt(widget.court['place_id'] ?? '');
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Get games from stream data
                  final games = snapshot.data ?? [];

                  // Show empty state if no games
                  if (games.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_tennis, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No upcoming games scheduled',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Be the first to create a game!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show games list
                  return ListView.builder(
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return _buildGameSessionCard(game, gameViewModel);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format time in 12-hour format with AM/PM
  String _formatTime12Hour(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildGameSessionCard(GameModel game, GameViewModel gameViewModel) {
    final isUserJoined = gameViewModel.isUserInGame(game);
    final formattedTime = _formatTime12Hour(game.gameDateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Name
            Text(
              game.courtName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${game.gameDateTime.month}/${game.gameDateTime.day}/${game.gameDateTime.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: game.isFull ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${game.players.length}/${game.maxPlayers}',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Players section
            Text(
              'Players:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            if (game.players.isEmpty)
              const Text(
                'No players yet - be the first to join!',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: game.players.map((player) {
                  return Chip(
                    avatar: player.profileImageUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(player.profileImageUrl!),
                            radius: 12,
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person, size: 12),
                            radius: 12,
                          ),
                    label: Text(
                      player.userName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[50],
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 16),
            
            // Join/Leave button with better styling - UPDATED WITH GUEST CHECK
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGuestUser() 
                    ? () => _showGuestUserError() // Show error if guest tries to join
                    : (game.isFull && !isUserJoined
                        ? null
                        : () => isUserJoined
                            ? _leaveGame(gameViewModel, game.id)
                            : _joinExistingGame(gameViewModel, game)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUserJoined ? Colors.red : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isUserJoined ? Icons.exit_to_app : Icons.person_add,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isUserJoined ? 'Leave Game' : 'Join Game',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Show message if game is full
            if (game.isFull && !isUserJoined)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'This game is full',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
    }
  }

  Future<void> _selectTime() async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (picked != null) {
    final int minute = (picked.minute / 15).round() * 15;
    
    // FIX: Handle the case where minute becomes 60
    int finalMinute = minute;
    int finalHour = picked.hour;
    
    if (minute == 60) {
      finalMinute = 0;
      finalHour = picked.hour + 1;
      
      // Check if hour becomes 24 (midnight) or beyond available hours
      if (finalHour >= 24 || !_availableHours.contains(finalHour)) {
        _showTimeError();
        return;
      }
    }
    
    final TimeOfDay roundedTime = TimeOfDay(hour: finalHour, minute: finalMinute);

    if (_availableHours.contains(roundedTime.hour)) {
      setState(() {
        _selectedTime = roundedTime;
      });
    } else {
      _showTimeError();
    }
  }
}
  void _showTimeError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a time between 6:00 AM and 8:00 PM"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _joinGame(GameViewModel gameViewModel) async {
    // ADD GUEST CHECK HERE TOO
    if (_isGuestUser()) {
      _showGuestUserError();
      return;
    }

    if (_selectedDate != null && _selectedTime != null) {
      final gameDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      try {
        await gameViewModel.joinGame(
          courtId: widget.court['place_id'] ?? '',
          courtName: widget.court['name'] ?? 'Unknown Court',
          gameDateTime: gameDateTime,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the game!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _joinExistingGame(GameViewModel gameViewModel, GameModel game) async {
    // ADD GUEST CHECK HERE TOO
    if (_isGuestUser()) {
      _showGuestUserError();
      return;
    }

    try {
      await gameViewModel.joinGame(
        courtId: game.courtId,
        courtName: game.courtName,
        gameDateTime: game.gameDateTime,
        maxPlayers: game.maxPlayers,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined the game!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _leaveGame(GameViewModel gameViewModel, String gameId) async {
    try {
      await gameViewModel.leaveGame(gameId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Left the game'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}