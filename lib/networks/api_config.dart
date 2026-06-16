class ApiConfig {
  static const String baseUrl = 'https://unaisah-digitallab.my.id/api';

  // ── Auth ──
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String resetPassword = '/reset-password';

  // ── User / Profile ──
  static const String user = '/user';
  static const String userUpdate = '/user/profile';
  static const String userProfile = '/user/profile';

  // ── Tasks (RESTful resource) ──
  static const String tasks = '/tasks';
  static String taskById(int id) => '/tasks/$id';
  static String taskCheck(int id) => '/tasks/$id/check';

  // ── Coins ──
  static const String coinHistory = '/coin-histori';
  static const String coinEarn = '/coins/earn';
  static const String coinSpend = '/coins/spend';

  // ── Puzzles ──
  static const String puzzles = '/puzzles';
  static const String puzzleUnlock = '/puzzles/unlock';

  // ── Streak ──
  static const String streak = '/streak';
  static const String streakIncrement = '/streak/increment';

  // ── Change Email / Password ──
  static const String changeEmail = '/user/change-email';
  static const String changePassword = '/user/change-password';

  // ── Settings ──
  static const String settings = '/user/settings';

  // ── Relax / Apps ──
  static const String apps = '/apps';
  static String purchaseApp(int id) => '/apps/$id/purchase';
  static const String relaxSessionStart = '/relax/session/start';
  static const String relaxSessionEnd = '/relax/session/end';
  static const String relaxSessionActive = '/relax/session/active';
  static const String relaxSessionHistory = '/relax/session/history';
  static const String appsComplete = '/apps/complete';

  // ── Rest Day ──
  static const String restDay = '/daily-record/rest-day';

  // ── Daily Record ──
  static const String dailyRecord = '/daily-record';

  // ── Mood ──
  static const String mood = '/daily-record/mood';
  static const String moodHistory = '/mood/history';

  // ── Notes ──
  static const String notes = '/notes';
}
