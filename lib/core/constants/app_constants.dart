class AppConstants {
  static const String appName = 'Expense Tracker';
  static const String currency = '\$';
  
  // Database
  static const String dbName = 'expense_tracker.db';
  static const int dbVersion = 3;
  
  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String userKey = 'user_data';
  static const String authTokenKey = 'auth_token';
  
  // Animation Duration
  static const Duration defaultDuration = Duration(milliseconds: 300);
  
  // Pagination
  static const int pageSize = 20;
}
