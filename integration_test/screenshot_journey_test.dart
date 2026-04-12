import 'package:app/app_providers.dart';
import 'package:app/env/integration_test_env.dart';
import 'package:app/main.dart';
import 'package:app/providers/providers.dart';
import 'package:app/ui/app.dart';
import 'package:app/ui/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'support/screenshot_shell.dart';

/// Store listing journey: Home → Search → Library. Same steps for phone and
/// tablet; [FORM_FACTOR] prefixes screenshot names (`phone_`, `tablet_`).
///
/// When `SCREENSHOT_WITH_BACKEND=true`, authenticates against `KOEL_HOST`
/// with `KOEL_EMAIL`/`KOEL_PASSWORD` before pumping the widget tree so that
/// Home / Search / Library render real data.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshot journey', (WidgetTester tester) async {
    const String formFactor = String.fromEnvironment(
      'FORM_FACTOR',
      defaultValue: 'phone',
    );
    final String prefix = '${formFactor}_';

    await bootstrapKoelApplication();

    if (kScreenshotWithBackend) {
      assert(kKoelHost.isNotEmpty, 'KOEL_HOST required');
      assert(kKoelEmail.isNotEmpty, 'KOEL_EMAIL required');
      assert(kKoelPassword.isNotEmpty, 'KOEL_PASSWORD required');

      await AuthProvider().login(
        host: kKoelHost,
        email: kKoelEmail,
        password: kKoelPassword,
      );
    }

    Widget shell = const ScreenshotShellApp(
      home: MainScreen(),
    );
    if (App.kScreenshotMode) {
      shell = TickerMode(
        enabled: false,
        child: shell,
      );
    }

    await tester.pumpWidget(
      MultiProvider(
        providers: buildKoelSingleChildProviders(),
        child: shell,
      ),
    );

    if (kScreenshotWithBackend) {
      final BuildContext ctx = tester.element(find.byType(MainScreen));
      await ctx.read<DataProvider>().init();
    }

    await tester.pumpAndSettle(const Duration(seconds: 30));

    await IntegrationTestWidgetsFlutterBinding.instance
        .takeScreenshot('${prefix}01_home');

    await tester.tap(find.byKey(const ValueKey<String>('tab_search')));
    await tester.pumpAndSettle(const Duration(seconds: 15));

    if (kScreenshotWithBackend) {
      final Finder searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, kScreenshotSearchTerm);
        await tester.pumpAndSettle(const Duration(seconds: 10));
      }
    }

    await IntegrationTestWidgetsFlutterBinding.instance
        .takeScreenshot('${prefix}02_search');

    await tester.tap(find.byKey(const ValueKey<String>('tab_library')));
    await tester.pumpAndSettle(const Duration(seconds: 15));
    await IntegrationTestWidgetsFlutterBinding.instance
        .takeScreenshot('${prefix}03_library');
  });
}
