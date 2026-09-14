import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:chatter_bee/services/notification_controller.dart';
import 'package:chatter_bee/services/notification_services.dart';
import 'package:chatter_bee/services/revenueCat_services.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:chatter_bee/services/sentence_bar_service.dart';
import 'package:chatter_bee/services/speech_mode_service.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/my_app.dart';
import 'feature/Profile/controller/pro_status_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await StorageService().init();
    await Get.putAsync(() async => CommunicatorSessionService());
    await Get.putAsync(() async => await NotificationService().init());

    Get.put(NotificationControllerFCM());
    await RevenueCatService.instance.init();
    await Get.putAsync(() => TtsService().onInit().then((_) => TtsService()));
    await Get.putAsync(() => SpeechModeService().init());
    Get.put(SentenceBarService(), permanent: true);
    Get.put(ProStatusController(), permanent: true);
    runApp(const MyApp());
  } catch (e, stack) {
    print('ERROR: $e');
    print(stack);
  }
}
