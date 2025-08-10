import 'package:flutter/material.dart';
import 'package:nexi/ui/function/friends_service.dart';


void showDeleteFriendDialog({
  required BuildContext context,
  required String currentUid,
  required Map<String, String> friend,
  required VoidCallback onDeleted,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove a friend'),
      // Treść dialogu z potwierdzeniem usunięcia przyjaciela po nazwie użytkownika
      content: Text('Delete ${friend['username']} from friends?'),
      actions: [
        TextButton(

          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();

            // Wywołanie metody usuwającej przyjaciela w bazie danych
            FriendService.deleteFriend(
              context: context,
              currentUid: currentUid,
              friendUid: friend['uid']!,
              onSuccess: onDeleted, // Callback do aktualizacji UI po usunięciu
            );
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
