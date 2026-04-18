class AppStrings {
  AppStrings._();

  static const String appName = 'Koel';

  /// Web OAuth Client ID — audience for the id_token. Not a secret (same as web app).
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
}
