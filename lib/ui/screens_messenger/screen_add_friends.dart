import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexi/ui/function/friends_service.dart';


void showAddFriendDialog({
  required BuildContext context,
  required List<Map<String, String>> friends,
  required void Function(Map<String, String>) onFriendAdded,
}) {
  final TextEditingController uidController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser; // Pobranie aktualnie zalogowanego użytkownika

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Add friend by UID'),
        content: TextField(
          controller: uidController,
          decoration: const InputDecoration(hintText: 'Enter friend`s UID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final friendUid = uidController.text.trim(); // Pobiera i oczyszcza wpisane UID

              // Sprawdza, czy UID nie jest puste i czy użytkownik jest zalogowany
              if (friendUid.isNotEmpty && currentUser != null) {
                Navigator.of(ctx).pop();

                // Wywołanie funkcji dodającej przyjaciela
                await FriendService.addFriend(
                  context: context,
                  currentUid: currentUser.uid,
                  friendUid: friendUid,
                  existingFriends: friends,
                  onSuccess: onFriendAdded,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
