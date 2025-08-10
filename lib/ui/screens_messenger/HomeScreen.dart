import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexi/menu_drawer/menu_drawer.dart';
import 'package:nexi/ui/function/friends_service.dart';
import 'package:nexi/ui/screens_messenger/screen_delete_friends.dart';
import 'package:nexi/ui/screens_messenger/screen_dialog.dart';
import 'screen_add_friends.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Subskrypcja na strumień listy przyjaciół
  StreamSubscription<List<Map<String, String>>>? _friendsSubscription;
  // Aktualna lista przyjaciół przechowywana lokalnie
  List<Map<String, String>> _friends = [];

  @override
  void initState() {
    super.initState();
    // Nasłuchujemy zmian w liście przyjaciół w czasie rzeczywistym
    _friendsSubscription = FriendService.subscribeToFriendsStream(widget.user.uid).listen((friendsList) {
      if (mounted) {
        setState(() {
          _friends = friendsList; // Aktualizacja lokalnej listy przyjaciół
        });
      }
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // Otwiera profil wybranego przyjaciela (przechodzi do nowego ekranu)
  void _openFriendProfile(Map<String, String> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendProfileScreen(
          currentUserId: widget.user.uid,
          friendUserId: friend['uid']!,
          friendUsername: friend['username']!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Anulujemy subskrypcję przy zamykaniu widgetu, aby uniknąć wycieków pamięci
    _friendsSubscription?.cancel();
    super.dispose();
  }

  // Pokazuje dialog dodawania nowego przyjaciela
  void _showAddFriend() {
    showAddFriendDialog(
      context: context,
      friends: _friends,
      onFriendAdded: (friend) {
        // Tutaj możesz dodać dodatkową logikę po dodaniu przyjaciela
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: true,
        actions: [
          // Przycisk otwierający dialog dodawania przyjaciela
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddFriend,
          ),
          // Przycisk wylogowania
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: AppDrawer(uid: widget.user.uid),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Friends list:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            // Jeśli lista przyjaciół jest pusta, wyświetlamy komunikat
            child: _friends.isEmpty
                ? const Center(child: Text('Friends not added'))
            // W przeciwnym razie lista przyjaciół w formie ListView
                : ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(friend['username'] ?? 'Unknown'),
                  // Kliknięcie na element otwiera profil przyjaciela
                  onTap: () => _openFriendProfile(friend),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Pokazuje dialog potwierdzający usunięcie przyjaciela
                      showDeleteFriendDialog(
                        context: context,
                        currentUid: widget.user.uid,
                        friend: friend,
                        onDeleted: () {
                          setState(() {
                            // Usunięcie przyjaciela z lokalnej listy po potwierdzeniu
                            _friends.removeWhere(
                                    (f) => f['uid'] == friend['uid']);
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
