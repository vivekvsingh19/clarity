import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../providers/decision_provider.dart';
import '../models/decision.dart';
import '../models/option.dart';

class ClarityResultScreen extends ConsumerWidget {
  final String decisionId;

  const ClarityResultScreen({required this.decisionId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(decisionsProvider);
    final decision = decisions.firstWhere(
      (d) => d.id == decisionId,
      orElse: () => Decision(title: 'Not Found'),
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (decision.options.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Decision not found.')),
      );
    }

    Option bestOption = decision.options.first;
    double maxCompositeScore = double.negativeInfinity;

    for (var opt in decision.options) {
      double composite = (opt.logicalScore * 2) + opt.regretScore;
      if (composite > maxCompositeScore) {
        maxCompositeScore = composite;
        bestOption = opt;
      }
    }

    final hasBiases = decision.biases.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verdict',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              decision.title,
              style: TextStyle(
                fontSize: 18,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 48),

            _SummaryCard(bestOption: bestOption, isDark: isDark),

            if (hasBiases) ...[
              const SizedBox(height: 48),
              const Text(
                'Bias Warning',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ...decision.biases.map(
                (b) => _BiasCard(biasInsight: b, isDark: isDark),
              ),
            ],

            const SizedBox(height: 48),
            const Text(
              'Breakdown',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            ...decision.options.map((opt) {
              return _OptionMetricCard(
                option: opt,
                isDark: isDark,
                isBest: opt.id == bestOption.id,
              );
            }),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Option bestOption;
  final bool isDark;

  const _SummaryCard({required this.bestOption, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary, // Black in light mode, White in dark mode
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.onPrimary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Data Suggestion',
                style: TextStyle(
                  color: AppColors.onPrimary.withAlpha(200),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Based on the weighted logic and regret minimisation, the best path is:',
            style: TextStyle(
              color: AppColors.onPrimary.withAlpha(200),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.onPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bestOption.title,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BiasCard extends StatelessWidget {
  final String biasInsight;
  final bool isDark;

  const _BiasCard({required this.biasInsight, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.negativeBackground.withAlpha(20)
            : AppColors.negativeBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.negative.withAlpha(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.negative,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              biasInsight,
              style: TextStyle(
                color: isDark ? const Color(0xFFEF9A9A) : AppColors.negative,
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionMetricCard extends StatelessWidget {
  final Option option;
  final bool isDark;
  final bool isBest;

  const _OptionMetricCard({
    required this.option,
    required this.isDark,
    required this.isBest,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isBest
        ? AppColors.primary
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isBest ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  option.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isBest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Best',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(
                label: 'Logic Score',
                value: option.logicalScore.toString(),
                isPositive: option.logicalScore >= 0,
                isDark: isDark,
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              _MetricItem(
                label: 'Regret Score',
                value: option.regretScore.toStringAsFixed(1),
                isPositive: option.regretScore >= 0,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;
  final bool isDark;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.isPositive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }
}
