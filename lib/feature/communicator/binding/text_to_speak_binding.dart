import 'package:chatter_bee/feature/communicator/controller/text_to_speak_controller.dart';
import 'package:get/get.dart';

class TextToSpeakBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TextToSpeakController>(
          () => TextToSpeakController(),
    );
  }
}
