import 'dart:async';
import 'dart:ui';

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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'app/my_app.dart';
import 'feature/Profile/controller/pro_status_controller.dart';
import 'firebase_options.dart';

/// Runs one startup step. A failing or hanging step must NEVER stop the app
/// from opening (Google Play: "app doesn't open or load").
Future<void> _safe(
  String name,
  Future<void> Function() task, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  try {
    await task().timeout(timeout);
  } catch (e, st) {
    debugPrint('[BOOT] $name failed: $e');
    debugPrint('$st');
  }
}

Future<void> _boot() async {
  await _safe('dotenv', () => dotenv.load(fileName: '.env'));
  await _safe(
    'firebase',
    () async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    },
  );
  await _safe('storage', () => StorageService().init());
  await _safe('session', () async {
    await Get.putAsync(() async => CommunicatorSessionService());
  });
  if (!Get.isRegistered<CommunicatorSessionService>()) {
    Get.put(CommunicatorSessionService());
  }

  // Notifications: register immediately, but do the slow parts (permission
  // dialog, FCM/APNs token) in the background, never before runApp().
  final notifications = Get.put(NotificationService());
  Get.put(NotificationControllerFCM());
  unawaited(_safe(
    'notifications',
    () async {
      await notifications.init();
    },
    timeout: const Duration(seconds: 90),
  ));

  await _safe('revenuecat', () => RevenueCatService.instance.init());

  final tts = Get.put(TtsService(), permanent: true);
  unawaited(_safe(
    'tts',
    () async {
      await tts.init();
    },
    timeout: const Duration(seconds: 20),
  ));

  final speechMode = Get.put(SpeechModeService());
  await _safe('speechMode', () async {
    await speechMode.init();
  });

  Get.put(SentenceBarService(), permanent: true);
  Get.put(ProStatusController(), permanent: true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uncaught async errors are logged instead of killing the app.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[UNCAUGHT] $error');
    debugPrint('$stack');
    return true;
  };

  try {
    await _boot();
    runApp(const MyApp());
  } catch (e, st) {
    debugPrint('[BOOT] fatal: $e');
    debugPrint('$st');
    runApp(_BootErrorApp(error: e.toString(), onRetry: main));
  }
}

/// Shown instead of a blank screen if startup fails unexpectedly.
class _BootErrorApp extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;
  const _BootErrorApp({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'ChatterBee could not start.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(error,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => onRetry(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
