import 'package:flutter/material.dart';

class FirstAidGuide {
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;

  FirstAidGuide({
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
  });
}
