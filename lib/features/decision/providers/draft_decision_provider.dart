import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/decision.dart';
import '../models/option.dart';
import '../models/pro_con.dart';

// State representing the draft being created.
class DraftDecisionNotifier extends Notifier<Decision> {
  @override
  Decision build() {
    return Decision(title: ''); // Empty start
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void addOption(String optionTitle) {
    final newOption = Option(title: optionTitle);
    state = state.copyWith(options: [...state.options, newOption]);
  }

  void addProConToOption(
    String optionId,
    String description,
    int weight,
    ProConType type,
  ) {
    final newProCon = ProCon(
      description: description,
      weight: weight,
      type: type,
    );
    final newOptions = state.options.map((opt) {
      if (opt.id == optionId) {
        return opt.copyWith(prosCons: [...opt.prosCons, newProCon]);
      }
      return opt;
    }).toList();
    state = state.copyWith(options: newOptions);
  }

  void updateOptionRegret(
    String optionId, {
    int? actionRegret,
    int? actionRegretProbability,
    int? inactionRegret,
    int? inactionRegretLikelihood,
  }) {
    final newOptions = state.options.map((opt) {
      if (opt.id == optionId) {
        return opt.copyWith(
          actionRegret: actionRegret ?? opt.actionRegret,
          actionRegretProbability:
              actionRegretProbability ?? opt.actionRegretProbability,
          inactionRegret: inactionRegret ?? opt.inactionRegret,
          inactionRegretLikelihood:
              inactionRegretLikelihood ?? opt.inactionRegretLikelihood,
        );
      }
      return opt;
    }).toList();
    state = state.copyWith(options: newOptions);
  }

  void reset() {
    state = Decision(title: '');
  }
}

final draftDecisionProvider = NotifierProvider<DraftDecisionNotifier, Decision>(
  () {
    return DraftDecisionNotifier();
  },
);
