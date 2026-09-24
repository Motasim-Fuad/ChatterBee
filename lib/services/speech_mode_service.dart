import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SpeechMode {
  speakImmediately,
  buildThenSpeak,
  speakImmediatelyOnly,
}

class SpeechModeService extends GetxService {
  static SpeechModeService get to => Get.find();

  static const _storageKey = 'speech_mode';

  final Rx<SpeechMode> currentMode = SpeechMode.speakImmediately.obs;

  bool get speaksOnTap =>
      currentMode.value == SpeechMode.speakImmediately ||
      currentMode.value == SpeechMode.speakImmediatelyOnly;

  bool get buildsSentence =>
      currentMode.value == SpeechMode.speakImmediately ||
      currentMode.value == SpeechMode.buildThenSpeak;

  bool get showSentenceBar =>
      currentMode.value != SpeechMode.speakImmediatelyOnly;

  Future<SpeechModeService> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentMode.value = _fromKey(prefs.getString(_storageKey));
    return this;
  }

  Future<void> setMode(SpeechMode mode) async {
    currentMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }

  SpeechMode _fromKey(String? value) {
    switch (value) {
      case 'buildThenSpeak':
        return SpeechMode.buildThenSpeak;
      case 'speakImmediatelyOnly':
      case 'immediateOnly':
        return SpeechMode.speakImmediatelyOnly;
      default:
        return SpeechMode.buildThenSpeak;
    }
  }
}
