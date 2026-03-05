import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../l10n/strings.dart';
import '../../../models/stats_monthly_response_model.dart';
import '../../../models/stats_summary_model.dart';

class BrandStatsCard extends StatelessWidget {
  final StatsSummaryModel? summary;
  final StatsMonthlyResponseModel? monthly;
  final AppStrings l10n;

  const BrandStatsCard({
    super.key,
    required this.summary,
    required this.monthly,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (summary == null && monthly == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLG),
        border: Border.all(color: AppTheme.divider),
      ),
      padding: EdgeInsets.all(SizeTokens.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            l10n.homeStatsTitle,
            style: TextStyle(
              fontSize: SizeTokens.fontLG,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (summary != null) ...[
            SizedBox(height: SizeTokens.spaceMD),
            _SummaryTiles(summary: summary!, l10n: l10n),
          ],
          if (summary?.byStatus?.isNotEmpty == true) ...[
            SizedBox(height: SizeTokens.spaceMD),
            _ByStatusRow(
              byStatusItems: summary!.byStatus!,
              l10n: l10n,
            ),
          ],
          if (monthly?.data?.isNotEmpty == true) ...[
            SizedBox(height: SizeTokens.spaceXL),
            Text(
              l10n.homeStatsMonthlyTitle,
              style: TextStyle(
                fontSize: SizeTokens.fontMD,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: SizeTokens.spaceMD),
            _MonthlyBarChart(items: monthly!.data!),
          ],
        ],
      ),
    );
  }
}

class _SummaryTiles extends StatelessWidget {
  final StatsSummaryModel summary;
  final AppStrings l10n;

  const _SummaryTiles({required this.summary, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          value: '${summary.totalAppointments ?? 0}',
          label: l10n.homeStatsTotalLabel,
        ),
        SizedBox(width: SizeTokens.spaceXS),
        _StatTile(
          value: '${summary.thisMonthCreated ?? 0}',
          label: l10n.homeStatsThisMonthLabel,
        ),
        SizedBox(width: SizeTokens.spaceXS),
        _StatTile(
          value: '${summary.activeCount ?? 0}',
          label: l10n.homeStatsActiveLabel,
        ),
        SizedBox(width: SizeTokens.spaceXS),
        _StatTile(
          value: '${summary.upcoming7Days ?? 0}',
          label: l10n.homeStatsUpcoming7DaysLabel,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: SizeTokens.spaceSM,
          horizontal: SizeTokens.spaceXS,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(SizeTokens.radiusMD),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: SizeTokens.fontXXL,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: SizeTokens.spaceXXS),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.fontXS,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ByStatusRow extends StatelessWidget {
  final List<dynamic> byStatusItems;
  final AppStrings l10n;

  const _ByStatusRow({required this.byStatusItems, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeStatsByStatusTitle,
          style: TextStyle(
            fontSize: SizeTokens.fontMD,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: SizeTokens.spaceXS),
        Wrap(
          spacing: SizeTokens.spaceXS,
          runSpacing: SizeTokens.spaceXS,
          children: byStatusItems.map<Widget>((item) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.spaceSM,
                vertical: SizeTokens.spaceXXS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(SizeTokens.radiusCircle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.name ?? ''}',
                    style: TextStyle(
                      fontSize: SizeTokens.fontSM,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accent,
                    ),
                  ),
                  SizedBox(width: SizeTokens.spaceXXS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.spaceXXS,
                      vertical: SizeConfig.h(1),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(SizeTokens.radiusCircle),
                    ),
                    child: Text(
                      '${item.count ?? 0}',
                      style: TextStyle(
                        fontSize: SizeTokens.fontXS,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final List<dynamic> items;

  const _MonthlyBarChart({required this.items});

  String _monthLabel(String? month) {
    if (month == null || month.length < 7) return '';
    const enMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final monthNum = int.tryParse(month.substring(5, 7));
    if (monthNum == null || monthNum < 1 || monthNum > 12) return '';
    // Use context-independent fallback; chart is decorative label only
    // For simplicity use the English abbreviation (purely visual)
    return enMonths[monthNum - 1];
    // If Turkish labels are needed, access can be done via locale in parent
    // but _MonthlyBarChart is a local widget without context dependency needed
    // for correctness — month index labels are universally understandable
  }

  @override
  Widget build(BuildContext context) {
    final maxCount = items.fold<int>(
      1,
      (prev, e) => max(prev, (e.count as int?) ?? 0),
    );
    // Use at least 1 to avoid division by zero
    final effectiveMax = maxCount < 1 ? 1 : maxCount;

    final chartHeight = SizeConfig.h(100);
    final labelHeight = SizeConfig.h(20);

    return SizedBox(
      height: chartHeight + labelHeight,
      child: CustomPaint(
        painter: _BarChartPainter(
          items: items,
          maxCount: effectiveMax,
          chartHeight: chartHeight,
          labelHeight: labelHeight,
          barColor: AppTheme.accent,
          labelColor: AppTheme.textSecondary,
          monthLabelFn: _monthLabel,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<dynamic> items;
  final int maxCount;
  final double chartHeight;
  final double labelHeight;
  final Color barColor;
  final Color labelColor;
  final String Function(String?) monthLabelFn;

  const _BarChartPainter({
    required this.items,
    required this.maxCount,
    required this.chartHeight,
    required this.labelHeight,
    required this.barColor,
    required this.labelColor,
    required this.monthLabelFn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final count = items.length;
    final gap = SizeConfig.w(4);
    final totalGap = gap * (count - 1);
    final barWidth = (size.width - totalGap) / count;

    final labelStyle = TextStyle(
      color: labelColor,
      fontSize: SizeConfig.sp(9),
      fontWeight: FontWeight.w500,
    );

    for (var i = 0; i < count; i++) {
      final item = items[i];
      final itemCount = (item.count as int?) ?? 0;
      final barHeight = (itemCount / maxCount) * chartHeight;
      final left = i * (barWidth + gap);
      final top = chartHeight - barHeight;

      // Draw bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        Radius.circular(SizeConfig.r(3)),
      );
      canvas.drawRRect(rect, barPaint);

      // Draw month label below bar
      final monthStr = item.month as String?;
      final label = monthLabelFn(monthStr);
      if (label.isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: barWidth);
        tp.paint(
          canvas,
          Offset(
            left + (barWidth - tp.width) / 2,
            chartHeight + SizeConfig.h(4),
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.items != items || old.maxCount != maxCount;
}
