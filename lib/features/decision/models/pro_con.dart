import 'package:uuid/uuid.dart';

enum ProConType { pro, con }

class ProCon {
  final String id;
  final String description;
  final int weight; // 1 to 5
  final ProConType type;

  ProCon({
    String? id,
    required this.description,
    required this.weight,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  ProCon copyWith({String? description, int? weight, ProConType? type}) {
    return ProCon(
      id: id,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      type: type ?? this.type,
    );
  }
}
