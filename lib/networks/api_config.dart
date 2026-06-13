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
  static const String userUpdate = '/user/update';

  // ── Tasks (RESTful resource) ──
  static const String tasks = '/tasks';
  static String taskById(int id) => '/tasks/$id';
  static String taskCheck(int id) => '/tasks/$id/check';

  // ── Coins ──
  static const String coinHistory = '/coins/history';
  static const String coinEarn = '/coins/earn';
  static const String coinSpend = '/coins/spend';

  // ── Puzzles ──
  static const String puzzles = '/puzzles';
  static const String puzzleUnlock = '/puzzles/unlock';

  // ── Notes ──
  static const String notes = '/notes';
  static const String noteCreate = '/notes/create';
  static const String noteUpdate = '/notes/update';
  static const String noteDelete = '/notes/delete';

  // ── Streak ──
  static const String streak = '/streak';
  static const String streakIncrement = '/streak/increment';

  // ── Trash ──
  static const String trash = '/trash';
  static const String trashRestore = '/trash/restore';
  static const String trashDelete = '/trash/delete';

  // ── Change Email / Password ──
  static const String changeEmail = '/user/change-email';
  static const String changePassword = '/user/change-password';

  // ── Settings ──
  static const String settings = '/user/settings';

  // ── Relax / Apps ──
  static const String apps = '/apps';

  // ── Rest Day ──
  static const String restDay = '/daily-record/rest-day';
}
