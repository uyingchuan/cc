import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/timelog/time_log_form_screen.dart';
import '../screens/timelog/time_log_home_screen.dart';
import '../screens/journal/entry_detail_screen.dart';
import '../screens/journal/entry_form_screen.dart';
import '../screens/journal/journal_home_screen.dart';
import '../models/asset.dart';
import '../screens/asset/asset_form_screen.dart';
import '../screens/asset/asset_history_screen.dart';
import '../screens/asset/asset_home_screen.dart';
import '../screens/asset/snapshot_history_screen.dart';
import '../screens/bill/bill_form_screen.dart';
import '../screens/bill/bill_home_screen.dart';
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
        path: '/timelog',
        name: 'timelog',
        builder: (context, state) => const TimeLogHomeScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'timelog-new',
            builder: (context, state) => const TimeLogFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'timelog-edit',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return TimeLogFormScreen(logId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/assets',
        name: 'assets',
        builder: (context, state) => const AssetHomeScreen(),
        routes: [
          GoRoute(
            path: 'snapshots',
            name: 'asset-snapshots',
            builder: (context, state) => const SnapshotHistoryScreen(),
          ),
          GoRoute(
            path: 'new',
            name: 'asset-new',
            builder: (context, state) => const AssetFormScreen(),
          ),
          GoRoute(
            path: ':id/history',
            name: 'asset-history',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final name = state.uri.queryParameters['name'] ?? '';
              return AssetHistoryScreen(assetId: id, assetName: name);
            },
          ),
          GoRoute(
            path: ':id/edit',
            name: 'asset-edit',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final asset = state.extra as Asset?;
              return AssetFormScreen(assetId: id, asset: asset);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/bills',
        name: 'bills',
        builder: (context, state) => const BillHomeScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'bill-new',
            builder: (context, state) => const BillFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'bill-edit',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BillFormScreen(billId: id);
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
