import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';
import 'package:vehicle_speed_estimator/core/widgets/verified_feed_tile.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';

class MonitorFeedPanel extends StatelessWidget {
  const MonitorFeedPanel({
    required this.verifiedFeed,
    super.key,
  });

  final List<VerifiedSpeedRecord> verifiedFeed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 48,
      right: 0,
      bottom: 64,
      width: 220,
      child: Container(
        color: OverlayColors.overlayScrim,
        padding: const EdgeInsets.all(CmpSpacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LATEST VERIFIED',
              style: CmpTypography.caption.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: CmpSpacing.space8),
            Expanded(
              child: verifiedFeed.isEmpty
                  ? Center(
                      child: Text(
                        'অপেক্ষমান...',
                        style: CmpTypography.caption.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: verifiedFeed.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: VerifiedFeedTile(record: verifiedFeed[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

