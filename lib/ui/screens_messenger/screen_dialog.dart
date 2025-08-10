import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nexi/ai_intelligent/screen/ai_screen.dart';
import 'package:nexi/camera/ui_camera/ui_camera.dart';
import 'package:nexi/ui/screens_messenger/screen_add_friends.dart';


class FriendProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String friendUserId;
  final String friendUsername;

  const FriendProfileScreen({
    super.key,
    required this.currentUserId,
    required this.friendUserId,
    required this.friendUsername,
  });

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  final TextEditingController _controller = TextEditingController(); // Kontroler do pola tekstowego wiadomości
  late DatabaseReference _messagesRef; // Referencja do bazy danych Firebase dla wiadomości

  // Generuje unikalny chatId na podstawie UID użytkownika i przyjaciela.
  String get chatId {
    final ids = [widget.currentUserId, widget.friendUserId]..sort();
    return ids.join('_'); // Łączy UID posortowane alfabetycznie, aby chatId był identyczny dla obu użytkowników
  }

  @override
  void initState() {
    super.initState();
    // Ustawienie referencji do wiadomości w Firebase Realtime Database
    _messagesRef = FirebaseDatabase.instance.ref('chats/$chatId/messages');

    // Nasłuchiwanie połączeń przychodzących dla bieżącego użytkownika
    listenForIncomingCalls(widget.currentUserId);
  }

  // Wysyła wiadomość do bazy danych.
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return; // Jeśli tekst jest pusty, nie wysyłaj

    final message = {
      'senderId': widget.currentUserId,
      'text': text,
      'timestamp': ServerValue.timestamp, // Serwerowy timestamp dla synchronizacji
    };

    _messagesRef.push().set(message); // Dodanie nowej wiadomości do bazy
    _controller.clear(); // Czyszczenie pola tekstowego po wysłaniu
  }

  // Nasłuchiwanie na połączenia przychodzące (np. video call)
  void listenForIncomingCalls(String currentUserId) {
    FirebaseDatabase.instance
        .ref('calls/$currentUserId/offer')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        final callerId = data['callerId'];

        // Sprawdzenie poprawności danych
        if (callerId == null || callerId is! String) {
          print('Error: callerId is missing or not a string');
          return;
        }

        // Przejście do ekranu kamery jako odbiorca połączenia
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UiCamera(
              currentUserId: currentUserId,
              remoteUserId: callerId,
              isCaller: false,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendUsername), // Wyświetlenie nazwy przyjaciela w tytule
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.smart_toy_outlined),
              iconSize: 40.0,
              onPressed: () {
                ai_screen(context); // Przejście do ekranu AI
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              iconSize: 40.0,
              onPressed: () {
                // Przejście do ekranu kamery i rozpoczęcie połączenia jako inicjator
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UiCamera(
                      currentUserId: widget.currentUserId,
                      remoteUserId: widget.friendUserId,
                      isCaller: true,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // StreamBuilder do wyświetlania listy wiadomości na żywo
            child: StreamBuilder<DatabaseEvent>(
              stream: _messagesRef.orderByChild('timestamp').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No messages'));
                }

                // Pobranie wiadomości z bazy i konwersja na listę
                final messagesMap = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                final messagesList = messagesMap.entries
                    .map((e) => {'key': e.key, ...Map<String, dynamic>.from(e.value)})
                    .toList();

                // Sortowanie wiadomości po czasie wysłania
                messagesList.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

                return ListView.builder(
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    final msg = messagesList[index];
                    final isMe = msg['senderId'] == widget.currentUserId; // Sprawdzenie czy wiadomość jest od nas

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  // Pole tekstowe do wpisywania wiadomości
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Write a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
