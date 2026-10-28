import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_app_bar.dart';
import 'package:vehicle_speed_estimator/core/widgets/empty_state.dart';
import 'package:vehicle_speed_estimator/core/widgets/verified_feed_tile.dart';
import 'package:vehicle_speed_estimator/features/settings/domain/settings_notifier.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';
import 'package:vehicle_speed_estimator/features/telemetry_sync/domain/telemetry_providers.dart';

class VerifiedLogsScreen extends ConsumerWidget {
  const VerifiedLogsScreen({super.key});

  void _showDetailSheet(BuildContext context, VerifiedSpeedRecord record) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cmp.surface,
      shape: const RoundedRectangleBorder(borderRadius: CmpSpacing.borderSheet),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(CmpSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'রেকর্ড বিস্তারিত / Record Detail',
              style: CmpTypography.title.copyWith(color: ctx.cmp.textPrimary),
            ),
            const Divider(),
            Text(
              'Track ID: #${record.trackId}',
              style: TextStyle(color: ctx.cmp.textPrimary),
            ),
            Text(
              'Vehicle: ${record.vehicleClass.banglaLabel} (${record.vehicleClass.wireName})',
              style: TextStyle(color: ctx.cmp.textPrimary),
            ),
            Text(
              'Speed: ${record.speedKmh.toStringAsFixed(2)} km/h',
              style: TextStyle(
                color: ctx.cmp.verified,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Half-1: ${record.speedHalf1Kmh.toStringAsFixed(2)} km/h | Half-2: ${record.speedHalf2Kmh.toStringAsFixed(2)} km/h',
              style: TextStyle(color: ctx.cmp.textSecondary),
            ),
            Text(
              'Divergence: ${(record.consistencyDivergence * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: ctx.cmp.textSecondary),
            ),
            Text(
              'Direction: ${record.direction} | Distance: ${record.distanceM.toStringAsFixed(1)} m',
              style: TextStyle(color: ctx.cmp.textSecondary),
            ),
            Text(
              'Timestamp UTC: ${record.timestampUtcMs}',
              style: TextStyle(color: ctx.cmp.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useBangla = ref.watch(
      settingsNotifierProvider.select((s) => s.useBanglaDigits),
    );
    final recordsAsync = ref.watch(recentRecordsProvider);

    return Scaffold(
      appBar: CmpAppBar(
        title: 'যাচাইকৃত লগ / Logs',
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export CSV',
            onPressed: () async {
              final dbRecords = await ref
                  .read(databaseProvider)
                  .getAllRecords();
              await ref
                  .read(exportServiceProvider)
                  .exportCsv(records: dbRecords, siteName: 'CMP Session');
            },
          ),
        ],
      ),
      body: recordsAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              title: 'কোনো লগ রেকর্ড নেই',
              subtitle: 'স্পিড ট্র্যাকিং সেশন শুরু করে গতি পরিমাপ করুন।',
              icon: Icons.history_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(CmpSpacing.space16),
            itemCount: records.length,
            itemBuilder: (ctx, i) {
              final record = records[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: CmpSpacing.space8),
                child: VerifiedFeedTile(
                  record: record,
                  useBanglaDigits: useBangla,
                  onTap: () => _showDetailSheet(context, record),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('লগ লোড করতে সমস্যা হয়েছে')),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (idx) {
          if (idx == 0) context.go('/');
          if (idx == 2) context.go('/settings');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'হোম / Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: 'লগ / Logs',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'সেটিংস / Settings',
          ),
        ],
      ),
    );
  }
}
