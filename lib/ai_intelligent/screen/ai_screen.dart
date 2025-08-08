import 'package:flutter/material.dart';
import 'package:nexi/ai_intelligent/function/function_ai.dart';

void ai_screen(BuildContext context) {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> sendMessage() async {
            final input = messageController.text.trim();
            if (input.isEmpty) return;

            setState(() {
              messages.add({'role': 'user', 'text': input});
              messageController.clear();
              isLoading = true;
            });

            try {
              final aiResponse = await askAI(input);
              setState(() {
                messages.add({'role': 'ai', 'text': aiResponse});
                isLoading = false;
              });

              // Прокрутка вниз
              await Future.delayed(const Duration(milliseconds: 100));
              if (scrollController.hasClients) {
                scrollController.jumpTo(scrollController.position.maxScrollExtent);
              }
            } catch (e) {
              setState(() {
                messages.add({
                  'role': 'ai',
                  'text': 'Error: ${e.toString()}'
                });
                isLoading = false;
              });
            }
          }

          return AlertDialog(
            title: const Text('AI Chat Assistant'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg['role'] == 'user';

                        return Align(
                          alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(msg['text'] ?? ''),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: 'Enter message...',
                          ),
                          onSubmitted: (_) => sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: sendMessage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}
