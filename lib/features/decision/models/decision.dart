import 'package:uuid/uuid.dart';
import 'option.dart';
import 'pro_con.dart';

class Decision {
  final String id;
  final String title;
  final DateTime? deadline;
  final DateTime createdAt;
  final List<Option> options;

  Decision({
    String? id,
    required this.title,
    this.deadline,
    DateTime? createdAt,
    this.options = const [],
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Decision copyWith({
    String? title,
    DateTime? deadline,
    List<Option>? options,
  }) {
    return Decision(
      id: id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
      options: options ?? this.options,
    );
  }

  // Returns list of biases detected across all options
  List<String> get biases {
    List<String> detectedBiases = [];

    // Bias rules
    bool extremeRegretImbalance = false;
    bool highFearLowDownside = false;
    bool sunkCostMentioned = false;

    for (var option in options) {
      // 1. Extreme regret imbalance
      // If action regret is way higher than inaction but logical scores are similar/high
      if (option.actionRegret >= 8 && option.inactionRegret <= 3) {
        extremeRegretImbalance = true;
      }

      // 2. High fear + low logical downside
      // Fear -> Action regret is very high, but cons (logical downside) are extremely low.
      int conWeights = option.prosCons
          .where((pc) => pc.type == ProConType.con)
          .fold(0, (sum, pc) => sum + pc.weight);

      if (option.actionRegret >= 8 &&
          conWeights <= 3 &&
          option.prosCons.isNotEmpty) {
        highFearLowDownside = true;
      }

      // 3. Heavy sunk cost mentioned
      final textToCheck =
          '${option.title.toLowerCase()} ${option.prosCons.map((e) => e.description.toLowerCase()).join(' ')}';

      if (textToCheck.contains('already spent') ||
          textToCheck.contains('put so much time') ||
          textToCheck.contains('too far in') ||
          textToCheck.contains('sunk cost') ||
          textToCheck.contains('invested')) {
        sunkCostMentioned = true;
      }
    }

    if (extremeRegretImbalance) {
      detectedBiases.add(
        "You might be overweighing the fear of taking action compared to staying still.",
      );
    }
    if (highFearLowDownside) {
      detectedBiases.add(
        "Your fear of doing this seems high, but the logical downside is actually very low. Are you overthinking it?",
      );
    }
    if (sunkCostMentioned) {
      detectedBiases.add(
        "We noticed signs of the 'Sunk Cost Fallacy'. Remember, past time or money spent shouldn't dictate your future.",
      );
    }

    return detectedBiases;
  }
}
