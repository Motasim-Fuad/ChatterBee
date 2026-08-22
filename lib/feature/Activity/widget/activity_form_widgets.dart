import 'dart:io';
import 'package:chatter_bee/config/app_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityForm extends StatelessWidget {
  final TextEditingController nameController;
  final RxString selectedTime;
  final RxString selectedImagePath;
  final RxString existingImageUrl;
  final RxString selectedStatus;
  final RxBool isSaving;
  final VoidCallback onSelectTime;
  final VoidCallback onPickImage;
  final void Function(String) onStatusChanged;
  final VoidCallback onSave;
  final String saveButtonLabel;
  final List<Map<String, String>> statusOptions;

  const ActivityForm({
    super.key,
    required this.nameController,
    required this.selectedTime,
    required this.selectedImagePath,
    required this.existingImageUrl,
    required this.selectedStatus,
    required this.isSaving,
    required this.onSelectTime,
    required this.onPickImage,
    required this.onStatusChanged,
    required this.onSave,
    required this.saveButtonLabel,
    required this.statusOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _FieldLabel(label: 'activity_name'.tr),
                const SizedBox(height: 8),
                _inputCard(
                  child: TextField(
                    controller: nameController,
                    style: GoogleFonts.nunito(
                        fontSize: 16, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'activity_name_hint'.tr,
                      hintStyle: GoogleFonts.nunito(
                          fontSize: 16, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.event_note_outlined,
                          color: Colors.black54, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _FieldLabel(label: 'time'.tr),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onSelectTime,
                  child: _inputCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.black54, size: 20),
                          const SizedBox(width: 12),
                          Obx(() => Text(
                            selectedTime.value,
                            style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: selectedTime.value.isNotEmpty
                                    ? Colors.black87
                                    : Colors.grey.shade400),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _FieldLabel(label: 'activity_status'.tr),
                const SizedBox(height: 8),
                Obx(() => Row(
                  children: statusOptions.map((opt) {
                    final isSelected =
                        selectedStatus.value == opt['value'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onStatusChanged(opt['value']!),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFDD268)
                                .withOpacity(0.3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFDD268)
                                  : Colors.grey.shade300,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            opt['labelKey']!.tr,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
                const SizedBox(height: 24),

                _FieldLabel(label: 'upload_image_icon'.tr),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onPickImage,
                  child: Obx(() {
                    final hasNewImage =
                        selectedImagePath.value.isNotEmpty;
                    final hasExisting =
                        existingImageUrl.value.isNotEmpty;
                    return _inputCard(
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 36),
                          child: hasNewImage
                              ? _imagePreview(
                            FileImage(
                                File(selectedImagePath.value)),
                            'tap_to_change'.tr,
                          )
                              : hasExisting
                              ? _imagePreview(
                            NetworkImage(
                                "${AppUrl.baseUrl}${existingImageUrl.value}"),
                            'tap_to_change'.tr,
                          )
                              : _uploadPlaceholder(),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() => SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSaving.value ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDD268),
                disabledBackgroundColor:
                const Color(0xFFFDD268).withOpacity(0.6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isSaving.value
                  ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.black54),
                ),
              )
                  : Text(
                saveButtonLabel,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _imagePreview(ImageProvider provider, String caption) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image(
              image: provider,
              height: 100,
              width: 100,
              fit: BoxFit.cover),
        ),
        const SizedBox(height: 10),
        Text(caption,
            style: GoogleFonts.nunito(
                fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _uploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.file_upload_outlined,
            size: 48, color: Colors.grey.shade500),
        const SizedBox(height: 12),
        Text('upload_image'.tr,
            style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
        const SizedBox(height: 4),
        Text('upload_image_desc'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.5)),
      ],
    );
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E9)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87));
  }
}
