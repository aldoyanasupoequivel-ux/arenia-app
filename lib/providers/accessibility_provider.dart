import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider extends ChangeNotifier {
  static const String _audioKey = 'audio_enabled';
  static const String _textScaleKey = 'text_scale_factor';

  bool _isAudioEnabled = false; // Por defecto desactivado
  double _textScaleFactor = 1.0; // 1.0 es normal, 1.2 es grande

  bool get isAudioEnabled => _isAudioEnabled;
  double get textScaleFactor => _textScaleFactor;

  bool get isLargeText => _textScaleFactor > 1.0;

  AccessibilityProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isAudioEnabled = prefs.getBool(_audioKey) ?? false;
    _textScaleFactor = prefs.getDouble(_textScaleKey) ?? 1.0;
    notifyListeners();
  }

  Future<void> toggleAudio() async {
    _isAudioEnabled = !_isAudioEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_audioKey, _isAudioEnabled);
    notifyListeners();
  }

  Future<void> toggleTextSize() async {
    _textScaleFactor = _textScaleFactor == 1.0 ? 1.20 : 1.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, _textScaleFactor);
    notifyListeners();
  }
}
