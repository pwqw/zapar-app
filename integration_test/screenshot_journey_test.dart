import 'package:app/app_providers.dart';
import 'package:app/env/integration_test_env.dart';
import 'package:app/main.dart';
import 'package:app/providers/providers.dart';
import 'package:app/ui/screens/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'support/screenshot_shell.dart';

/// Forces every [CachedNetworkImage] currently mounted to download and decode
/// before the next frame, then waits a few extra frames so the rasterizer
/// paints them. Returns once all precache futures complete.
Future<void> _precacheVisibleImagesAndSettle(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(seconds: 15));
    final BuildContext ctx = tester.element(find.byType(MainScreen));
    final List<Future<void>> futures = [];
    for (final Element el in find.byType(CachedNetworkImage).evaluate()) {
      final CachedNetworkImage w = el.widget as CachedNetworkImage;
      futures.add(
        precacheImage(CachedNetworkImageProvider(w.imageUrl), ctx)
            .catchError((_) {}),
      );
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
    // Extra margin so rasterizer paints the newly-available images.
    await Future<void>.delayed(const Duration(seconds: 3));
  });
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

/// Store listing journey: Home → Search → Library. Same steps for phone and
/// tablet; [FORM_FACTOR] prefixes screenshot names (`phone_`, `tablet_`).
///
/// When `SCREENSHOT_WITH_BACKEND=true`, authenticates against `KOEL_HOST`
/// with `KOEL_EMAIL`/`KOEL_PASSWORD` before pumping the widget tree so that
/// Home / Search / Library render real data.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshot journey', (WidgetTester tester) async {
    // Tablets arrancan en landscape; forzar portrait antes de cualquier render.
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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

      // Koel throttles /api/me. Retry w/ backoff for rate-limited CI runs.
      const List<int> backoffs = [0, 15, 30, 60, 90];
      Object? lastError;
      for (final int wait in backoffs) {
        if (wait > 0) {
          await Future<void>.delayed(Duration(seconds: wait));
        }
        try {
          await AuthProvider().login(
            host: kKoelHost,
            email: kKoelEmail,
            password: kKoelPassword,
          );
          lastError = null;
          break;
        } catch (e) {
          lastError = e;
          // ignore: avoid_print
          print('login attempt failed (waited ${wait}s): $e');
        }
      }
      if (lastError != null) throw lastError;
    }

    const Widget shell = ScreenshotShellApp(
      home: MainScreen(),
    );

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

    await _precacheVisibleImagesAndSettle(tester);

    await IntegrationTestWidgetsFlutterBinding.instance
        .convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    await IntegrationTestWidgetsFlutterBinding.instance
        .takeScreenshot('${prefix}01_home');

    await tester.tap(find.byKey(const ValueKey<String>('tab_search')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    if (kScreenshotWithBackend) {
      final Finder searchField = find.byType(CupertinoSearchTextField);
      expect(searchField, findsWidgets,
          reason: 'Search tab must show CupertinoSearchTextField');
      await tester.tap(searchField.first);
      await tester.pumpAndSettle();
      await tester.enterText(searchField.first, kScreenshotSearchTerm);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // searchExcerpts hits backend + CachedNetworkImage for result covers.
      await _precacheVisibleImagesAndSettle(tester);
    }

    await IntegrationTestWidgetsFlutterBinding.instance
        .takeScreenshot('${prefix}02_search');

    await tester.tap(find.byKey(const ValueKey<String>('tab_library')));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await IntegrationTestWidgetsFlutterBinding.instance
        .takeScreenshot('${prefix}03_library');
  });
}
