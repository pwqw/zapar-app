import 'package:app/constants/constants.dart';
import 'package:app/ui/app.dart';
import 'package:app/ui/theme_data.dart';
import 'package:app/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// [MaterialApp] shell matching production theme/l10n, with an explicit [home]
/// so integration tests skip [InitialScreen] / login / loading.
///
/// When built with `--dart-define=SCREENSHOT_MODE=true`, matches [App] stability
/// tweaks (text scale, [TickerMode] applied by the test harness).
class ScreenshotShellApp extends StatelessWidget {
  const ScreenshotShellApp({
    Key? key,
    required this.home,
  }) : super(key: key);

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return Material(
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
          home: home,
          builder: (context, child) {
            final Widget content = child ?? const SizedBox.shrink();
            if (!App.kScreenshotMode) {
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
  }
}
