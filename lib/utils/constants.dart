class AppConstants {
  // Puzzle
  static const int maxDailyPuzzleTasks = 6;
  static const int baseCoinReward = 25;
  static const int completionBonus = 100;

  // Relax
  static const int defaultRelaxDuration = 30; // minutes
  static const int relaxPenaltyPerMinute = 5; // coins lost per minute overtime

  // Animations
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration longDuration = Duration(milliseconds: 1000);

  // Strings
  static const String appName = 'Mindmate';
  static const String appTagline = 'Learn with Fun';
}
