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
      title: const Text('Удалить друга'),
      content: Text('Удалить ${friend['username']} из друзей?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();

            FriendService.deleteFriend(
              context: context,
              currentUid: currentUid,
              friendUid: friend['uid']!,
              onSuccess: onDeleted,
            );
          },
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
}
