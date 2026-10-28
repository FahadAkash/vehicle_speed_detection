import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_app_bar.dart';
import 'package:vehicle_speed_estimator/features/settings/domain/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.cmp;
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: const CmpAppBar(title: 'সেটিংস / Settings'),
      body: ListView(
        padding: const EdgeInsets.all(CmpSpacing.space16),
        children: [
          Text(
            'সাধারণ সেটিংস / General',
            style: CmpTypography.label.copyWith(color: colors.primary),
          ),
          const SizedBox(height: CmpSpacing.space8),
          SwitchListTile(
            title: const Text('বাংলা সংখ্যা ব্যবহার করুন'),
            subtitle: const Text('Use Bangla digits for numbers and speed'),
            value: settings.useBanglaDigits,
            onChanged: (val) => ref
                .read(settingsNotifierProvider.notifier)
                .toggleBanglaDigits(val),
          ),
          SwitchListTile(
            title: const Text('ডায়াগনস্টিক মোড'),
            subtitle: const Text(
              'Show dropped frames & rejected fault counter',
            ),
            value: settings.diagnosticsMode,
            onChanged: (val) => ref
                .read(settingsNotifierProvider.notifier)
                .toggleDiagnostics(val),
          ),
          const Divider(height: 32),
          Text(
            'থিম নির্বাচন / Appearance',
            style: CmpTypography.label.copyWith(color: colors.primary),
          ),
          const SizedBox(height: CmpSpacing.space8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.dark, label: Text('ডার্ক / Dark')),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('লাইট / Light'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('সিস্টেম / Auto'),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (set) => ref
                .read(settingsNotifierProvider.notifier)
                .setThemeMode(set.first),
          ),
          const Divider(height: 32),
          Text(
            'আইনি অস্বীকৃতি ও শর্তাবলী / Legal Disclaimer',
            style: CmpTypography.label.copyWith(color: colors.primary),
          ),
          const SizedBox(height: CmpSpacing.space8),
          Container(
            padding: const EdgeInsets.all(CmpSpacing.space16),
            decoration: BoxDecoration(
              color: colors.surfaceHigh,
              borderRadius: CmpSpacing.borderCard,
              border: Border.all(color: colors.outline),
            ),
            child: Text(
              'এই অ্যাপটি ফোনের ক্যামেরা ও কৃত্রিম বুদ্ধিমত্তা ব্যবহার করে যানবাহনের গতি অনুমান করে (আনুমানিক গতি / Estimated Speed)। উপযুক্ত আইনি কর্তৃপক্ষের অনুমোদন ও সঠিক ক্যালিব্রেশন ছাড়া এটি সরাসরি আদালতের প্রমাণ হিসেবে ব্যবহার করা যাবে না। অ্যাপটিতে কোনো ব্যক্তিগত তথ্য, মুখমণ্ডল বা লাইসেন্স প্লেট সংরক্ষণ বা প্রক্রিয়াজাত করা হয় না।\n\n'
              'This application produces estimated speed measurements. It strictly does not perform facial recognition, license-plate recognition, or raw video storage.',
              style: CmpTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (idx) {
          if (idx == 0) context.go('/');
          if (idx == 1) context.go('/logs');
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
