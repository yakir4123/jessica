// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equity_curves.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquityCurvesModel _$EquityCurvesModelFromJson(Map<String, dynamic> json) =>
    EquityCurvesModel(
      strategyId: json['strategy_id'] as String,
      values: (json['values'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$EquityCurvesModelToJson(EquityCurvesModel instance) =>
    <String, dynamic>{
      'strategy_id': instance.strategyId,
      'values': instance.values,
    };
