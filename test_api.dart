import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final baseUrl = 'https://unaisah-digitallab.my.id/api';
  
  final email = 'test_api_${DateTime.now().millisecondsSinceEpoch}@test.com';
  final regRes = await http.post(
    Uri.parse('$baseUrl/register'),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: jsonEncode({
      'username': 'TestUser_',
      'email': email,
      'password': 'password',
      'password_confirmation': 'password'
    }),
  );
  
  if (regRes.statusCode != 200 && regRes.statusCode != 201) {
    print('Failed to register: ${regRes.body}');
    return;
  }
  final regData = jsonDecode(regRes.body);
  final token = regData['access_token'];
  
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  print('\nTesting Puzzles...');
  final puzzleHist = await http.get(Uri.parse('$baseUrl/puzzles'), headers: headers);
  print('Puzzles Status: ${puzzleHist.statusCode}');
  print('Puzzles Body: ${puzzleHist.body}');

  print('\nTesting Coins...');
  final coinHist = await http.get(Uri.parse('$baseUrl/coins/history'), headers: headers);
  print('Coins Status: ${coinHist.statusCode}');
  print('Coins Body: ${coinHist.body}');

  print('\nTesting Tasks...');
  final taskHist = await http.get(Uri.parse('$baseUrl/tasks'), headers: headers);
  print('Tasks Status: ${taskHist.statusCode}');
  print('Tasks Body: ${taskHist.body}');
  
  print('\nTesting Mood...');
  final moodHist = await http.get(Uri.parse('$baseUrl/mood/history'), headers: headers);
  print('Mood Status: ${moodHist.statusCode}');
  print('Mood Body: ${moodHist.body}');
}
