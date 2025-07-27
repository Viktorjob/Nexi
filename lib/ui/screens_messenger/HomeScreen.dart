import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _friends = [];

  void _showAddFriendDialog() {
    final TextEditingController uidController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить друга'),
          content: TextField(
            controller: uidController,
            decoration: const InputDecoration(hintText: 'Введите UID'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final uid = uidController.text.trim();
                if (uid.isNotEmpty && !_friends.contains(uid)) {
                  setState(() {
                    _friends.add(uid);
                  });
                }
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    // Здесь можно добавить логику выхода из аккаунта
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add), // Иконка "Добавить друга"
            onPressed: _showAddFriendDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Список друзей:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: _friends.isEmpty
                ? const Center(child: Text('Друзья не добавлены'))
                : ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(_friends[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
