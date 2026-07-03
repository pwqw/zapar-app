/// Compile-time flags for integration / screenshot tests (`--dart-define`).

/// When true, [OverviewProvider.refresh] skips HTTP so tests can pump
/// [MainScreen] without a Koel backend.
const bool kIntegrationTestSkipOverviewNetwork = bool.fromEnvironment(
  'INTEGRATION_TEST',
  defaultValue: false,
);

/// When true, the screenshot journey test logs in against a real Koel backend
/// using [kKoelHost] / [kKoelEmail] / [kKoelPassword] and loads real data.
const bool kScreenshotWithBackend = bool.fromEnvironment(
  'SCREENSHOT_WITH_BACKEND',
  defaultValue: false,
);

const String kKoelHost = String.fromEnvironment('KOEL_HOST', defaultValue: '');
const String kKoelEmail =
    String.fromEnvironment('KOEL_EMAIL', defaultValue: '');
const String kKoelPassword =
    String.fromEnvironment('KOEL_PASSWORD', defaultValue: '');

const String kScreenshotSearchTerm =
    String.fromEnvironment('SCREENSHOT_SEARCH_TERM', defaultValue: 'zamba');
