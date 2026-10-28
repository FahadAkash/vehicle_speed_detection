import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/utils/number_formatter.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_app_bar.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_button.dart';
import 'package:vehicle_speed_estimator/core/widgets/empty_state.dart';
import 'package:vehicle_speed_estimator/core/widgets/metric_tile.dart';
import 'package:vehicle_speed_estimator/core/widgets/sync_status_card.dart';
import 'package:vehicle_speed_estimator/core/widgets/verified_feed_tile.dart';
import 'package:vehicle_speed_estimator/features/settings/domain/settings_notifier.dart';
import 'package:vehicle_speed_estimator/features/telemetry_sync/domain/telemetry_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.cmp;
    final useBangla = ref.watch(
      settingsNotifierProvider.select((s) => s.useBanglaDigits),
    );
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;
    final todayCount = ref.watch(todayVerifiedCountProvider).value ?? 0;
    final recentRecordsAsync = ref.watch(recentRecordsProvider);

    return Scaffold(
      appBar: const CmpAppBar(
        title: 'সিএমপি স্পিড মনিটর',
        subtitle: 'Chattogram Metropolitan Police (CMP)',
        showBrandStripe: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(CmpSpacing.space16),
        children: [
          CmpButton(
            label: 'নতুন সেশন শুরু করুন / Start Session',
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.push('/session/setup'),
          ),
          const SizedBox(height: CmpSpacing.space16),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'আজকের যাচাই / Verified',
                  value: NumberFormatter.formatInt(
                    todayCount,
                    useBanglaDigits: useBangla,
                  ),
                  icon: Icons.speed_rounded,
                ),
              ),
              const SizedBox(width: CmpSpacing.space12),
              const Expanded(
                child: MetricTile(
                  label: 'সর্বশেষ সেশন / Last',
                  value: 'সক্রিয়',
                  icon: Icons.access_time_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: CmpSpacing.space16),
          SyncStatusCard(
            pendingCount: pendingCount,
            useBanglaDigits: useBangla,
            onRetrySync: () async {
              final pending = await ref
                  .read(databaseProvider)
                  .getPendingSyncRecords();
              if (pending.isNotEmpty) {
                await ref.read(syncServiceProvider).syncRecords(pending);
              }
            },
          ),
          const SizedBox(height: CmpSpacing.space24),
          Text(
            'সাম্প্রতিক যাচাইকৃত / Recent Verified',
            style: CmpTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: CmpSpacing.space12),
          recentRecordsAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return const EmptyState(
                  title: 'এখনও কোনো গতি রেকর্ড নেই',
                  subtitle: 'নতুন সেশন শুরু করে গতি পরিমাপ করুন।',
                  icon: Icons.speed_outlined,
                );
              }
              return Column(
                children: records.map((record) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: CmpSpacing.space8),
                    child: VerifiedFeedTile(
                      record: record,
                      useBanglaDigits: useBangla,
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('ত্রুটি ঘটেছে'),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (idx) {
          if (idx == 1) context.go('/logs');
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
