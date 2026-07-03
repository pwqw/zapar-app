import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<Uri?> materializeDefaultArtUri(String assetName) async {
  try {
    final content = await rootBundle.load(assetName);
    final bytes = content.buffer.asUint8List();
    final documentDir = await getApplicationDocumentsDirectory();
    final filePath = '${documentDir.path}/default-image.webp';

    return (await File(filePath).writeAsBytes(bytes)).uri;
  } catch (_) {
    return null;
  }
}
