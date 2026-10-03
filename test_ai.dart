import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'YOUR_API_KEY_HERE';
  final response = await http.post(
    Uri.parse('https://api.anthropic.com/v1/messages'),
    headers: {
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: jsonEncode({
      'model': 'claude-3-haiku-20240307',
      'max_tokens': 100,
      'messages': [{'role': 'user', 'content': 'Test'}]
    })
  );
  print('STATUS: ${response.statusCode}');
  print('BODY: ${response.body}');
}
