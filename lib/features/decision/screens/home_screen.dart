import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../providers/decision_provider.dart';
import '../models/decision.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(decisionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=47',
                        ), // Placeholder avatar
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Vivek',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Today ${DateFormat('dd MMM').format(DateTime.now())}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.greyLight, width: 2),
                    ),
                    child: const Icon(Icons.search, size: 24),
                  ),
                ],
              ),
            ),

            // Hero Dashboard Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  color: AppColors.pastelPurple,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Decision\nDashboard',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solve your pending thoughts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _buildHeroAvatar('3'),
                        _buildHeroAvatar('4'),
                        _buildHeroAvatar('5'),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '+4',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 24, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your decisions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // Scrollable List
            Expanded(
              child: decisions.isEmpty
                  ? Center(
                      child: Text(
                        'No decisions yet.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: decisions.length,
                        itemBuilder: (context, index) {
                          // Assign a rotating pastel color
                          final colors = [
                            AppColors.pastelOrange,
                            AppColors.pastelBlue,
                            AppColors.pastelGreen,
                            AppColors.pastelPink,
                            AppColors.pastelYellow,
                          ];
                          return _DecisionPillCard(
                            decision: decisions[index],
                            color: colors[index % colors.length],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroAvatar(String id) {
    return Transform.translate(
      offset: const Offset(-10, 0),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.pastelPurple, width: 3),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=$id'),
        ),
      ),
    );
  }
}

class _DecisionPillCard extends StatelessWidget {
  final Decision decision;
  final Color color;

  const _DecisionPillCard({required this.decision, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBiases = decision.biases.isNotEmpty;

    return GestureDetector(
      onTap: () => context.push('/decision/${decision.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small chip tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Options: ${decision.options.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                decision.title.isEmpty ? 'Untitled Decision' : decision.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Created',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM').format(decision.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (hasBiases)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
