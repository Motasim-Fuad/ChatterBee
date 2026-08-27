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

  bool get buildsSentence =>
      currentMode.value != SpeechMode.speakImmediatelyOnly;

  bool get speaksOnTap =>
      currentMode.value != SpeechMode.buildThenSpeak;

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
    return SpeechMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => SpeechMode.speakImmediately,
    );
  }
}
