import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TtsService extends GetxService {
  static TtsService get to => Get.find();

  final FlutterTts _tts = FlutterTts();

  final RxBool isSpeaking = false.obs;

  Future<TtsService> init() async {
    try {
      if (Platform.isIOS) {
        await _tts.setSharedInstance(true);
        await _applyIosAudioSession();
      }
      if (Platform.isAndroid) {
        final engine = await _tts.getDefaultEngine;
        if (engine is String && engine.isNotEmpty) {
          await _tts.setEngine(engine);
        }
      }
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('TtsService init error: $e');
    }

    _tts.setStartHandler(() => isSpeaking.value = true);
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    _tts.setCancelHandler(() => isSpeaking.value = false);
    _tts.setErrorHandler((msg) {
      debugPrint('TTS error: $msg');
      isSpeaking.value = false;
    });
    return this;
  }

  Future<void> _applyIosAudioSession() async {
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.duckOthers,
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      ],
      IosTextToSpeechAudioMode.spokenAudio,
    );
  }

  Future<void> speak(String text, {String lang = 'en'}) async {
    if (text.trim().isEmpty) return;

    try {
      await stop();
      if (Platform.isIOS) {
        await _applyIosAudioSession();
      }
      await _tts.setLanguage(_mapLang(lang));
      await _tts.setVolume(1.0);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
      isSpeaking.value = false;
    }
  }

  Future<void> speakWhenIdle(String text, {String lang = 'en'}) async {
    final deadline = DateTime.now().add(const Duration(seconds: 8));
    while (isSpeaking.value && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 80));
    }
    await speak(text, lang: lang);
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    isSpeaking.value = false;
  }

  String _mapLang(String lang) {
    switch (lang) {
      case 'es': return 'es-ES';
      case 'ar': return 'ar-SA';
      default:   return 'en-US';
    }
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}
