import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/journal/entry_detail_screen.dart';
import '../screens/journal/entry_form_screen.dart';
import '../screens/journal/journal_home_screen.dart';
import '../screens/asset/asset_form_screen.dart';
import '../screens/asset/asset_home_screen.dart';
import '../screens/journal/search_screen.dart';
import '../screens/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/assets',
        name: 'assets',
        builder: (context, state) => const AssetHomeScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'asset-new',
            builder: (context, state) => const AssetFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'asset-edit',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return AssetFormScreen(assetId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/journal',
        name: 'journal',
        builder: (context, state) => const JournalHomeScreen(),
        routes: [
          GoRoute(
            path: 'search',
            name: 'entry-search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'journal-settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'entry-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return EntryDetailScreen(entryId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'entry-edit',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return EntryFormScreen(entryId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
