import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/authentication/controller/verification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerificationController>(
      builder: (controller) {
        return AbsorbPointer(
          absorbing: controller.isNavigating,
          child: Scaffold(
            backgroundColor: AppColors.bgColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      Center(
                        child: Image.asset(ImagesLink.logo, height: 95,),
                      ),
                      const SizedBox(height: 60),

                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Verification Code',
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Enter the verification code that we\nhave sent to your email',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Color(0xFF636F85),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),

                      GetBuilder<VerificationController>(
                        builder: (controller) => Column(
                          children: [
                            IgnorePointer(
                              ignoring: controller.isLoading || controller.isNavigating,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  4,
                                      (index) => Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: controller.otpCode.length > index
                                            ? AppColors.primaryColor
                                            : const Color(0xFFE5E7EB),
                                        width: controller.otpCode.length > index ? 1 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: controller.otpControllers[index],
                                        focusNode: controller.focusNodes[index],
                                        enabled: !controller.isNavigating,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        maxLength: 1,
                                        style: GoogleFonts.nunito(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          counterText: '',
                                        ),
                                        onChanged: (value) {
                                          if (!controller.isNavigating) {
                                            controller.onOtpChanged(value, index);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive the code? ",
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: controller.canResend && !controller.isNavigating
                                      ? controller.resendCode
                                      : null,
                                  child: Text(
                                    'Resend code',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: controller.canResend && !controller.isNavigating
                                          ? Colors.red
                                          : Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            if (!controller.canResend)
                              Text(
                                'Resend code at ${controller.formatTime(controller.resendTimer)}',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                      GetBuilder<VerificationController>(
                        builder: (controller) => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: controller.isLoading ||
                                controller.isNavigating ||
                                controller.otpCode.length != 4
                                ? null
                                : controller.verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: const Color(0xFF2C3E50),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: controller.isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
                              ),
                            )
                                : Text(
                              'Continue',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
