import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

enum ToastType { info, success, error }

/// Lightweight toast (no extra package needed). Replaces Get.snackbar.
///
///   AppToast.success('account_deleted'.tr);
///   AppToast.error(response.message);
///   AppToast.show('Something');
class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;
  static ValueNotifier<bool>? _visible;

  static void show(
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final text = message.trim();
    if (text.isEmpty) return;

    final overlay = Get.key.currentState?.overlay ??
        (Get.overlayContext != null ? Overlay.of(Get.overlayContext!) : null);
    if (overlay == null) return;

    _dismissNow();

    final visible = ValueNotifier<bool>(false);
    _visible = visible;

    final entry = OverlayEntry(
      builder: (context) {
        final media = MediaQuery.of(context);
        final bottom = media.viewInsets.bottom + media.padding.bottom + 32;
        return Positioned(
          left: 24,
          right: 24,
          bottom: bottom,
          child: IgnorePointer(
            child: ValueListenableBuilder<bool>(
              valueListenable: visible,
              builder: (_, show, __) => AnimatedOpacity(
                opacity: show ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedSlide(
                  offset: show ? Offset.zero : const Offset(0, 0.3),
                  duration: const Duration(milliseconds: 200),
                  child: Center(child: _ToastBody(message: text, type: type)),
                ),
              ),
            ),
          ),
        );
      },
    );
    _entry = entry;
    overlay.insert(entry);

    // fade in on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (identical(_visible, visible)) visible.value = true;
    });

    _timer = Timer(duration, () {
      if (!identical(_visible, visible)) return;
      visible.value = false;
      _timer = Timer(const Duration(milliseconds: 220), _dismissNow);
    });
  }

  static void success(String message) => show(message, type: ToastType.success);
  static void error(String message) => show(message, type: ToastType.error);
  static void info(String message) => show(message);

  static void _dismissNow() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
    _visible = null;
  }
}

class _ToastBody extends StatelessWidget {
  final String message;
  final ToastType type;
  const _ToastBody({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    IconData? icon;
    switch (type) {
      case ToastType.success:
        bg = const Color(0xFF2E7D32);
        icon = Icons.check_circle_outline;
        break;
      case ToastType.error:
        bg = const Color(0xFFC62828);
        icon = Icons.error_outline;
        break;
      case ToastType.info:
        bg = const Color(0xFF2D2D2D);
        icon = null;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                message,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
