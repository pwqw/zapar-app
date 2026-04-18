import 'package:app/constants/constants.dart';
import 'package:app/router.dart';
import 'package:app/services/log_service.dart';
import 'package:app/ui/screens/screens.dart';
import 'package:app/ui/theme_data.dart';
import 'package:app/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class _AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    LogService.instance.setCurrentScreen(route.settings.name ?? 'unknown');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    LogService.instance.setCurrentScreen(previousRoute?.settings.name ?? 'unknown');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      LogService.instance.setCurrentScreen(newRoute.settings.name ?? 'unknown');
    }
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  /// UI más estable para capturas (`--dart-define=SCREENSHOT_MODE=true`).
  static const bool kScreenshotMode = bool.fromEnvironment(
    'SCREENSHOT_MODE',
    defaultValue: false,
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    Widget tree = Material(
      color: Colors.transparent,
      child: GradientDecoratedContainer(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: themeData(context),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: InitialScreen.routeName,
          routes: AppRouter.routes,
          navigatorObservers: <NavigatorObserver>[_AppRouteObserver()],
          builder: (context, child) {
            final Widget content = child ?? const SizedBox.shrink();
            if (!kScreenshotMode) {
              return content;
            }
            final MediaQueryData mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(textScaler: const TextScaler.linear(1)),
              child: content,
            );
          },
        ),
      ),
    );

    if (kScreenshotMode) {
      tree = TickerMode(
        enabled: false,
        child: tree,
      );
    }

    return tree;
  }
}
