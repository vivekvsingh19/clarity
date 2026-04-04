import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F1E8), Color(0xFFF4EADF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasBiases) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E7D5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE0B65F),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'You may be influenced by short-term emotion.',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
              ],
              Text(
                'Recommended Choice',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF6F728A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bestOption.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 64,
                  height: 1.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
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
              const SizedBox(height: 24),
              _SummaryCard(bestOption: bestOption, isDark: isDark),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Accept Decision'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Reconsider',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Breakdown',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ...decision.options.map((opt) {
                return _OptionMetricCard(
                  option: opt,
                  isDark: isDark,
                  isBest: opt.id == bestOption.id,
                );
              }),
              if (hasBiases) ...[
                const SizedBox(height: 20),
                ...decision.biases.map(
                  (b) => _BiasCard(biasInsight: b, isDark: isDark),
                ),
              ],
              const SizedBox(height: 48),
            ],
          ),
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            const Color(0xFF6A4A30),
            const Color(0xFFB88363),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.onPrimary, size: 24),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'calm recommendation',
                  style: TextStyle(
                    color: AppColors.onPrimary.withAlpha(230),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.onPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Best option',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bestOption.title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
        color: isDark ? AppColors.darkSurface : AppColors.negativeBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.negative.withAlpha(34)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.negative.withAlpha(14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.negative,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              biasInsight,
              style: TextStyle(
                color: isDark ? const Color(0xFFFFD3D3) : AppColors.negative,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isBest ? 2 : 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
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
                    fontWeight: FontWeight.w800,
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
                    borderRadius: BorderRadius.circular(999),
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
