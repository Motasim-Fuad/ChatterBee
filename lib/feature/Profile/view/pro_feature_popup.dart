import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProFeaturePopup extends StatelessWidget {
  const ProFeaturePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SubscriptionController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF3D6), Colors.white],
                  stops: [0.0, 0.35],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header: bee + title
                    Row(
                      children: [
                        Image.asset(ImagesLink.logo, height: 70),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This is a\nChatterBee Pro Feature!',
                            style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1B2A41),
                                height: 1.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.nunito(
                            fontSize: 13.5, color: Colors.black87, height: 1.5),
                        children: const [
                          TextSpan(
                              text:
                              'Unlock powerful tools that help you stay connected and '),
                          TextSpan(
                              text: 'support every moment that matters.',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    // Feature list
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _feature(
                            icon: Icons.notifications_active_rounded,
                            bg: const Color(0xFFDCEBFB),
                            color: const Color(0xFF4A90D9),
                            title: 'Real-Time Notifications',
                            desc:
                            'Get notified right away when a message is sent using the sentence builder, so you never miss what\'s important.',
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          _feature(
                            icon: Icons.people_alt_rounded,
                            bg: const Color(0xFFFFE8CC),
                            color: const Color(0xFFF08C00),
                            title: 'Linked Caregiver Accounts',
                            desc:
                            'Connect caregivers to stay in sync and support communication together.',
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          _feature(
                            icon: Icons.favorite_rounded,
                            bg: const Color(0xFFFADADD),
                            color: const Color(0xFFE05A6D),
                            title: 'BuddyBee Encouragement',
                            desc:
                            'Friendly, positive encouragement that keeps motivation high every day.',
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          _feature(
                            icon: Icons.checklist_rounded,
                            bg: const Color(0xFFE6DDF7),
                            color: const Color(0xFF7E57C2),
                            title: 'Visual Routines',
                            desc:
                            'Create step-by-step routines that build independence and help each day flow more smoothly.',
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          _feature(
                            icon: Icons.tune_rounded,
                            bg: const Color(0xFFD8F0E3),
                            color: const Color(0xFF43A776),
                            title: 'Advanced Customization',
                            desc:
                            'Personalize voices, buttons, and settings to match their preferences and communication style.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Unlock button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back(); // close popup
                          c.onContinuePressed(); // purchase selected plan
                        },
                        icon: const Icon(Icons.lock_outline, size: 20),
                        label: Text('Unlock with ChatterBee Pro',
                            style: GoogleFonts.nunito(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Maybe later
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Maybe later',
                            style: GoogleFonts.nunito(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Restore
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text('Already a Pro user? ',
                            style: GoogleFonts.nunito(
                                fontSize: 12, color: Colors.grey[600])),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                            c.restorePurchases();
                          },
                          child: Text('Restore Purchase',
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: const Color(0xFF4A5DD9),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Close (X) button
          Positioned(
            top: -8,
            right: -4,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature({
    required IconData icon,
    required Color bg,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.nunito(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B2A41))),
                const SizedBox(height: 3),
                Text(desc,
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: Colors.black54, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}