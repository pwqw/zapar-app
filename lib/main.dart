import 'dart:async';

import 'audio_handler.dart' if (dart.library.html) 'audio_handler_stub.dart';
import 'package:app/app_providers.dart';
import 'package:app/ui/app.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'providers/download_provider.dart';

late KoelAudioHandler audioHandler;

/// Shared startup (storage + audio service) for production and integration tests.
Future<void> bootstrapKoelApplication() async {
  audioHandler = await AudioService.init(
    builder: () => KoelAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'dev.koel.app.channel.audio',
      androidNotificationChannelName: 'Koel audio playback',
      androidNotificationOngoing: true,
    ),
  );

  await GetStorage.init('Preferences');
  await GetStorage.init(DownloadProvider.serializedPlayableContainer);
}

Future<void> main() async {
  await bootstrapKoelApplication();

  runApp(
    MultiProvider(
      providers: buildKoelSingleChildProviders(),
      child: const App(),
    ),
  );
}
