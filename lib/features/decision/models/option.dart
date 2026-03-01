import 'package:uuid/uuid.dart';
import 'pro_con.dart';

class Option {
  final String id;
  final String title;
  final List<ProCon> prosCons;

  // Regret Simulator Fields
  final int actionRegret; // 1 to 10
  final int actionRegretProbability; // 1 to 10
  final int inactionRegret; // 1 to 10
  final int inactionRegretLikelihood; // 1 to 10

  Option({
    String? id,
    required this.title,
    this.prosCons = const [],
    this.actionRegret = 1,
    this.actionRegretProbability = 1,
    this.inactionRegret = 1,
    this.inactionRegretLikelihood = 1,
  }) : id = id ?? const Uuid().v4();

  Option copyWith({
    String? title,
    List<ProCon>? prosCons,
    int? actionRegret,
    int? actionRegretProbability,
    int? inactionRegret,
    int? inactionRegretLikelihood,
  }) {
    return Option(
      id: id,
      title: title ?? this.title,
      prosCons: prosCons ?? this.prosCons,
      actionRegret: actionRegret ?? this.actionRegret,
      actionRegretProbability:
          actionRegretProbability ?? this.actionRegretProbability,
      inactionRegret: inactionRegret ?? this.inactionRegret,
      inactionRegretLikelihood:
          inactionRegretLikelihood ?? this.inactionRegretLikelihood,
    );
  }

  // Logical Score = sum(pro weights) - sum(con weights)
  int get logicalScore {
    int prosSum = prosCons
        .where((pc) => pc.type == ProConType.pro)
        .fold(0, (sum, pc) => sum + pc.weight);
    int consSum = prosCons
        .where((pc) => pc.type == ProConType.con)
        .fold(0, (sum, pc) => sum + pc.weight);
    return prosSum - consSum;
  }

  // Regret Score = (action regret × probability weight) − (inaction regret × weight)
  // Assuming 1-10 mapped. I'll use straightforward multiplication.
  double get regretScore {
    double actionScore = (actionRegret * actionRegretProbability).toDouble();
    double inactionScore = (inactionRegret * inactionRegretLikelihood)
        .toDouble();
    return actionScore - inactionScore;
  }
}
