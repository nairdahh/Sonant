import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple theme mode provider (light/dark).
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});
