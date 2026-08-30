import 'dart:io';
import 'package:chatter_bee/Repository/caregiver_repository/caregiver_customization_repository.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CaregiverSubCategoryController extends GetxController {
  final CaregiverCustomizationRepository _repo =
  CaregiverCustomizationRepository();
  final ImagePicker _picker = ImagePicker();

  late final CategoryModel parentCategory;

  final RxList<SubCategoryModel> subCategories = <SubCategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxSet<int> selectedIds = <int>{}.obs;

  final RxString formColorHex = '#B5CFD1'.obs;
  final Rx<File?> formImageFile = Rx<File?>(null);
  final RxBool formLoading = false.obs;

  SubCategoryModel? _editingSub;

  String get subInitialName => _editingSub?.name ?? '';

  @override
  void onInit() {
    super.onInit();
    parentCategory = Get.arguments as CategoryModel;
    subCategories.value = parentCategory.subCategories;
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
      final updated = response.data!.categories
          .firstWhereOrNull((c) => c.id == parentCategory.id);
      if (updated != null) subCategories.value = updated.subCategories;

      if (Get.isRegistered<CaregiverHomeController>()) {
        Get.find<CaregiverHomeController>().loadContent();
      }
    }
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

  void onSubCategoryTap(SubCategoryModel sub) {
    if (isEditMode.value) {
      toggleSelection(sub.id);
    } else {
      Get.toNamed('/item-screen', arguments: sub);
    }
  }

  void showAddSheet() {
    _editingSub = null;
    formColorHex.value = '#B5CFD1';
    formImageFile.value = null;
    _openSheet('add_sub_category'.tr);
  }

  void showEditSheet(SubCategoryModel sub) {
    _editingSub = sub;
    formColorHex.value = sub.color.isNotEmpty ? sub.color : '#B5CFD1';
    formImageFile.value = null;
    _openSheet('edit'.tr);
  }

  void _openSheet(String title) {
    Get.bottomSheet(
      _SubCategorySheet(controller: this, title: title),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
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

  Future<void> save(String name) async {
    if (name.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_name'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    formLoading.value = true;
    final lang = _currentLang;
    debugPrint('SubCategory save lang: $lang');

    if (_editingSub != null) {
      final res = await _repo.updateSubCategory(
        subCategoryId: _editingSub!.id,
        name: name.trim(),
        color: formColorHex.value,
        imageFile: formImageFile.value,
        lang: lang,
      );
      formLoading.value = false;
      if (res.isSuccess) {
        Get.back();
        await refresh();
        Get.snackbar('updated'.tr, 'sub_category_updated'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      final communicatorId =
          CommunicatorSessionService.to.communicatorId.value;
      final res = await _repo.createSubCategory(
        name: name.trim(),
        color: formColorHex.value,
        order: subCategories.length,
        communicatorId: communicatorId,
        mainCategoryId: parentCategory.id,
        imageFile: formImageFile.value,
        lang: lang,
      );
      formLoading.value = false;
      if (res.isSuccess) {
        Get.back();
        await refresh();
        Get.snackbar('created'.tr, 'sub_category_created'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}


class _SubCategorySheet extends StatefulWidget {
  final CaregiverSubCategoryController controller;
  final String title;
  const _SubCategorySheet({required this.controller, required this.title});

  @override
  State<_SubCategorySheet> createState() => _SubCategorySheetState();
}

class _SubCategorySheetState extends State<_SubCategorySheet> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.controller.subInitialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
              controller: _nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'sub_category_name_label'.tr,
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
              children: kColorOptions.map((opt) {
                Color col;
                try {
                  col = Color(int.parse('FF${opt['hex']!.replaceAll('#', '')}', radix: 16));
                } catch (_) {
                  col = const Color(0xFFB5CFD1);
                }
                final selected = c.formColorHex.value == opt['hex'];
                return GestureDetector(
                  onTap: () => c.formColorHex.value = opt['hex']!,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: col, shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.black87 : Colors.transparent, width: 2.5,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: col.withOpacity(0.5), blurRadius: 6)]
                          : [],
                    ),
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
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
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: c.formLoading.value ? null : () => c.save(_nameCtrl.text),
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
