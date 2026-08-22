import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunicatorSessionService extends GetxService {
  static const String _communicatorIdKey = 'selected_communicator_id';
  static const String _communicatorNameKey = 'selected_communicator_name';

  final RxInt communicatorId = 0.obs;
  final RxString communicatorName = ''.obs;

  // Singleton accessor
  static CommunicatorSessionService get to => Get.find();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    communicatorId.value = prefs.getInt(_communicatorIdKey) ?? 0;
    communicatorName.value = prefs.getString(_communicatorNameKey) ?? '';
  }

  Future<void> setSelected(int id, String name) async {
    communicatorId.value = id;
    communicatorName.value = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_communicatorIdKey, id);
    await prefs.setString(_communicatorNameKey, name);
  }

  Future<void> clear() async {
    communicatorId.value = 0;
    communicatorName.value = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_communicatorIdKey);
    await prefs.remove(_communicatorNameKey);
  }

  bool get hasSelected => communicatorId.value != 0;
}
