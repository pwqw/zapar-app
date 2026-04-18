import 'package:flutter/foundation.dart';

/// Reemplazo seguro para [Platform.isIOS] de `dart:io` (no disponible en web).
bool get isIOSDevice =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
