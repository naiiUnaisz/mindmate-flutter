import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindmate/networks/api_config.dart';

String _fixAvatarUrl(String? url) {
  if (url == null || url.isEmpty) return url ?? '';
  if (url.startsWith('http://localhost') || url.startsWith('http://127.0.0.1')) {
    return url.replaceFirst(RegExp(r'^https?://(localhost|127\.0\.0\.1)(:\d+)?'),
        'https://unaisah-digitallab.my.id');
  }
  return url;
}

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

  static const _timeout = Duration(seconds: 20);

  Future<http.Response> _get(String path, {Map<String, String>? headers}) =>
      _client.get(_uri(path), headers: headers ?? _headers).timeout(_timeout);

  Future<http.Response> _post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) => _client
      .post(_uri(path), headers: headers ?? _headers, body: body)
      .timeout(_timeout);

  Future<http.Response> _put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) => _client
      .put(_uri(path), headers: headers ?? _headers, body: body)
      .timeout(_timeout);

  Future<http.Response> _delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) => _client
      .delete(_uri(path), headers: headers ?? _headers, body: body)
      .timeout(_timeout);

  Map<String, dynamic> _parseBody(http.Response res) {
    try {
      if (res.body.isEmpty) return {};
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'data': decoded};
      return {};
    } catch (_) {
      return {};
    }
  }

  // ── Auth ──
  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_email', email);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _post(
      ApiConfig.login,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = _parseBody(res);
    if (res.statusCode == 200 && body['access_token'] != null) {
      await saveToken(body['access_token'] as String);
      await _saveEmail(email);
    }
    if (body['user'] is Map && body['user']['avatar'] != null) {
      body['user']['avatar'] = _fixAvatarUrl(body['user']['avatar'] as String?);
    }
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await _post(
      ApiConfig.register,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'username': name}),
    );
    final body = _parseBody(res);
    if (res.statusCode == 201 && body['access_token'] != null) {
      await saveToken(body['access_token'] as String);
      await _saveEmail(email);
    }
    return {'status': res.statusCode, ...body};
  }

  Future<void> apiLogout() async {
    try {
      if (_token != null) {
        await _post(ApiConfig.logout);
      }
    } catch (_) {}
    await logout();
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _post(
      ApiConfig.forgotPassword,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> verifyCode(String code) async {
    final res = await _post(
      ApiConfig.verifyCode,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'code': code}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> resetPassword(
    String password,
    String confirmPassword,
  ) async {
    final res = await _post(
      ApiConfig.resetPassword,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
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
    final res = await _get(ApiConfig.user);
    final body = _parseBody(res);
    // Normalize response: unwrap from 'data' or 'user' keys if present
    final userData = body['data'] is Map
        ? body['data'] as Map<String, dynamic>
        : body['user'] is Map
        ? body['user'] as Map<String, dynamic>
        : body;
    if (userData['avatar'] != null) {
      userData['avatar'] = _fixAvatarUrl(userData['avatar'] as String?);
    }
    return {'status': _extractStatus(res.statusCode, body), 'user': userData};
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final res = await _get(ApiConfig.userProfile);
    final body = _parseBody(res);
    final data = body['data'];
    if (data is Map<String, dynamic> && data['avatar'] != null) {
      data['avatar'] = _fixAvatarUrl(data['avatar'] as String?);
    }
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String username = '',
    required String gender,
    required DateTime? dateOfBirth,
    String? avatar,
  }) async {
    final uri = _uri(ApiConfig.userUpdate);
    final request = http.MultipartRequest('PUT', uri);
    request.fields['name'] = name;
    request.fields['username'] = username;
    if (gender.isNotEmpty) request.fields['gender'] = gender.toLowerCase();
    
    if (dateOfBirth != null) {
      request.fields['birthday'] =
          '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}';
    }

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.headers['Accept'] = 'application/json';

    if (avatar != null && avatar.isNotEmpty && !avatar.startsWith('http')) {
      try {
        final bytes = base64Decode(avatar);
        request.files.add(http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      } catch (_) {}
    }

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    final result = _parseBody(res);
    
    final userData = result['data'] is Map
        ? result['data'] as Map<String, dynamic>
        : result;
    if (userData['avatar'] != null) {
      userData['avatar'] = _fixAvatarUrl(userData['avatar'] as String?);
    }
    return {'status': res.statusCode, 'user': userData, ...result};
  }

  /// Returns the int status from body if present, otherwise the HTTP status code.
  int _extractStatus(int httpStatus, Map<String, dynamic> body) {
    if (body['status'] is int) return body['status'] as int;
    return httpStatus;
  }

  /// Try to parse a numeric task ID. Returns null if the ID is not a valid int
  /// (e.g., a locally-generated UUID). Callers should skip the API call when null.
  int? _tryTaskId(String id) => int.tryParse(id);

  // ── Tasks ──
  Future<Map<String, dynamic>> getTasks() async {
    final res = await _get(ApiConfig.tasks);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> createTask(
    String title,
    String? description,
    DateTime deadline, {
    String taskType = 'puzzle',
  }) async {
    final res = await _post(
      ApiConfig.tasks,
      body: jsonEncode({
        'title': title,
        'description': description,
        'task_type': taskType,
      }),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> updateTask(
    String taskId,
    String title,
    String? description, {
    String? taskType,
  }) async {
    final id = _tryTaskId(taskId);
    if (id == null) return {'status': 400, 'message': 'Invalid task ID'};
    final body = <String, dynamic>{'title': title, 'description': description};
    if (taskType != null) body['task_type'] = taskType;
    final res = await _put(
      ApiConfig.taskById(id),
      body: jsonEncode(body),
    );
    final parsed = _parseBody(res);
    return {'status': res.statusCode, ...parsed};
  }

  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    final id = _tryTaskId(taskId);
    if (id == null) return {'status': 400, 'message': 'Invalid task ID'};
    final res = await _delete(ApiConfig.taskById(id));
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  /// Complete a task. The response includes coins_earned, current_coin_balance,
  /// current_streak, and source so the caller can update local state directly.
  Future<Map<String, dynamic>> completeTask(
    String taskId, {
    String source = 'puzzle',
  }) async {
    final id = _tryTaskId(taskId);
    if (id == null) return {'status': 400, 'message': 'Invalid task ID'};
    final res = await _post(
      ApiConfig.taskCheck(id),
      body: jsonEncode({'source': source}),
    );
    final body = _parseBody(res);
    return {
      'status': res.statusCode,
      ...body,
      // Normalise the response data into the top level for convenience
      if (body['data'] is Map<String, dynamic>)
        ..._extractCheckData(body['data'] as Map<String, dynamic>),
    };
  }

  Map<String, dynamic> _extractCheckData(Map<String, dynamic> data) {
    return {
      if (data['coins_earned'] != null) 'coins_earned': data['coins_earned'],
      if (data['current_coin_balance'] != null)
        'current_coin_balance': data['current_coin_balance'],
      if (data['current_streak'] != null)
        'current_streak': data['current_streak'],
      if (data['puzzle_opened'] != null) 'puzzle_opened': data['puzzle_opened'],
    };
  }

  // ── Coins ──
  Future<Map<String, dynamic>> getCoinHistory() async {
    final res = await _get(ApiConfig.coinHistory);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> earnCoins(int amount, String reason) async {
    final res = await _post(
      ApiConfig.coinEarn,
      body: jsonEncode({'amount': amount, 'reason': reason}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> spendCoins(int amount, String reason) async {
    final res = await _post(
      ApiConfig.coinSpend,
      body: jsonEncode({'amount': amount, 'reason': reason}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Notes ──
  Future<Map<String, dynamic>> getNotes() async {
    final res = await _get(ApiConfig.notes);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> createNote(String title, String content, {String tab = 'todo'}) async {
    final res = await _post(
      ApiConfig.notes,
      body: jsonEncode({'title': title, 'content': content, 'tab': tab}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> updateNote(String id, String title, String content, {bool? isCompleted}) async {
    final nid = int.tryParse(id);
    final path = nid != null ? ApiConfig.notes + '/$nid' : ApiConfig.notes + '/$id';
    final body = <String, dynamic>{'title': title, 'content': content};
    if (isCompleted != null) body['is_completed'] = isCompleted;
    final res = await _put(
      path,
      body: jsonEncode(body),
    );
    final parsed = _parseBody(res);
    return {'status': res.statusCode, ...parsed};
  }

  Future<Map<String, dynamic>> deleteNote(String id) async {
    final nid = int.tryParse(id);
    final path = nid != null ? ApiConfig.notes + '/$nid' : ApiConfig.notes + '/$id';
    final res = await _delete(path);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }
Future<Map<String, dynamic>> getPuzzles() async {
    final res = await _get(ApiConfig.puzzles);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> unlockPuzzle() async {
    final res = await _post(ApiConfig.puzzleUnlock);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Streak ──
  Future<Map<String, dynamic>> getStreak() async {
    final res = await _get(ApiConfig.streak);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> incrementStreak() async {
    final res = await _post(ApiConfig.streakIncrement);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Change Email / Password ──
  Future<Map<String, dynamic>> changeEmail(
    String currentEmail,
    String newEmail,
    String confirmEmail,
  ) async {
    final res = await _post(
      ApiConfig.changeEmail,
      body: jsonEncode({
        'email': newEmail,
      }),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final res = await _post(
      ApiConfig.changePassword,
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Settings ──
  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    final res = await _post(ApiConfig.settings, body: jsonEncode(settings));
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Relax / Apps ──
  Future<Map<String, dynamic>> getApps() async {
    final res = await _get(ApiConfig.apps);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> purchaseApp(int id) async {
    final res = await _post(ApiConfig.purchaseApp(id));
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }
  
  Future<Map<String, dynamic>> startRelaxSession(int appId, int duration) async {
    final res = await _post(
      ApiConfig.relaxSessionStart,
      body: jsonEncode({'app_id': appId, 'duration': duration}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> endRelaxSession(int sessionId, int lateMinutes) async {
    final res = await _post(
      ApiConfig.relaxSessionEnd,
      body: jsonEncode({'session_id': sessionId, 'late_minutes': lateMinutes}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> getActiveSession() async {
    final res = await _get(ApiConfig.relaxSessionActive);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> getSessionHistory({int page = 1}) async {
    final res = await _get('${ApiConfig.relaxSessionHistory}?page=$page');
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> completeAppSession() async {
    final res = await _post(ApiConfig.appsComplete);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }


  // ── Daily Record ──
  Future<Map<String, dynamic>> getDailyRecord() async {
    final res = await _get(ApiConfig.dailyRecord);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Mood ──
  Future<Map<String, dynamic>> submitMood(String mood, String date) async {
    // Backend expects 'mood_level' with 'neutral' instead of 'normal'
    String apiMood = mood;
    if (apiMood == 'normal') apiMood = 'neutral';
    final res = await _post(
      ApiConfig.mood,
      body: jsonEncode({'mood_level': apiMood}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  Future<Map<String, dynamic>> getMoodHistory() async {
    final res = await _get(ApiConfig.moodHistory);
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  // ── Rest Day ──
  Future<Map<String, dynamic>> restDay(String date) async {
    final res = await _post(
      ApiConfig.restDay,
      body: jsonEncode({'date': date}),
    );
    final body = _parseBody(res);
    return {'status': res.statusCode, ...body};
  }

  void dispose() => _client.close();
}
