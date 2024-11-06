import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core.dart';
import '../data.dart';

final analyticsProvider = Provider((ref) => FirebaseAnalytics.instance);
final databaseProvider = Provider((ref) => AppDatabase());
final queueManagerProvider = Provider((ref) => QueueManager());
final projectRepo = Provider<ProjectRepo>((ref) => ProjectLocalRepo(
      ref.read(databaseProvider),
      ref.read(queueManagerProvider),
    ));
