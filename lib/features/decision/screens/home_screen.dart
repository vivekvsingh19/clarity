import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../providers/decision_provider.dart';
import '../models/decision.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(decisionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _BottomDock(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu, size: 24, color: AppColors.textPrimary),
                  const SizedBox(width: 14),
                  Text(
                    'Clarity',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 38,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Let’s find\nclarity.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 58,
                  height: 1.05,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your mental space is sacred. Take a moment to reflect on your current paths.',
                style: GoogleFonts.nunito(
                  fontSize: 30,
                  height: 1.4,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              _InsightCard(decisions: decisions),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Journeys',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 42,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${decisions.length} ONGOING',
                    style: GoogleFonts.nunito(
                      letterSpacing: 1.4,
                      fontSize: 20,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (decisions.isEmpty)
                _EmptyJourneyCard(onCreate: () => context.push('/create'))
              else
                ...decisions.map((decision) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _JourneyCard(decision: decision),
                  );
                }),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => context.push('/create'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF26314D), Color(0xFF081A57)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    '"The quality of your life is determined by the quality of your decisions."',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 42,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final List<Decision> decisions;

  const _InsightCard({required this.decisions});

  @override
  Widget build(BuildContext context) {
    final hasBias = decisions.any((d) => d.biases.isNotEmpty);

    return Container(
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
            child: const Icon(Icons.psychology_alt_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INSIGHT',
                  style: GoogleFonts.nunito(
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasBias
                      ? 'You may be influenced by short-term emotion.'
                      : 'Your decisions are balanced and grounded.',
                  style: GoogleFonts.nunito(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    fontSize: 20,
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

class _JourneyCard extends StatelessWidget {
  final Decision decision;

  const _JourneyCard({required this.decision});

  @override
  Widget build(BuildContext context) {
    final routeStage = _routeStage(decision);

    return GestureDetector(
      onTap: () => context.push('/decision/${decision.id}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    decision.title.isEmpty ? 'Untitled journey' : decision.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F0EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${routeStage.completed}/${routeStage.total} steps',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Focus: ${_focusLabel(decision)}',
              style: GoogleFonts.nunito(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: routeStage.progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE8E5E1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0A1C58)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stageLabel('DISCOVERY', routeStage.completed >= 1),
                _stageLabel('EVALUATION', routeStage.completed >= 2),
                _stageLabel('FINALIZE', routeStage.completed >= 3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stageLabel(String label, bool active) {
    return Text(
      label,
      style: GoogleFonts.nunito(
        fontSize: 11,
        letterSpacing: 0.8,
        color: active ? AppColors.primary : const Color(0xFFBCB6AD),
        fontWeight: FontWeight.w800,
      ),
    );
  }

  _RouteStage _routeStage(Decision decision) {
    final hasTitle = decision.title.trim().isNotEmpty;
    final hasOptions = decision.options.isNotEmpty;
    final hasProsCons = decision.options.any((option) => option.prosCons.isNotEmpty);
    final hasRegret = decision.options.any(
      (option) => option.actionRegret > 1 || option.inactionRegret > 1,
    );

    int completed = 0;
    if (hasTitle) completed++;
    if (hasOptions) completed++;
    if (hasProsCons) completed++;
    if (hasRegret) completed++;

    return _RouteStage(completed: completed, total: 5);
  }

  String _focusLabel(Decision decision) {
    if (decision.options.isEmpty) return 'Planning';
    return decision.options.first.title;
  }
}

class _EmptyJourneyCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyJourneyCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No active journeys yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first decision journey to track clarity in real-time.',
            style: GoogleFonts.nunito(
              color: AppColors.textSecondary,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Start journey'),
          ),
        ],
      ),
    );
  }
}

class _BottomDock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F1EB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.grid_view_rounded, color: Color(0xFF7E8397)),
          Icon(Icons.alt_route_rounded, color: Color(0xFF7E8397)),
          SizedBox(width: 42),
          Icon(Icons.history_rounded, color: Color(0xFF7E8397)),
          Icon(Icons.settings, color: Color(0xFF7E8397)),
        ],
      ),
    );
  }
}

class _RouteStage {
  final int completed;
  final int total;

  const _RouteStage({required this.completed, required this.total});

  double get progress {
    if (total == 0) return 0;
    return (completed / total).clamp(0.0, 1.0);
  }
}
