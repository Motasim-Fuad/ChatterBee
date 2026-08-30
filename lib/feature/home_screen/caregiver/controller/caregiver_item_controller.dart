import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/caregiver_repository/caregiver_customization_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/speech_mode_service.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:chatter_bee/utils/buddy_bee_encouragement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CaregiverItemController extends GetxController {
  final CaregiverCustomizationRepository _repo =
  CaregiverCustomizationRepository();
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecorderInitialized = false;
  late final dynamic parent;
  String get parentTitle => parent is SubCategoryModel
      ? (parent as SubCategoryModel).name
      : (parent as CategoryModel).name;
  int get parentId => parent is SubCategoryModel
      ? (parent as SubCategoryModel).id
      : (parent as CategoryModel).id;

  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxSet<int> selectedIds = <int>{}.obs;
  final RxInt playingItemId = (-1).obs;
  final RxInt selectedItemId = (-1).obs;
  final RxString selectedWord = ''.obs;
  final RxString selectedImage = ''.obs;
  final RxString selectedColor = '#FFD700'.obs;

  final RxString formColorHex = '#FFD700'.obs;
  final Rx<File?> formImageFile = Rx<File?>(null);
  final Rx<File?> formAudioFile = Rx<File?>(null);
  final RxString audioFileName = ''.obs;
  final RxBool isRecording = false.obs;
  final RxBool isPlayingFormAudio = false.obs;
  final RxBool formLoading = false.obs;

  ItemModel? _editingItem;

  String get itemInitialWord => _editingItem?.word ?? '';

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _soundPlayer;

  final List<Map<String, String>> colorOptions = [
    {'hex': '#FFD700', 'label': 'Gold'},
    {'hex': '#FFC857', 'label': 'Yellow'},
    {'hex': '#FF5733', 'label': 'Orange Red'},
    {'hex': '#4CAF50', 'label': 'Green'},
    {'hex': '#2196F3', 'label': 'Blue'},
    {'hex': '#9C27B0', 'label': 'Purple'},
    {'hex': '#E91E63', 'label': 'Pink'},
    {'hex': '#B5CFD1', 'label': 'Light Blue'},
  ];

  @override
  void onInit() {
    super.onInit();
    parent = Get.arguments;
    if (parent is SubCategoryModel) {
      items.value = (parent as SubCategoryModel).items;
    } else if (parent is CategoryModel) {
      items.value = (parent as CategoryModel).items;
    } else {
      throw ArgumentError('Caregiver item screen requires a category or sub-category');
    }
    _initAudio();
  }

  Future<void> _initAudio() async {
    _recorder = FlutterSoundRecorder();
    _soundPlayer = FlutterSoundPlayer();
    await _recorder!.openRecorder();
    _isRecorderInitialized = true;
    await _soundPlayer!.openPlayer();
  }

  // Normalize Lang
  String _normalizeLang(String lang) {
    return lang.split('-').first.split('_').first.toLowerCase();
  }

  String get _currentLang {
    try {
      final raw = LanguageController.to.currentLocale.value.toLanguageTag();
      return _normalizeLang(raw);
    } catch (_) {
      return 'en';
    }
  }

  bool get _isBuddyMode {
    try {
      return Get.find<CaregiverHomeController>().isBuddyMode.value;
    } catch (_) {
      return false;
    }
  }

  Color get formColor {
    try {
      final hex = formColorHex.value.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFFFD700);
    }
  }

  Future<void> refresh() async {
    final communicatorId = CommunicatorSessionService.to.communicatorId.value;
    if (communicatorId == 0) return;

    isLoading.value = true;
    final lang = _currentLang;

    final response = _isBuddyMode
        ? await _repo.getUserBuddyModeContent(communicatorId, lang: lang)
        : await _repo.getUserContent(communicatorId, lang: lang);

    isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      for (final cat in response.data!.categories) {
        if (parent is CategoryModel && cat.id == (parent as CategoryModel).id) {
          items.value = cat.items;
          break;
        }
        if (parent is SubCategoryModel) {
          final sub = cat.subCategories.firstWhereOrNull(
              (s) => s.id == (parent as SubCategoryModel).id);
          if (sub != null) {
            items.value = sub.items;
            break;
          }
        }
      }
      if (Get.isRegistered<CaregiverHomeController>()) {
        Get.find<CaregiverHomeController>().loadContent();
      }
    }
  }


  Future<void> playItemAudio(ItemModel item) async {
    if (item.speak != null && item.speak!.isNotEmpty) {
      final url = AppUrl.mediaUrl(item.speak);
      if (url == null) return;

      if (playingItemId.value == item.id) {
        await _audioPlayer.stop();
        playingItemId.value = -1;
        return;
      }

      playingItemId.value = item.id;
      await _audioPlayer.play(UrlSource(url));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (playingItemId.value == item.id) playingItemId.value = -1;
      });
    } else {
      await TtsService.to.speak(item.word ?? '', lang: _currentLang);
    }
  }

  void onItemTap(ItemModel item) {
    final word = item.word ?? '';
    if (SpeechModeService.to.speaksOnTap) {
      if (selectedItemId.value == item.id) {
        clearSelectionBar();
        return;
      }
      selectedItemId.value = item.id;
      selectedWord.value = word;
      selectedImage.value = item.imageIcon ?? '';
      selectedColor.value = item.color;
      TtsService.to.speak(word, lang: _currentLang);
      BuddyBeeEncouragement.maybeShow();
      return;
    }
    selectedItemId.value = item.id;
    selectedImage.value = item.imageIcon ?? '';
    selectedColor.value = item.color;
    if (selectedWord.value.trim().isEmpty) {
      selectedWord.value = word;
    } else {
      selectedWord.value = '${selectedWord.value} $word';
    }
  }

  void promptTypedText() {
    Get.toNamed(AppRoutes.TEXT_TO_SPEAK);
  }

  Future<void> speakSelected() async {
    if (selectedWord.value.trim().isEmpty) return;
    await TtsService.to.speak(selectedWord.value, lang: _currentLang);
    BuddyBeeEncouragement.maybeShow();
  }

  void clearSelectionBar() {
    TtsService.to.stop();
    selectedItemId.value = -1;
    selectedWord.value = '';
    selectedImage.value = '';
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) selectedIds.clear();
  }

  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void showAddSheet() {
    _editingItem = null;
    _resetFormState();
    _showItemSheet('add_item'.tr);
  }

  void showEditSheet(ItemModel item) {
    _editingItem = item;
    formColorHex.value = item.color.isNotEmpty ? item.color : '#FFD700';
    formImageFile.value = null;
    formAudioFile.value = null;
    audioFileName.value = '';
    isRecording.value = false;
    isPlayingFormAudio.value = false;
    _showItemSheet('edit'.tr);
  }

  void _resetFormState() {
    formColorHex.value = '#FFD700';
    formImageFile.value = null;
    formAudioFile.value = null;
    audioFileName.value = '';
    isRecording.value = false;
    isPlayingFormAudio.value = false;
  }

  void _showItemSheet(String title) {
    Get.bottomSheet(
      ItemFormSheet(controller: this, title: title),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> save(String word) async {
    if (word.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_word'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    formLoading.value = true;
    final lang = _currentLang;
    debugPrint('Item save lang: $lang');

    if (_editingItem != null) {
      final response = await _repo.updateItem(
        itemId: _editingItem!.id,
        word: word.trim(),
        color: formColorHex.value,
        imageFile: formImageFile.value,
        audioFile: formAudioFile.value,
        lang: lang,
      );
      formLoading.value = false;
      if (response.isSuccess) {
        Get.back();
        await refresh();
        Get.snackbar('updated'.tr, 'item_updated'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, response.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      final communicatorId =
          CommunicatorSessionService.to.communicatorId.value;
      final response = await _repo.createItem(
        categoryId: parentId,
        word: word.trim(),
        color: formColorHex.value,
        communicatorId: communicatorId,
        imageFile: formImageFile.value,
        audioFile: formAudioFile.value,
        lang: lang,
      );
      formLoading.value = false;
      if (response.isSuccess) {
        Get.back();
        await refresh();
        Get.snackbar('created'.tr, 'item_created'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, response.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<bool> requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      return status.isGranted;
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512);
    if (picked != null) formImageFile.value = File(picked.path);
  }

  void removeImage() => formImageFile.value = null;

  Future<void> toggleRecording() async {
    final hasPermission = await requestMicPermission();
    if (!hasPermission) return;

    if (_recorder == null || !_isRecorderInitialized) {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
    }

    if (isRecording.value) {
      final path = await _recorder!.stopRecorder();
      isRecording.value = false;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          formAudioFile.value = file;
          audioFileName.value = 'recorded_audio.aac';
          debugPrint('Item Audio saved: $path');
        } else {
          debugPrint('Item Audio not found: $path');
        }
      }
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final recordPath =
          '${dir.path}/item_audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: recordPath, codec: Codec.aacADTS);
      isRecording.value = true;
    }
  }

  Future<void> toggleFormAudioPlayback() async {
    if (formAudioFile.value == null) return;
    if (isPlayingFormAudio.value) {
      await _soundPlayer!.stopPlayer();
      isPlayingFormAudio.value = false;
    } else {
      isPlayingFormAudio.value = true;
      await _soundPlayer!.startPlayer(
        fromURI: formAudioFile.value!.path,
        whenFinished: () => isPlayingFormAudio.value = false,
      );
    }
  }

  Future<void> removeAudio() async {
    formAudioFile.value = null;
    audioFileName.value = '';
    if (isPlayingFormAudio.value) {
      await _soundPlayer?.stopPlayer();
      isPlayingFormAudio.value = false;
    }
    if (isRecording.value) {
      await _recorder?.stopRecorder();
      isRecording.value = false;
    }
  }

  @override
  void onClose() {
    _recorder?.closeRecorder();
    _soundPlayer?.closePlayer();
    _audioPlayer.dispose();
    _isRecorderInitialized = false;
    super.onClose();
  }
}


class ItemFormSheet extends StatefulWidget {
  final CaregiverItemController controller;
  final String title;

  const ItemFormSheet({super.key, required this.controller, required this.title});

  @override
  State<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<ItemFormSheet> {
  late final TextEditingController _wordCtrl;

  @override
  void initState() {
    super.initState();
    _wordCtrl = TextEditingController(text: widget.controller.itemInitialWord);
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20, bottom: bottomInset + 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(
              controller: _wordCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'word_label'.tr,
                hintText: 'word_hint'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFC857), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('color'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 10, runSpacing: 10,
              children: c.colorOptions.map((opt) {
                Color col;
                try {
                  col = Color(int.parse('FF${opt['hex']!.replaceAll('#', '')}', radix: 16));
                } catch (_) {
                  col = const Color(0xFFFFD700);
                }
                final isSelected = c.formColorHex.value == opt['hex'];
                return GestureDetector(
                  onTap: () => c.formColorHex.value = opt['hex']!,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: col, shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.transparent, width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: col.withOpacity(0.5), blurRadius: 6)]
                          : [],
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 16),
            Text('image_optional'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() => c.formImageFile.value != null
                ? Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(c.formImageFile.value!, width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: c.removeImage,
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                label: Text('remove'.tr, style: const TextStyle(color: Colors.red)),
              ),
            ])
                : OutlinedButton.icon(
              onPressed: c.pickImage,
              icon: const Icon(Icons.image_outlined),
              label: Text('choose_image'.tr),
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
            const SizedBox(height: 16),
            Text('voice_audio_speak'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() {
              final hasAudio = c.formAudioFile.value != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _AudioBtn(
                      icon: c.isRecording.value ? Icons.stop : Icons.mic,
                      color: c.isRecording.value ? Colors.red : const Color(0xFFFFC857),
                      label: c.isRecording.value ? 'stop'.tr : 'record'.tr,
                      onTap: c.toggleRecording,
                    ),
                    if (hasAudio) ...[
                      const SizedBox(width: 10),
                      _AudioBtn(
                        icon: c.isPlayingFormAudio.value ? Icons.stop : Icons.play_arrow,
                        color: const Color(0xFF4CAF50),
                        label: c.isPlayingFormAudio.value ? 'stop'.tr : 'play'.tr,
                        onTap: c.toggleFormAudioPlayback,
                      ),
                      const SizedBox(width: 10),
                      _AudioBtn(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        label: 'delete'.tr,
                        onTap: c.removeAudio,
                      ),
                    ],
                  ]),
                  if (c.isRecording.value) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(width: 8, height: 8,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('recording_indicator'.tr,
                          style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ]),
                  ],
                  if (hasAudio && !c.isRecording.value) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.audio_file, color: Color(0xFF4CAF50), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            c.audioFileName.value.isEmpty ? 'audio_ready'.tr : c.audioFileName.value,
                            style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text('record_voice_hint2'.tr,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              );
            }),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: c.formLoading.value ? null : () => c.save(_wordCtrl.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC857),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: c.formLoading.value
                    ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text('save'.tr,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _AudioBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _AudioBtn({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
