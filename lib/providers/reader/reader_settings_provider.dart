// lib/providers/reader/reader_settings_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader_settings_provider.freezed.dart';
part 'reader_settings_provider.g.dart';

/// Reader UI settings (font, typeface, alignment, immersive mode)
@freezed
class ReaderSettings with _$ReaderSettings {
  const factory ReaderSettings({
    @Default(ReaderTypeface.serif) ReaderTypeface typeface,
    @Default(1.0) double fontScale,
    @Default(1.0) double lineHeightScale,
    @Default(true) bool useJustifyAlignment,
    @Default(false) bool immersiveMode,
  }) = _ReaderSettings;
}

enum ReaderTypeface { serif, sans }

/// StateNotifier provider for reader settings
@riverpod
class ReaderSettingsNotifier extends _$ReaderSettingsNotifier {
  @override
  ReaderSettings build() => const ReaderSettings();

  void setTypeface(ReaderTypeface typeface) =>
      state = state.copyWith(typeface: typeface);

  void setFontScale(double scale) =>
      state = state.copyWith(fontScale: scale.clamp(0.5, 2.0));

  void setLineHeightScale(double scale) =>
      state = state.copyWith(lineHeightScale: scale.clamp(0.8, 2.0));

  void toggleJustifyAlignment() =>
      state = state.copyWith(useJustifyAlignment: !state.useJustifyAlignment);

  void setJustifyAlignment(bool value) =>
      state = state.copyWith(useJustifyAlignment: value);

  void toggleImmersiveMode() =>
      state = state.copyWith(immersiveMode: !state.immersiveMode);
}
