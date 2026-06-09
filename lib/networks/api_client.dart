import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:application_belajar/networks/api_config.dart';


class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  final http.Client _client = http.Client();
  String? _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  bool get isLoggedIn => _token != null;

  String? get token => _token;

  Future<void> saveToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, dynamic> _parseBody(http.Response res) =>
      jsonDecode(res.body) as Map<String, dynamic>;

  // ── Auth ──
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.post(
      _uri(ApiConfig.login),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = _parseBody(res);
    if (res.statusCode == 200 && body['access_token'] != null) {
      await saveToken(body['access_token'] as String);
    }
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await _client.post(
      _uri(ApiConfig.register),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    final body = _parseBody(res);
    if (res.statusCode == 201 && body['access_token'] != null) {
      await saveToken(body['access_token'] as String);
    }
    return {'status': res.statusCode, ...body};
  }

  Future<void> apiLogout() async {
    if (_token != null) {
      await _client.post(
        _uri(ApiConfig.logout),
        headers: _headers,
      );
    }
    await logout();
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _client.post(
      _uri(ApiConfig.forgotPassword),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> verifyCode(String code) async {
    final res = await _client.post(
      _uri(ApiConfig.verifyCode),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'code': code}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> resetPassword(
      String password, String confirmPassword) async {
    final res = await _client.post(
      _uri(ApiConfig.resetPassword),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── User / Profile ──
  Future<Map<String, dynamic>> getUser() async {
    final res = await _client.get(
      _uri(ApiConfig.user),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, 'user': body};
  }

  // ── Tasks ──
  Future<Map<String, dynamic>> getTasks() async {
    final res = await _client.get(
      _uri(ApiConfig.tasks),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> createTask(
      String title, String? description, DateTime deadline) async {
    final res = await _client.post(
      _uri(ApiConfig.tasks),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'description': description,
      }),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> updateTask(
      String taskId, String title, String? description) async {
    final res = await _client.put(
      _uri(ApiConfig.taskById(int.parse(taskId))),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'description': description,
      }),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    final res = await _client.delete(
      _uri(ApiConfig.taskById(int.parse(taskId))),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> completeTask(String taskId) async {
    final res = await _client.post(
      _uri(ApiConfig.taskCheck(int.parse(taskId))),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Coins ──
  Future<Map<String, dynamic>> getCoinHistory() async {
    final res = await _client.get(
      _uri(ApiConfig.coinHistory),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> earnCoins(int amount, String reason) async {
    final res = await _client.post(
      _uri(ApiConfig.coinEarn),
      headers: _headers,
      body: jsonEncode({'amount': amount, 'reason': reason}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> spendCoins(int amount, String reason) async {
    final res = await _client.post(
      _uri(ApiConfig.coinSpend),
      headers: _headers,
      body: jsonEncode({'amount': amount, 'reason': reason}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Puzzles ──
  Future<Map<String, dynamic>> getPuzzles() async {
    final res = await _client.get(
      _uri(ApiConfig.puzzles),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> unlockPuzzle(String puzzleId, int cost) async {
    final res = await _client.post(
      _uri(ApiConfig.puzzleUnlock),
      headers: _headers,
      body: jsonEncode({'puzzle_id': puzzleId, 'cost': cost}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Notes ──
  Future<Map<String, dynamic>> getNotes() async {
    final res = await _client.get(
      _uri(ApiConfig.notes),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> createNote(String title, String content) async {
    final res = await _client.post(
      _uri(ApiConfig.noteCreate),
      headers: _headers,
      body: jsonEncode({'title': title, 'content': content}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> updateNote(
      String noteId, String title, String content) async {
    final res = await _client.put(
      _uri(ApiConfig.noteUpdate),
      headers: _headers,
      body: jsonEncode({'id': noteId, 'title': title, 'content': content}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> deleteNote(String noteId) async {
    final res = await _client.delete(
      _uri(ApiConfig.noteDelete),
      headers: _headers,
      body: jsonEncode({'id': noteId}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Streak ──
  Future<Map<String, dynamic>> getStreak() async {
    final res = await _client.get(
      _uri(ApiConfig.streak),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> incrementStreak() async {
    final res = await _client.post(
      _uri(ApiConfig.streakIncrement),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Trash ──
  Future<Map<String, dynamic>> getTrash() async {
    final res = await _client.get(
      _uri(ApiConfig.trash),
      headers: _headers,
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> restoreFromTrash(String taskId) async {
    final res = await _client.post(
      _uri(ApiConfig.trashRestore),
      headers: _headers,
      body: jsonEncode({'id': taskId}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> deleteFromTrash(String taskId) async {
    final res = await _client.delete(
      _uri(ApiConfig.trashDelete),
      headers: _headers,
      body: jsonEncode({'id': taskId}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  void dispose() => _client.close();
}
