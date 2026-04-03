import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../providers/draft_decision_provider.dart';
import '../providers/decision_provider.dart';
import '../models/pro_con.dart';
import '../models/option.dart';

class CreateDecisionScreen extends ConsumerStatefulWidget {
  const CreateDecisionScreen({super.key});

  @override
  ConsumerState<CreateDecisionScreen> createState() =>
      _CreateDecisionScreenState();
}

class _CreateDecisionScreenState extends ConsumerState<CreateDecisionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      final draft = ref.read(draftDecisionProvider);
      ref.read(decisionsProvider.notifier).addDecision(draft);
      ref.read(draftDecisionProvider.notifier).reset();
      context.pop();
    }
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevPage,
        ),
        title: Text(
          'Step ${_currentPage + 1} of $_totalPages',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            backgroundColor: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppColors.onPrimary : AppColors.primary,
            ),
            minHeight: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _Step1Title(isDark: isDark),
                  _Step2Options(isDark: isDark),
                  _Step3ProsCons(isDark: isDark),
                  _Step4Regret(isDark: isDark),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _totalPages - 1
                          ? 'Finish & Save'
                          : 'Continue',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// STEP 1: Title
class _Step1Title extends ConsumerStatefulWidget {
  final bool isDark;
  const _Step1Title({required this.isDark});

  @override
  ConsumerState<_Step1Title> createState() => _Step1TitleState();
}

class _Step1TitleState extends ConsumerState<_Step1Title> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(draftDecisionProvider).title;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'What decision are you facing?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
            ),
            child: TextField(
              controller: _controller,
              onChanged: (val) =>
                  ref.read(draftDecisionProvider.notifier).updateTitle(val),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: null,
              minLines: 1,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g., Should I look for a new job?',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Give the decision a clear name so the rest of the flow stays focused.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// STEP 2: Options
class _Step2Options extends ConsumerStatefulWidget {
  final bool isDark;
  const _Step2Options({required this.isDark});

  @override
  ConsumerState<_Step2Options> createState() => _Step2OptionsState();
}

class _Step2OptionsState extends ConsumerState<_Step2Options> {
  final TextEditingController _controller = TextEditingController();

  void _addOption() {
    if (_controller.text.trim().isNotEmpty) {
      ref
          .read(draftDecisionProvider.notifier)
          .addOption(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(draftDecisionProvider);
    final borderColor = widget.isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List the possible paths',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Add at least two options so the app can compare them clearly.',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Add an option...',
                    prefixIcon: Icon(Icons.route_rounded),
                  ),
                  onSubmitted: (_) => _addOption(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addOption,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: draft.options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final option = draft.options[index];
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppColors.darkSurfaceHighlight
                              : AppColors.lightSurfaceHighlight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// STEP 3: Pros and Cons
class _Step3ProsCons extends ConsumerWidget {
  final bool isDark;
  const _Step3ProsCons({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftDecisionProvider);

    if (draft.options.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Text(
            'Please add options first.',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weigh the logic',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add objective pros and cons for each.',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: draft.options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = draft.options[index];
                return _OptionProConCard(option: option, isDark: isDark);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionProConCard extends ConsumerStatefulWidget {
  final Option option;
  final bool isDark;
  const _OptionProConCard({required this.option, required this.isDark});

  @override
  ConsumerState<_OptionProConCard> createState() => _OptionProConCardState();
}

class _OptionProConCardState extends ConsumerState<_OptionProConCard> {
  final TextEditingController _controller = TextEditingController();
  ProConType _selectedType = ProConType.pro;
  double _weight = 3;

  void _addProCon() {
    if (_controller.text.trim().isNotEmpty) {
      ref
          .read(draftDecisionProvider.notifier)
          .addProConToOption(
            widget.option.id,
            _controller.text.trim(),
            _weight.toInt(),
            _selectedType,
          );
      _controller.clear();
      setState(() => _weight = 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;
    final surfaceColor = widget.isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              widget.option.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          Divider(height: 1, color: borderColor),
          if (widget.option.prosCons.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: widget.option.prosCons
                    .map(
                      (pc) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              pc.type == ProConType.pro
                                  ? Icons.add_circle
                                  : Icons.remove_circle,
                              color: pc.type == ProConType.pro
                                  ? AppColors.positive
                                  : AppColors.negative,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                pc.description,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? AppColors.darkSurfaceHighlight
                                    : AppColors.lightSurfaceHighlight,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: borderColor),
                              ),
                              child: Text(
                                'x${pc.weight}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Divider(height: 1, color: borderColor),
          ],
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedType = ProConType.pro),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedType == ProConType.pro
                                ? AppColors.positive
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedType == ProConType.pro
                                  ? AppColors.positive
                                  : borderColor,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pro',
                            style: TextStyle(
                              color: _selectedType == ProConType.pro
                                  ? Colors.white
                                  : (widget.isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedType = ProConType.con),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedType == ProConType.con
                                ? AppColors.negative
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedType == ProConType.con
                                  ? AppColors.negative
                                  : borderColor,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Con',
                            style: TextStyle(
                              color: _selectedType == ProConType.con
                                  ? Colors.white
                                  : (widget.isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Describe the point...',
                    prefixIcon: Icon(Icons.notes_rounded),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Weight:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Slider(
                        value: _weight,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (val) => setState(() => _weight = val),
                      ),
                    ),
                    Text(
                      '${_weight.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filled(
                      icon: const Icon(Icons.check),
                      onPressed: _addProCon,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// STEP 4: Regret
class _Step4Regret extends ConsumerWidget {
  final bool isDark;
  const _Step4Regret({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftDecisionProvider);

    if (draft.options.isEmpty) {
      return Center(
        child: Text(
          'Please add options first.',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Measure emotion',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Predict how you will feel later.',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: draft.options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final option = draft.options[index];
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSliderRow(
                        context,
                        'Action Regret',
                        'If I do this and it fails.',
                        option.actionRegret.toDouble(),
                        (val) => ref
                            .read(draftDecisionProvider.notifier)
                            .updateOptionRegret(
                              option.id,
                              actionRegret: val.toInt(),
                            ),
                      ),
                      const SizedBox(height: 24),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                      const SizedBox(height: 24),
                      _buildSliderRow(
                        context,
                        'Inaction Regret',
                        'If I do not do this.',
                        option.inactionRegret.toDouble(),
                        (val) => ref
                            .read(draftDecisionProvider.notifier)
                            .updateOptionRegret(
                              option.id,
                              inactionRegret: val.toInt(),
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    BuildContext context,
    String title,
    String subtitle,
    double value,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceHighlight
                    : AppColors.lightSurfaceHighlight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${value.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
