import 'package:flutter/material.dart';

class ResultConfig {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final List<ResultAction> actions;

  const ResultConfig({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.actions,
  });
}

class ResultAction {
  final String label;
  final String url;

  const ResultAction({
    required this.label,
    required this.url,
  });
}
