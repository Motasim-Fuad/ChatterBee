import 'dart:io';
import 'package:chatter_bee/Repository/caregiver_repository/caregiver_customization_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:chatter_bee/services/pro_access_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

const List<Map<String, String>> kColorOptions = [
  {'hex': '#B5CFD1', 'label': 'Teal'},
  {'hex': '#FFD700', 'label': 'Gold'},
  {'hex': '#FFC857', 'label': 'Yellow'},
  {'hex': '#FF5733', 'label': 'Orange Red'},
  {'hex': '#4CAF50', 'label': 'Green'},
  {'hex': '#2196F3', 'label': 'Blue'},
  {'hex': '#9C27B0', 'label': 'Purple'},
  {'hex': '#E91E63', 'label': 'Pink'},
];

class CaregiverHomeController extends GetxController {
  final CaregiverCustomizationRepository _repo =
  CaregiverCustomizationRepository();
  final AuthRepository _authRepository = AuthRepository();
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final RxBool isLoading = false.obs;
  final RxString loadError = ''.obs;
  final RxBool isBuddyMode = false.obs;
  final RxBool isEditMode = false.obs;
  final RxBool isQsEditMode = false.obs;
  final RxSet<int> selectedCategoryIds = <int>{}.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<QuickSpeakModel> quickSpeaks = <QuickSpeakModel>[].obs;
  final RxInt selectedQuickSpeakId = (-1).obs;
  final RxString selectedQuickSpeakText = ''.obs;
  final RxString selectedQuickSpeakImage = ''.obs;
  final RxString selectedQuickSpeakColor = '#FFD700'.obs;

  List<CategoryModel> get apiCategories => categories;

  final RxString catColorHex = '#B5CFD1'.obs;
  final Rx<File?> catImageFile = Rx<File?>(null);
  final RxBool catFormLoading = false.obs;
  CategoryModel? _editingCategory;

  final RxString qsColorHex = '#FFD700'.obs;
  final Rx<File?> qsImageFile = Rx<File?>(null);
  final Rx<File?> qsAudioFile = Rx<File?>(null);
  final RxString qsAudioFileName = ''.obs;
  final RxBool qsIsRecording = false.obs;
  final RxBool qsIsPlayingAudio = false.obs;
  final RxBool qsFormLoading = false.obs;
  QuickSpeakModel? _editingQuickSpeak;

  String get catInitialName => _editingCategory?.name ?? '';
  String get qsInitialWord => _editingQuickSpeak?.word ?? '';

  bool _isRecorderInitialized = false;
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _soundPlayer;

  @override
  void onInit() {
    super.onInit();
    _initAudio();
    _initLoad();
  }

  Future<void> _initAudio() async {
    _recorder = FlutterSoundRecorder();
    _soundPlayer = FlutterSoundPlayer();
    await _recorder!.openRecorder();
    _isRecorderInitialized = true;
    await _soundPlayer!.openPlayer();
  }

  Future<void> _initLoad() async {
    await _fetchProfile();
    await loadContent();
  }

  Future<void> _fetchProfile() async {
    try {
      final profileRes = await _authRepository.getProfile();
      if (profileRes.isSuccess && profileRes.data != null) {
        final data = profileRes.data!['data'] ?? profileRes.data!;
        isBuddyMode.value = data['buddy_mode'] ?? false;
      }
    } catch (e) {
      debugPrint('CaregiverHomeController: profile fetch error: $e');
    }
  }

  // Normalize Lang
  String _normalizeLang(String lang) {
    return lang.split('-').first.split('_').first.toLowerCase();
  }

  String get _currentLang {
    try {
      final raw = LanguageController.to.currentLocale.value.toLanguageTag();
      final normalized = _normalizeLang(raw);
      debugPrint('🌐 lang raw=$raw normalized=$normalized');
      return normalized;
    } catch (_) {
      return 'en';
    }
  }

  Future<void> loadContent() async {
    final communicatorId = CommunicatorSessionService.to.communicatorId.value;
    if (communicatorId == 0) {
      categories.clear();
      quickSpeaks.clear();
      loadError.value = 'Please select a communicator first.';
      return;
    }

    isLoading.value = true;
    loadError.value = '';
    final lang = _currentLang;

    final response = isBuddyMode.value
        ? await _repo.getUserBuddyModeContent(communicatorId, lang: lang)
        : await _repo.getUserContent(communicatorId, lang: lang);

    isLoading.value = false;

    if (response.isSuccess && response.data != null) {
      categories.assignAll(response.data!.categories);
      quickSpeaks.assignAll(response.data!.quickSpeaks);
    } else {
      categories.clear();
      quickSpeaks.clear();
      loadError.value = response.message.isNotEmpty
          ? response.message
          : 'Failed to load content.';
    }
  }

  Future<void> refresh() => loadContent();

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) selectedCategoryIds.clear();
  }

  void toggleQsEditMode() => isQsEditMode.value = !isQsEditMode.value;

  void toggleCategorySelection(int id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
  }

  void onCategoryTap(CategoryModel category) {
    if (isEditMode.value) {
      toggleCategorySelection(category.id);
    } else if (category.subCategories.isEmpty) {
      Get.toNamed('/item-screen', arguments: category);
    } else {
      Get.toNamed('/sub-category', arguments: category);
    }
  }


  void selectQuickSpeak(QuickSpeakModel qs) {
    selectedQuickSpeakId.value = qs.id;
    selectedQuickSpeakText.value = qs.word ?? '';
    selectedQuickSpeakImage.value = AppUrl.mediaUrl(qs.imageIcon) ?? '';
    selectedQuickSpeakColor.value = qs.color;
  }

  void clearQuickSpeak() {
    TtsService.to.stop();
    selectedQuickSpeakId.value = -1;
    selectedQuickSpeakText.value = '';
    selectedQuickSpeakImage.value = '';
  }

  Future<void> speakSelectedQuickSpeak() async {
    if (selectedQuickSpeakText.value.isEmpty) return;
    await TtsService.to.speak(selectedQuickSpeakText.value, lang: _currentLang);
  }

  Future<void> playQuickSpeak(QuickSpeakModel qs) async {
    selectQuickSpeak(qs);
    await speakSelectedQuickSpeak();
  }

  void showAddCategorySheet() {
    _editingCategory = null;
    catColorHex.value = '#B5CFD1';
    catImageFile.value = null;
    _openSheet(_CategorySheet(controller: this, title: 'add_category'.tr));
  }

  void showEditCategorySheet(CategoryModel cat) {
    _editingCategory = cat;
    catColorHex.value = cat.color.isNotEmpty ? cat.color : '#B5CFD1';
    catImageFile.value = null;
    _openSheet(_CategorySheet(controller: this, title: 'edit'.tr));
  }

  Future<void> pickCatImage() async {
    if (!ProAccessGate.allowOrPrompt()) return;
    final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512);
    if (picked != null) catImageFile.value = File(picked.path);
  }

  void removeCatImage() => catImageFile.value = null;

  Future<void> saveCategory(String name) async {
    if (name.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_name'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    catFormLoading.value = true;
    final communicatorId = CommunicatorSessionService.to.communicatorId.value;
    final lang = _currentLang;

    if (_editingCategory != null) {
      final res = await _repo.updateCategory(
        categoryId: _editingCategory!.id,
        name: name.trim(),
        color: catColorHex.value,
        imageFile: catImageFile.value,
        lang: lang,
      );
      catFormLoading.value = false;
      if (res.isSuccess) {
        Get.back();
        await loadContent();
        Get.snackbar('updated'.tr, 'category_updated'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      final res = await _repo.createCategory(
        name: name.trim(),
        color: catColorHex.value,
        communicatorId: communicatorId,
        order: categories.length,
        imageFile: catImageFile.value,
        lang: lang,
      );
      catFormLoading.value = false;
      if (res.isSuccess) {
        Get.back();
        await loadContent();
        Get.snackbar('created'.tr, 'category_created'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void showAddQuickSpeakSheet() {
    _editingQuickSpeak = null;
    qsColorHex.value = '#FFD700';
    qsImageFile.value = null;
    qsAudioFile.value = null;
    qsAudioFileName.value = '';
    qsIsRecording.value = false;
    qsIsPlayingAudio.value = false;
    _openSheet(_QuickSpeakSheet(controller: this, title: 'quick_speak'.tr));
  }

  void showEditQuickSpeakSheet(QuickSpeakModel qs) {
    _editingQuickSpeak = qs;
    qsColorHex.value = qs.color.isNotEmpty ? qs.color : '#FFD700';
    qsImageFile.value = null;
    qsAudioFile.value = null;
    qsAudioFileName.value = '';
    qsIsRecording.value = false;
    qsIsPlayingAudio.value = false;
    _openSheet(_QuickSpeakSheet(controller: this, title: 'edit'.tr));
  }

  Future<void> pickQsImage() async {
    if (!ProAccessGate.allowOrPrompt()) return;
    final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512);
    if (picked != null) qsImageFile.value = File(picked.path);
  }

  void removeQsImage() => qsImageFile.value = null;

  Future<void> toggleQsRecording() async {
    final perm = await Permission.microphone.request();
    if (!perm.isGranted) {
      Get.snackbar('permission'.tr, 'mic_permission_required'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_recorder == null || !_isRecorderInitialized) {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
    }

    if (qsIsRecording.value) {
      final path = await _recorder!.stopRecorder();
      qsIsRecording.value = false;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          qsAudioFile.value = file;
          qsAudioFileName.value = 'recorded_audio.aac';
          debugPrint('✅ QS Audio saved: $path');
        } else {
          debugPrint('❌ QS Audio not found: $path');
        }
      }
    } else {
      if (qsIsPlayingAudio.value) {
        await _soundPlayer!.stopPlayer();
        qsIsPlayingAudio.value = false;
      }
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/qs_audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: path, codec: Codec.aacADTS);
      qsIsRecording.value = true;
    }
  }

  Future<void> toggleQsPlayback() async {
    if (qsAudioFile.value == null) return;
    if (qsIsPlayingAudio.value) {
      await _soundPlayer!.stopPlayer();
      qsIsPlayingAudio.value = false;
    } else {
      qsIsPlayingAudio.value = true;
      await _soundPlayer!.startPlayer(
        fromURI: qsAudioFile.value!.path,
        whenFinished: () => qsIsPlayingAudio.value = false,
      );
    }
  }

  void removeQsAudio() {
    qsAudioFile.value = null;
    qsAudioFileName.value = '';
    if (qsIsPlayingAudio.value) {
      _soundPlayer!.stopPlayer();
      qsIsPlayingAudio.value = false;
    }
    if (qsIsRecording.value) {
      _recorder!.stopRecorder();
      qsIsRecording.value = false;
    }
  }

  Future<void> saveQuickSpeak(String word) async {
    if (word.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_word'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    qsFormLoading.value = true;
    final communicatorId = CommunicatorSessionService.to.communicatorId.value;
    final lang = _currentLang;

    if (_editingQuickSpeak != null) {
      final res = await _repo.updateQuickSpeak(
        quickSpeakId: _editingQuickSpeak!.id,
        word: word.trim(),
        color: qsColorHex.value,
        imageFile: qsImageFile.value,
        audioFile: null,
        lang: lang,
      );
      qsFormLoading.value = false;
      if (res.isSuccess) {
        Get.back();
        await loadContent();
        Get.snackbar('updated'.tr, 'quick_speak_updated'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      final res = await _repo.createQuickSpeak(
        word: word.trim(),
        color: qsColorHex.value,
        communicatorId: communicatorId,
        imageFile: qsImageFile.value,
        audioFile: null,
        lang: lang,
      );
      qsFormLoading.value = false;
      if (res.isSuccess) {
        Get.back();
        await loadContent();
        Get.snackbar('created'.tr, 'quick_speak_created'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void _openSheet(Widget sheet) {
    Get.bottomSheet(sheet,
        isScrollControlled: true, backgroundColor: Colors.transparent);
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


class _SheetWrapper extends StatelessWidget {
  final Widget child;
  const _SheetWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
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
        child: child,
      ),
    );
  }
}


class _CategorySheet extends StatefulWidget {
  final CaregiverHomeController controller;
  final String title;
  const _CategorySheet({required this.controller, required this.title});

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.controller.catInitialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return _SheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Text(widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: _inputDecoration('category_name_label'.tr),
          ),
          const SizedBox(height: 16),
          Text('color'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(() => Wrap(
            spacing: 10, runSpacing: 10,
            children: kColorOptions.map((opt) {
              final color = _hexToColor(opt['hex']!);
              final selected = c.catColorHex.value == opt['hex'];
              return _ColorDot(color: color, selected: selected,
                  onTap: () => c.catColorHex.value = opt['hex']!);
            }).toList(),
          )),
          const SizedBox(height: 16),
          Text('image_optional'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(() => c.catImageFile.value != null
              ? _ImagePreview(file: c.catImageFile.value!, onRemove: c.removeCatImage)
              : _PickImageBtn(onTap: c.pickCatImage)),
          const SizedBox(height: 24),
          Obx(() => _SaveBtn(
            loading: c.catFormLoading.value,
            onTap: () => c.saveCategory(_nameCtrl.text),
          )),
        ],
      ),
    );
  }
}


class _QuickSpeakSheet extends StatefulWidget {
  final CaregiverHomeController controller;
  final String title;
  const _QuickSpeakSheet({required this.controller, required this.title});

  @override
  State<_QuickSpeakSheet> createState() => _QuickSpeakSheetState();
}

class _QuickSpeakSheetState extends State<_QuickSpeakSheet> {
  late final TextEditingController _wordCtrl;

  @override
  void initState() {
    super.initState();
    _wordCtrl = TextEditingController(text: widget.controller.qsInitialWord);
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return _SheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Text(widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: _wordCtrl,
            autofocus: true,
            decoration: _inputDecoration('word_label'.tr),
          ),
          const SizedBox(height: 16),
          Text('color'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(() => Wrap(
            spacing: 10, runSpacing: 10,
            children: kColorOptions.map((opt) {
              final color = _hexToColor(opt['hex']!);
              final selected = c.qsColorHex.value == opt['hex'];
              return _ColorDot(color: color, selected: selected,
                  onTap: () => c.qsColorHex.value = opt['hex']!);
            }).toList(),
          )),
          const SizedBox(height: 16),
          Text('image_optional'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(() => c.qsImageFile.value != null
              ? _ImagePreview(file: c.qsImageFile.value!, onRemove: c.removeQsImage)
              : _PickImageBtn(onTap: c.pickQsImage)),
          if (false) ...[
          const SizedBox(height: 16),
          Text('voice_audio_speak'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(() {
            final hasAudio = c.qsAudioFile.value != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _AudioBtn(
                    icon: c.qsIsRecording.value ? Icons.stop : Icons.mic,
                    color: c.qsIsRecording.value ? Colors.red : const Color(0xFFFFC857),
                    label: c.qsIsRecording.value ? 'stop'.tr : 'record'.tr,
                    onTap: c.toggleQsRecording,
                  ),
                  if (hasAudio) ...[
                    const SizedBox(width: 10),
                    _AudioBtn(
                      icon: c.qsIsPlayingAudio.value ? Icons.stop : Icons.play_arrow,
                      color: const Color(0xFF4CAF50),
                      label: c.qsIsPlayingAudio.value ? 'stop'.tr : 'play'.tr,
                      onTap: c.toggleQsPlayback,
                    ),
                    const SizedBox(width: 10),
                    _AudioBtn(
                      icon: Icons.delete_outline,
                      color: Colors.red,
                      label: 'delete'.tr,
                      onTap: c.removeQsAudio,
                    ),
                  ],
                ]),
                if (c.qsIsRecording.value) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('recording_indicator'.tr,
                        style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ]),
                ],
                if (hasAudio && !c.qsIsRecording.value) ...[
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
                          c.qsAudioFileName.value.isEmpty ? 'audio_ready'.tr : c.qsAudioFileName.value,
                          style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text('record_voice_hint'.tr,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            );
          }),
          ],
          const SizedBox(height: 24),
          Obx(() => _SaveBtn(
            loading: c.qsFormLoading.value,
            onTap: () => c.saveQuickSpeak(_wordCtrl.text),
          )),
        ],
      ),
    );
  }
}


class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40, height: 4,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.black87 : Colors.transparent, width: 2.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
              : [],
        ),
        child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  const _ImagePreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file, width: 60, height: 60, fit: BoxFit.cover),
      ),
      const SizedBox(width: 12),
      TextButton.icon(
        onPressed: onRemove,
        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
        label: Text('remove'.tr, style: const TextStyle(color: Colors.red)),
      ),
    ]);
  }
}

class _PickImageBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _PickImageBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.image_outlined),
      label: Text('choose_image'.tr),
      style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}

class _SaveBtn extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _SaveBtn({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC857),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : Text('save'.tr,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16)),
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

Color _hexToColor(String hex) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return const Color(0xFFB5CFD1);
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFFC857), width: 1.5),
    ),
  );
}
