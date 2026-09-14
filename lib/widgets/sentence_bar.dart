import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/services/sentence_bar_service.dart';
import 'package:chatter_bee/services/speech_mode_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SentenceBar extends StatelessWidget {
  final String hint;
  final String? lang;
  final bool isCooldown;
  final int cooldownCount;
  final VoidCallback? onSpeak;
  final VoidCallback? onClear;

  const SentenceBar({
    super.key,
    this.hint = '',
    this.lang,
    this.isCooldown = false,
    this.cooldownCount = 0,
    this.onSpeak,
    this.onClear,
  });

  Color _parseColor(String hex, Color fallback) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!SpeechModeService.to.showSentenceBar) {
        return const SizedBox.shrink();
      }
      final bar = SentenceBarService.to;
      final chips = bar.tokens.toList();
      return Column(
        children: [
          SizedBox(
            height: 0,
            width: 0,
            child: TextField(
              controller: bar.typeController,
              focusNode: bar.typeFocusNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => bar.submitTyped(lang: lang),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border.fromBorderSide(
                        BorderSide(color: Color(0xFFE3E3E9))),
                  ),
                  child: chips.isEmpty
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            hint.isEmpty ? 'select_quick_speak_hint'.tr : hint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                fontSize: 15, color: Colors.grey[400]),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: chips.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final chip = chips[i];
                            final color =
                                _parseColor(chip.colorHex, const Color(0xFFFFD700));
                            final imageUrl = AppUrl.mediaUrl(chip.imageUrl) ??
                                (chip.imageUrl.startsWith('http')
                                    ? chip.imageUrl
                                    : '');
                            return Container(
                              width: 58,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: color),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorWidget: (_, __, ___) => Icon(
                                                  Icons.image_outlined,
                                                  color: color,
                                                  size: 18),
                                            )
                                          : Icon(Icons.short_text,
                                              color: color, size: 18),
                                    ),
                                  ),
                                  Text(
                                    chip.text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.nunito(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 10),
              _BarBtn(
                color: const Color(0xFF7BC5D3),
                onTap: isCooldown
                    ? null
                    : () {
                        if (onSpeak != null) {
                          onSpeak!();
                        } else {
                          bar.speakAll(lang: lang);
                        }
                      },
                child: isCooldown
                    ? Text('$cooldownCount',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700))
                    : SvgPicture.asset(ImagesLink.speakIcon,
                        width: 22, height: 22),
              ),
              const SizedBox(width: 10),
              _BarBtn(
                color: const Color(0xFFE57373),
                onTap: () {
                  if (onClear != null) {
                    onClear!();
                  } else {
                    bar.clear();
                  }
                },
                child: SvgPicture.asset(ImagesLink.cancelIcon,
                    width: 22, height: 22),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _BarBtn extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;
  final Widget child;
  const _BarBtn({required this.color, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onTap == null ? color.withValues(alpha: 0.4) : color,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
