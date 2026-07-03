import 'package:flutter/cupertino.dart';

import 'package:app/utils/default_art_uri_io.dart'
    if (dart.library.html) 'package:app/utils/default_art_uri_web.dart' as impl;

class AppImages {
  AppImages._();

  static const defaultImageAssetName = 'assets/images/default-image.webp';
  static Uri? _defaultArtUri;

  static const defaultImage = const Image(
    image: AssetImage(defaultImageAssetName),
  );

  // audio_service doesn't directly support `asset://` URIs, so we need to
  // convert the asset to a file and use a `file://` URI instead.
  // See: https://github.com/ryanheise/audio_service/issues/523
  // Web: no dart:io File — notification art URI is omitted.
  static Future<Uri?> getDefaultArtUri() async {
    if (_defaultArtUri == null) {
      _defaultArtUri = await impl.materializeDefaultArtUri(defaultImageAssetName);
    }

    return _defaultArtUri;
  }
}
