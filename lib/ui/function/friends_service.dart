import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FriendService {

  // Generuje unikalne ID czatu na podstawie dwóch identyfikatorów użytkowników.
  // Sortuje UID alfabetycznie i łączy je podkreślnikiem.
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

      // Usunięcie czatu powiązanego z tymi użytkownikami
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

  // Dodaje nowego przyjaciela do listy znajomych.
  // Sprawdza, czy użytkownik nie próbuje dodać siebie lub czy już nie jest znajomym.
  // Pobiera dane użytkownika z bazy, dodaje relację w 'userFriends' i wywołuje [onSuccess].
  // Pokazuje komunikaty o sukcesie lub błędach.
  static Future<void> addFriend({
    required BuildContext context,
    required String currentUid,
    required String friendUid,
    required List<Map<String, String>> existingFriends,
    required void Function(Map<String, String>) onSuccess,
  }) async {
    // Nie pozwala dodać siebie samego jako przyjaciela
    if (friendUid == currentUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot add yourself')),
      );
      return;
    }

    // Sprawdza, czy użytkownik już jest na liście znajomych
    if (existingFriends.any((f) => f['uid'] == friendUid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The user is already in your friends list')),
      );
      return;
    }

    try {
      final db = FirebaseDatabase.instance.ref();
      // Pobiera dane potencjalnego przyjaciela z bazy
      final snapshot = await db.child('users/$friendUid').get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      final friendData = Map<String, dynamic>.from(snapshot.value as Map);
      final username = friendData['username'] ?? 'No name';

      // Dodaje wpisy relacji przyjaźni dla obu użytkowników
      await db.child('userFriends/$currentUid/$friendUid').set(true);
      await db.child('userFriends/$friendUid/$currentUid').set(true);

      // Wywołuje callback z informacjami o nowym przyjacielu
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

  // Ładuje listę przyjaciół aktualnego użytkownika z bazy Firebase.
  // Pobiera dane każdego znajomego (UID i username) i zwraca listę map.
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

  // Subskrybuje strumień zmian listy przyjaciół użytkownika w czasie rzeczywistym.
  // Za każdym razem, gdy dane ulegają zmianie, pobiera aktualną listę przyjaciół wraz z ich nazwami.
  static Stream<List<Map<String, String>>> subscribeToFriendsStream(String currentUid) {
    final friendsRef = FirebaseDatabase.instance.ref().child('userFriends').child(currentUid);

    return friendsRef.onValue.asyncMap((event) async {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, String>> loadedFriends = [];

        // Dla każdego UID przyjaciela pobiera jego dane z bazy
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
