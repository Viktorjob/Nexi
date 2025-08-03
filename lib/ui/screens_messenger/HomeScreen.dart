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
  StreamSubscription<List<Map<String, String>>>? _friendsSubscription;
  List<Map<String, String>> _friends = [];

  @override
  void initState() {
    super.initState();
    _friendsSubscription = FriendService.subscribeToFriendsStream(widget.user.uid).listen((friendsList) {
      if (mounted) {
        setState(() {
          _friends = friendsList;
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
    _friendsSubscription?.cancel();
    super.dispose();
  }


  void _showAddFriend() {
    showAddFriendDialog(
      context: context,
      friends: _friends,
      onFriendAdded: (friend) {

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
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddFriend,
          ),
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
            child: _friends.isEmpty
                ? const Center(child: Text('Friends not added'))
                : ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(friend['username'] ?? 'Unknown'),
                  onTap: () => _openFriendProfile(friend),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDeleteFriendDialog(
                        context: context,
                        currentUid: widget.user.uid,
                        friend: friend,
                        onDeleted: () {
                          setState(() {
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


