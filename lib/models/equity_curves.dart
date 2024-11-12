import 'package:json_annotation/json_annotation.dart';

part 'equity_curves.g.dart';

@JsonSerializable()
class EquityCurvesModel {
  @JsonKey(name: 'strategy_id')
  final String strategyId;

  @JsonKey(name: 'values')
  final List<double> values;

  EquityCurvesModel({
    required this.strategyId,
    required this.values,
  });

  // A factory constructor for creating a new instance from a map.
  factory EquityCurvesModel.fromJson(Map<String, dynamic> json) =>
      _$EquityCurvesModelFromJson(json);

  // A method to convert the instance back to JSON.
  Map<String, dynamic> toJson() => _$EquityCurvesModelToJson(this);
}
