import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_controller.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const CustomSwitch({Key? key, required this.value, required this.onChanged})
      : super(key: key);
  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.value ? 1.0 : 0.0,
    );
    _animation = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant CustomSwitch old) {
    super.didUpdateWidget(old);
    widget.value ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => Container(
          width: 40,
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
          decoration: BoxDecoration(
            color: widget.value ? AppColors.primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(children: [
            Align(
              alignment: Alignment.lerp(
                  Alignment.centerLeft, Alignment.centerRight, _animation.value)!,
              child: Container(
                width: 20, height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(1, 2))
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationControllerdamo());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          const SizedBox(height: 45),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Obx(() => Row(children: [
              Expanded(
                child: _buildTab('Notification',
                    controller.selectedTab.value == 0,
                        () => controller.changeTab(0)),
              ),
              Expanded(
                child: _buildTab('Alert Settings',
                    controller.selectedTab.value == 1,
                        () => controller.changeTab(1)),
              ),
            ])),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return controller.selectedTab.value == 0
                  ? _buildNotificationContent(controller)
                  : _buildAlertSettingsContent(controller);
            }),
          ),
        ],
      ),
    );
  }

  // Tab widget
  Widget _buildTab(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(text,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isActive ? AppColors.primaryColor : Colors.grey[600],
            )),
        const SizedBox(height: 12),
        Container(
          height: 2,
          width: double.infinity,
          color: isActive ? AppColors.primaryColor : Colors.grey[300],
        ),
      ]),
    );
  }

  // Notification list
  Widget _buildNotificationContent(NotificationControllerdamo controller) {
    if (controller.notifications.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (controller.todayNotifications.isNotEmpty) ...[
            _sectionHeader('Today'),
            ...controller.todayNotifications
                .map((n) => _notificationItem(n, controller)),
            const SizedBox(height: 20),
          ],
          if (controller.yesterdayNotifications.isNotEmpty) ...[
            _sectionHeader('Yesterday'),
            ...controller.yesterdayNotifications
                .map((n) => _notificationItem(n, controller)),
            const SizedBox(height: 20),
          ],
          if (controller.olderNotifications.isNotEmpty) ...[
            _sectionHeader('Older'),
            ...controller.olderNotifications
                .map((n) => _notificationItem(n, controller)),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Text(label,
        style: GoogleFonts.nunito(
            fontSize: 18, fontWeight: FontWeight.w600)),
  );

  Widget _notificationItem(
      NotificationModel n, NotificationControllerdamo controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('notif_${n.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.deleteNotification(n),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.red),
        ),
        child: InkWell(
          onTap: () => controller.onNotificationTap(n),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: n.isRead ? Colors.white : const Color(0xFFFFFBEE),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                    color: n.iconBg, shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(n.imagePath,
                      width: 28, height: 28, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.notifications,
                          color: n.iconColor, size: 22)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: n.isRead
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: Colors.black87,
                          )),
                      const SizedBox(height: 4),
                      Text(n.timeString,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[600])),
                    ]),
              ),
              if (!n.isRead)
                Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFDD268),
                      shape: BoxShape.circle),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  // Alert Settings
  Widget _buildAlertSettingsContent(NotificationControllerdamo controller) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Obx(() {
          final isPro = ProStatusController.to.isProUser.value;
          if (isPro) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(children: [
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Upgrade to Pro to customize alert settings.',
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: Colors.amber.shade900),
                ),
              ),
            ]),
          );
        }),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Obx(() => _settingItem(
              title: 'Button Alerts',
              subtitle: 'Receive alerts when buttons are tapped',
              value: controller.buttonAlerts.value,
              onChanged: controller.toggleButtonAlerts,
            )),
            _divider(),
            Obx(() => _settingItem(
              title: 'Sentence Builder Alerts',
              subtitle: 'Receive alerts when sentences are built',
              value: controller.sentenceBuilderAlerts.value,
              onChanged: controller.toggleSentenceBuilderAlerts,
            )),
            _divider(),
            Obx(() => _settingItem(
              title: 'My Schedule Alerts',
              subtitle: 'Receive alerts for schedule activities',
              value: controller.myScheduleAlerts.value,
              onChanged: controller.toggleMyScheduleAlerts,
            )),
          ]),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, color: Colors.grey[100]),
  );

  Widget _settingItem({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isPro = ProStatusController.to.isProUser.value;
    return Row(children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(title,
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              if (!isPro) ...[
                const SizedBox(width: 6),
                const Icon(Icons.lock_outline,
                    size: 14, color: Colors.amber),
              ],
            ]),
            Text(subtitle,
                style: GoogleFonts.nunito(
                    fontSize: 12, color: Colors.grey[600])),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Opacity(
          opacity: isPro ? 1.0 : 0.4,
          child: CustomSwitch(value: value, onChanged: onChanged),
        ),
      ),
    ]);
  }
}
