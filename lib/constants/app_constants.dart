class AppConstants {
  static const String appName = 'HieroVision';
  static const String appVersion = '1.0.0';
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // API endpoints
  static const String baseUrl = 'https://api.hierovision.com';
  
  // Asset paths
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String errorAnimation = 'assets/animations/error.json';
  static const String successAnimation = 'assets/animations/success.json';
  
  // Shared preferences keys
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String firstRunKey = 'first_run';
  
  // Default values
  static const String defaultLanguage = 'en';
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  
  // Error messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String permissionErrorMessage = 'Please grant the required permissions to continue.';
} 