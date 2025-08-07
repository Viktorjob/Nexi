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
  final TextEditingController _controller = TextEditingController();
  late DatabaseReference _messagesRef;

  String get chatId {
    final ids = [widget.currentUserId, widget.friendUserId]..sort();
    return ids.join('_');
  }

  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseDatabase.instance.ref('chats/$chatId/messages');
    listenForIncomingCalls(widget.currentUserId);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = {
      'senderId': widget.currentUserId,
      'text': text,
      'timestamp': ServerValue.timestamp,
    };

    _messagesRef.push().set(message);
    _controller.clear();
  }
  void listenForIncomingCalls(String currentUserId) {
    FirebaseDatabase.instance
        .ref('calls/$currentUserId/offer')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        final callerId = data['callerId'];

        if (callerId == null || callerId is! String) {
          print('Error: callerId is missing or not a string');
          return;
        }

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
      appBar: AppBar(title: Text(widget.friendUsername),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.smart_toy_outlined),
              iconSize: 40.0,
              onPressed: () {
                ai_screen(context);
              },

            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              iconSize: 40.0,
              onPressed: () {
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
            child: StreamBuilder<DatabaseEvent>(
              stream: _messagesRef.orderByChild('timestamp').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No messages'));
                }

                final messagesMap = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                final messagesList = messagesMap.entries
                    .map((e) => {'key': e.key, ...Map<String, dynamic>.from(e.value)})
                    .toList();


                messagesList.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

                return ListView.builder(
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    final msg = messagesList[index];
                    final isMe = msg['senderId'] == widget.currentUserId;

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
