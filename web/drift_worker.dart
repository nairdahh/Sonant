// web/drift_worker.dart
// Worker script for Drift database on Web

import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
