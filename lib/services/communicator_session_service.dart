import 'package:chatter_bee/Repository/profile_invitation_repo.dart';
import 'package:chatter_bee/models/profile_invitation_model/profile_invitation_model.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:chatter_bee/services/storage/secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunicatorSessionService extends GetxService {
  static const String _communicatorIdKey = 'selected_communicator_id';
  static const String _communicatorNameKey = 'selected_communicator_name';
  static const String _caregiverIdKey = 'linked_caregiver_id';
  static const String _caregiverNameKey = 'linked_caregiver_name';

  final RxInt communicatorId = 0.obs;
  final RxString communicatorName = ''.obs;

  /// Caregiver this device switched FROM (so we can switch back freely).
  final RxInt caregiverId = 0.obs;
  final RxString caregiverName = ''.obs;

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
    caregiverId.value = prefs.getInt(_caregiverIdKey) ?? 0;
    caregiverName.value = prefs.getString(_caregiverNameKey) ?? '';
  }

  Future<void> setCaregiver(int id, String name) async {
    caregiverId.value = id;
    caregiverName.value = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_caregiverIdKey, id);
    await prefs.setString(_caregiverNameKey, name);
  }

  bool get hasCaregiver => caregiverId.value != 0;

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
    caregiverId.value = 0;
    caregiverName.value = '';
    await prefs.remove(_caregiverIdKey);
    await prefs.remove(_caregiverNameKey);
  }

  bool get hasSelected => communicatorId.value != 0;

  
  Future<int?> resolveActivityCommunicatorId() async {
    final role = StorageService().getUserRole()?.trim().toLowerCase();
    if (role == 'communicator') {
      final raw = await SecureStorageService().getUserId();
      final id = int.tryParse(raw ?? '') ?? 0;
      if (id != 0) {
        if (communicatorId.value != id) {
          await setSelected(id, communicatorName.value);
        }
        return id;
      }
    }

    if (communicatorId.value != 0) return communicatorId.value;

    if (role == 'caregiver') {
      await _selectFirstLinkedCommunicator();
      if (communicatorId.value != 0) return communicatorId.value;
    }
    return null;
  }

  Future<void> _selectFirstLinkedCommunicator() async {
    try {
      final response = await ProfileInvitationRepo().listConnections();
      if (!response.isSuccess || response.data == null) return;
      final connections = _parseConnections(response.data!);
      if (connections.isEmpty) return;
      final preferred = connections.firstWhereOrNull((c) => c.isSelected) ??
          connections.first;
      if (preferred.communicatorId != 0) {
        await setSelected(
          preferred.communicatorId,
          preferred.communicatorName,
        );
      }
    } catch (_) {}
  }

  List<ConnectionModel> _parseConnections(Map<String, dynamic> responseData) {
    List<dynamic> rawList = [];
    if (responseData['data'] is Map) {
      rawList = responseData['data']['connections'] ?? [];
    } else if (responseData['connections'] is List) {
      rawList = responseData['connections'];
    } else if (responseData['results'] is List) {
      rawList = responseData['results'];
    } else if (responseData['data'] is List) {
      rawList = responseData['data'];
    }
    return rawList
        .whereType<Map>()
        .map((e) => ConnectionModel.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.communicatorId != 0)
        .toList();
  }
}
