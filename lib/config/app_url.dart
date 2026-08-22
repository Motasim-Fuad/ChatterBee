class AppUrl {
  static const String baseUrl = 'https://api.chatterbeeapp.com';

  static const String login = '$baseUrl/api/auth/login/';
  static const String profile = '$baseUrl/api/auth/profile/';
  static const String tokenRefresh = '$baseUrl/api/auth/token/refresh/';
  static const String logout = '$baseUrl/api/auth/logout/';
  static const String changePassword = '$baseUrl/api/auth/password/change/';
  static const String deleteAccount = '$baseUrl/api/auth/account/delete/';
  static const String verifyEmail = '$baseUrl/api/auth/verify-email/';
  static const String resendOtp = '$baseUrl/api/auth/resend-otp/';
  static const String forgotPassword = '$baseUrl/api/auth/password/reset-request/';
  static const String verifyResetOtp = '$baseUrl/api/auth/password/reset-verify-otp/';
  static const String resetPassword = '$baseUrl/api/auth/password/reset-confirm/';
  static const String communicatorRegister = '$baseUrl/api/auth/communicator/register/';
  static const String caregiverRegister = '$baseUrl/api/auth/caregiver/register/';
  static const String privacyPolicy = '$baseUrl/api/settings/privacy/';
  static const String support = '$baseUrl/api/settings/support/';

  static const String sendInvitation = '$baseUrl/api/auth/invitations/send/';
  static const String acceptInvitation = '$baseUrl/api/auth/invitations/accept/';
  static const String rejectInvitation = '$baseUrl/api/auth/invitations/reject/';
  static const String listInvitations = '$baseUrl/api/auth/invitations/';
  static const String listConnections = '$baseUrl/api/auth/connections/';
  static const String disconnectProfile = '$baseUrl/api/auth/connections/disconnect/';
  static const String connectionStats = '$baseUrl/api/auth/connections/stats/';
  static const String switchConnection = '$baseUrl/api/auth/connections/switch/';

  static const String copyDefaultContent = '$baseUrl/api/caregiver/customization/copy-defaults/';
  static const String resetCustomization = '$baseUrl/api/caregiver/customization/reset/';

  // Normal-mode caregiver content URL
  static String getCaregiverContent(int communicatorId, {String lang = 'en'}) =>
      '$baseUrl/api/caregiver/customization/user/$communicatorId/?lang=$lang';

  // Buddy-mode caregiver content URL
  static String getCaregiverBuddyModeContent(int communicatorId, {String lang = 'en'}) =>
      '$baseUrl/api/caregiver/customization/buddy-mode/user/$communicatorId/?lang=$lang';

  // Update category URL
  static String updateUserCategory(int catagoryid) =>
      '$baseUrl/api/caregiver/customization/category/$catagoryid/';

  // Update sub-category URL
  static String updateUserSubCategory(int subcatagoryid) =>
      '$baseUrl/api/caregiver/customization/category/$subcatagoryid/';

  // Update item URL
  static String updateUserItem(int itemId) =>
      '$baseUrl/api/caregiver/customization/item/$itemId/';

  // Update quick speak URL
  static String updateUserQuickSpeak(int id) =>
      '$baseUrl/api/caregiver/customization/quickspeak/$id/';

  static const String createCategory = '$baseUrl/api/caregiver/content/create-category/';
  static const String createSubCategory = '$baseUrl/api/caregiver/content/create-subcategory/';
  static const String createItem = '$baseUrl/api/caregiver/content/create-item/';
  static const String createQuickSpeak = '$baseUrl/api/caregiver/content/create-quickspeak/';

  // Normal mode
  static String getCommunicatorContent({String lang = 'en'}) =>
      '$baseUrl/api/communicator/content/?lang=$lang';

  // Buddy mode
  static String getCommunicatorBuddyModeContent({String lang = 'en'}) =>
      '$baseUrl/api/communicator/content/buddy-mode/?lang=$lang';

  static const String activities       = '/api/activity/activities/';
  static const String activitiesCreate = '/api/activity/activities/create/';
  static String activityDelete(int id) => '/api/activity/activities/$id/delete/';
  static String activityUpdate(int id) => '/api/activity/activities/$id/update/';

  // Media Url
  static String? mediaUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  static const String pressContent = '/api/communicator/content/pressed/';
}
