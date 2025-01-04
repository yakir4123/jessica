// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_logs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditColumnSettings _$AuditColumnSettingsFromJson(Map<String, dynamic> json) =>
    AuditColumnSettings(
      query: json['query'] as String,
      column: json['column'] as String,
      operator: json['operator'] as String?,
      value: json['value'] as String?,
    );

Map<String, dynamic> _$AuditColumnSettingsToJson(
        AuditColumnSettings instance) =>
    <String, dynamic>{
      'query': instance.query,
      'column': instance.column,
      'operator': instance.operator,
      'value': instance.value,
    };
