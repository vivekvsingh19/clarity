import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/decision.dart';
import '../models/option.dart';
import '../models/pro_con.dart';

// Provides the list of saved decisions.
class DecisionsNotifier extends Notifier<List<Decision>> {
  @override
  List<Decision> build() {
    // Return empty initially. In a real app, load from local storage/SQLite here.
    return [
      Decision(
        id: '1',
        title: 'Should I quit my job?',
        options: [
          Option(
            id: 'o1',
            title: 'Quit and start my own business',
            prosCons: [
              ProCon(
                description: 'Freedom and autonomy',
                weight: 5,
                type: ProConType.pro,
              ),
              ProCon(
                description: 'Uncertain income',
                weight: 4,
                type: ProConType.con,
              ),
            ],
            actionRegret: 8,
            actionRegretProbability: 5,
            inactionRegret: 9,
            inactionRegretLikelihood: 8,
          ),
          Option(
            id: 'o2',
            title: 'Stay at my current job',
            prosCons: [
              ProCon(
                description: 'Stable income',
                weight: 4,
                type: ProConType.pro,
              ),
              ProCon(
                description: 'Feeling unfulfilled',
                weight: 4,
                type: ProConType.con,
              ),
              ProCon(
                description: 'I\'ve put so much time here already',
                weight: 3,
                type: ProConType.con,
              ),
            ],
            actionRegret: 4,
            actionRegretProbability: 7,
            inactionRegret: 7,
            inactionRegretLikelihood: 9,
          ),
        ],
      ),
    ];
  }

  void addDecision(Decision decision) {
    state = [...state, decision];
  }

  void updateDecision(Decision updatedDecision) {
    state = [
      for (final decision in state)
        if (decision.id == updatedDecision.id) updatedDecision else decision,
    ];
  }

  void removeDecision(String decisionId) {
    state = state.where((d) => d.id != decisionId).toList();
  }
}

final decisionsProvider = NotifierProvider<DecisionsNotifier, List<Decision>>(
  () {
    return DecisionsNotifier();
  },
);
