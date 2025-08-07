import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FriendService {

  static String getChatId(String uid1, String uid2) {
    final sortedUids = [uid1, uid2]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }

  static Future<void> deleteFriend({
    required BuildContext context,
    required String currentUid,
    required String friendUid,
    required VoidCallback onSuccess,
  }) async {
    try {
      final db = FirebaseDatabase.instance.ref();

      await db.child('userFriends/$currentUid/$friendUid').remove();
      await db.child('userFriends/$friendUid/$currentUid').remove();

      final chatId = getChatId(currentUid, friendUid);
      await db.child('chats/$chatId').remove();

      onSuccess();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend and chat deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error while deleting: $e')),
        );
      }
    }
  }


  static Future<void> addFriend({
    required BuildContext context,
    required String currentUid,
    required String friendUid,
    required List<Map<String, String>> existingFriends,
    required void Function(Map<String, String>) onSuccess,
  }) async {
    if (friendUid == currentUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot add yourself')),
      );
      return;
    }

    if (existingFriends.any((f) => f['uid'] == friendUid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The user is already in your friends list')),
      );
      return;
    }

    try {
      final db = FirebaseDatabase.instance.ref();
      final snapshot = await db.child('users/$friendUid').get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      final friendData = Map<String, dynamic>.from(snapshot.value as Map);
      final username = friendData['username'] ?? 'No name';


      await db.child('userFriends/$currentUid/$friendUid').set(true);
      await db.child('userFriends/$friendUid/$currentUid').set(true);

      onSuccess({'uid': friendUid, 'username': username});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend added: $username')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while adding: $e')),
      );
    }
  }


  static Future<List<Map<String, String>>> loadFriends({
    required String currentUid,
  }) async {
    final db = FirebaseDatabase.instance.ref();
    final friendsSnapshot = await db.child('userFriends/$currentUid').get();

    final List<Map<String, String>> friends = [];

    if (friendsSnapshot.exists) {
      final friendMap = Map<String, dynamic>.from(friendsSnapshot.value as Map);

      for (final friendUid in friendMap.keys) {
        final userSnapshot = await db.child('users/$friendUid').get();

        if (userSnapshot.exists) {
          final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
          final username = userData['username'] ?? 'No name';

          friends.add({'uid': friendUid, 'username': username});
        }
      }
    }

    return friends;
  }
  static Stream<List<Map<String, String>>> subscribeToFriendsStream(String currentUid) {
    final friendsRef = FirebaseDatabase.instance.ref().child('userFriends').child(currentUid);

    return friendsRef.onValue.asyncMap((event) async {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, String>> loadedFriends = [];

        for (final entry in data.entries) {
          final friendUid = entry.key as String;
          final friendSnapshot = await FirebaseDatabase.instance.ref().child('users').child(friendUid).get();

          if (friendSnapshot.exists && friendSnapshot.value != null) {
            final friendData = friendSnapshot.value as Map<dynamic, dynamic>;
            final username = friendData['username'] ?? 'No name';
            loadedFriends.add({'uid': friendUid, 'username': username});
          }
        }

        return loadedFriends;
      } else {
        return <Map<String, String>>[];
      }
    });
  }
}
