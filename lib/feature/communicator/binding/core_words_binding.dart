import 'package:chatter_bee/feature/communicator/controller/core_words_controller.dart';
import 'package:get/get.dart';

class CoreWordsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoreWordsController>(
          () => CoreWordsController(),
    );
  }
}
