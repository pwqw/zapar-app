import 'package:app/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Provider tree shared by [main] and integration tests.
List<SingleChildWidget> buildKoelSingleChildProviders() {
  return [
    Provider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ArtistProvider()),
    ChangeNotifierProvider(create: (context) => PlayableProvider()),
    Provider(create: (_) => MediaInfoProvider()),
    Provider(
      create: (context) => DownloadProvider(
        playableProvider: context.read<PlayableProvider>(),
      ),
      lazy: false,
    ),
    ChangeNotifierProvider(create: (context) => AlbumProvider()),
    ChangeNotifierProvider(
      create: (context) => FavoriteProvider(
        playableProvider: context.read<PlayableProvider>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => RecentlyPlayedProvider(
        playableProvider: context.read<PlayableProvider>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => InteractionProvider(
        playableProvider: context.read<PlayableProvider>(),
        recentlyPlayedProvider: context.read<RecentlyPlayedProvider>(),
      ),
      lazy: false,
    ),
    ChangeNotifierProvider(
      create: (context) => PlaylistProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => PlaylistFolderProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => SearchProvider(
        playableProvider: context.read<PlayableProvider>(),
        artistProvider: context.read<ArtistProvider>(),
        albumProvider: context.read<AlbumProvider>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => DataProvider(
        playlistProvider: context.read<PlaylistProvider>(),
        playlistFolderProvider: context.read<PlaylistFolderProvider>(),
        playableProvider: context.read<PlayableProvider>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => OverviewProvider(
        playableProvider: context.read<PlayableProvider>(),
        albumProvider: context.read<AlbumProvider>(),
        artistProvider: context.read<ArtistProvider>(),
        recentlyPlayedProvider: context.read<RecentlyPlayedProvider>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => DownloadSyncProvider(
        downloadProvider: context.read<DownloadProvider>(),
        playableProvider: context.read<PlayableProvider>(),
      ),
    ),
    ChangeNotifierProvider(create: (context) => PodcastProvider()),
    ChangeNotifierProvider(create: (context) => GenreProvider()),
    ChangeNotifierProvider(create: (context) => RadioStationProvider()),
    ChangeNotifierProvider(create: (context) => RadioPlayerProvider()),
    ChangeNotifierProvider(
      create: (context) => PlayableListScreenProvider(
        playableProvider: context.read<PlayableProvider>(),
        searchProvider: context.read<SearchProvider>(),
      ),
    ),
  ];
}
