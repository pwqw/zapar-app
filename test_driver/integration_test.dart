import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver that persists [IntegrationTestWidgetsFlutterBinding.takeScreenshot]
/// bytes to `integration_test/screenshots/<name>.png` on the host machine.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final File file = File('integration_test/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
