import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LastEmailSuggestion extends StatelessWidget {
  final String email;
  final bool visible;
  final VoidCallback onSelect;

  const LastEmailSuggestion({
    super.key,
    required this.email,
    required this.visible,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible || email.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.mail_outline, size: 20, color: Color(0xFF636F85)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
