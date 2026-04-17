/// Environment-based configuration for TRISH app.
/// Set via --dart-define=ENV=prod at build time, defaults to 'dev'.
/// Usage: flutter run --dart-define=ENV=prod
const String _env = String.fromEnvironment('ENV', defaultValue: 'dev');
const String _apiUrlOverride = String.fromEnvironment('API_URL', defaultValue: '');
const String _wsUrlOverride = String.fromEnvironment('WS_URL', defaultValue: '');
const String _aiEngineUrlOverride = String.fromEnvironment('AI_ENGINE_URL', defaultValue: '');

class AppConfig {
  static const String env = _env;

  static bool get isProduction => env == 'prod';
  static bool get isDevelopment => env == 'dev';
  static bool get isStaging => env == 'staging';

  static String get apiUrl {
    if (_apiUrlOverride.trim().isNotEmpty) return _apiUrlOverride.trim();
    switch (env) {
      case 'prod':
        return 'https://api.trish.app';
      case 'staging':
        return 'https://api-staging.trish.app';
      default:
        return 'http://localhost:8080';
    }
  }

  static String get wsUrl {
    if (_wsUrlOverride.trim().isNotEmpty) return _wsUrlOverride.trim();
    final base = apiUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    return '$base/ws/chat';
  }

  static String get aiEngineUrl {
    if (_aiEngineUrlOverride.trim().isNotEmpty) return _aiEngineUrlOverride.trim();
    switch (env) {
      case 'prod':
        return 'https://ai.trish.app';
      case 'staging':
        return 'https://ai-staging.trish.app';
      default:
        return 'http://localhost:8000';
    }
  }
}

// Use getters for runtime config (backward compatible)
String get API_URL => AppConfig.apiUrl;
String get WS_URL => AppConfig.wsUrl;
