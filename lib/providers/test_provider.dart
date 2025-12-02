// lib/providers/test_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'test_provider.g.dart';

/// Test provider to verify riverpod_generator code generation
@riverpod
String helloWorld(Ref ref) {
  return 'Hello from Riverpod!';
}

/// Test async provider
@riverpod
Future<String> asyncHelloWorld(Ref ref) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return 'Async Hello from Riverpod!';
}
