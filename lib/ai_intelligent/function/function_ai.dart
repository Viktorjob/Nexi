
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexi/api_keys.dart';

Future<String> askAI(String prompt) async {


  final response = await http.post(
    Uri.parse('https://api.deepseek.com/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': 'deepseek-chat',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': 0.7,
      'max_tokens': 8192,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'].toString().trim();
  } else {
    throw Exception('AI request failed: ${response.statusCode}');
  }
}
