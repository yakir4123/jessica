import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audit_logs.g.dart';

@JsonSerializable()
class AuditColumnSettings {
  final String query;
  final String column;
  final String? operator;
  final String? value;

  AuditColumnSettings({
    required this.query,
    required this.column,
    this.operator,
    this.value,
  });

  // JSON serialization/deserialization methods
  factory AuditColumnSettings.fromJson(Map<String, dynamic> json) =>
      _$AuditColumnSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AuditColumnSettingsToJson(this);
  @override
  String toString() {
    if (query == 'select'){
      return column;
    }
    return '$column $operator $value';
  }

  Color getColor(BuildContext context) {
    if (query == 'select'){
      return Theme.of(context).cardColor;
    }
    return Theme.of(context).colorScheme.primary;
  }
}
