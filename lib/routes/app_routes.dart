import 'package:chatter_bee/feature/Activity/buinding/activities_binding.dart';
import 'package:chatter_bee/feature/Activity/buinding/edit_activity_buinding.dart';

import 'package:chatter_bee/feature/Activity/view/activities_screen.dart';
import 'package:chatter_bee/feature/Activity/buinding/add_activity_binding.dart';
import 'package:chatter_bee/feature/Activity/view/add_activity_screen.dart';
import 'package:chatter_bee/feature/Activity/view/edit_activity.dart';
import 'package:chatter_bee/feature/Profile/binding/Profile_binding.dart';
import 'package:chatter_bee/feature/Profile/binding/change_password_binding.dart';
import 'package:chatter_bee/feature/Profile/binding/privacy_policy_binding.dart';
import 'package:chatter_bee/feature/Profile/binding/subscription_binding.dart';
import 'package:chatter_bee/feature/Profile/binding/support_bonding.dart';
import 'package:chatter_bee/feature/Profile/view/change_password_screen.dart';
import 'package:chatter_bee/feature/Profile/view/privacy_policy_screen.dart';
import 'package:chatter_bee/feature/Profile/view/profile_screen.dart';
import 'package:chatter_bee/feature/Profile/view/subscription_screen.dart';
import 'package:chatter_bee/feature/Profile/view/support_screen.dart';
import 'package:chatter_bee/feature/authentication/binding/create_new_password_binding.dart';
import 'package:chatter_bee/feature/authentication/binding/forgot_password_binding.dart';
import 'package:chatter_bee/feature/authentication/binding/forgot_verification_binding.dart';
import 'package:chatter_bee/feature/authentication/binding/loginBinding.dart';
import 'package:chatter_bee/feature/authentication/binding/signup_binding.dart';
import 'package:chatter_bee/feature/authentication/binding/verification_binding.dart';
import 'package:chatter_bee/feature/authentication/screen/create_new_password_screen.dart';
import 'package:chatter_bee/feature/authentication/screen/forgot_password_screen.dart';
import 'package:chatter_bee/feature/authentication/screen/forgot_verification_screen.dart';
import 'package:chatter_bee/feature/authentication/screen/loginScreen.dart';
import 'package:chatter_bee/feature/authentication/screen/signup_screen.dart';
import 'package:chatter_bee/feature/authentication/screen/verification_screen.dart';
import 'package:chatter_bee/feature/communicator/binding/action_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/core_words_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/emotions_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/food_drink_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/greetings_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/health_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/people_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/places_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/question_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/text_to_speak_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/things_binding.dart';
import 'package:chatter_bee/feature/communicator/binding/visual_schedules_binding.dart';
import 'package:chatter_bee/feature/communicator/screen/action_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/core_words_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/emotions_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/food_drink_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/greetings_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/health_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/people_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/places_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/question_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/text_to_speak.dart';
import 'package:chatter_bee/feature/communicator/screen/things_screen.dart';
import 'package:chatter_bee/feature/communicator/screen/visual_schedules_screen.dart';
import 'package:chatter_bee/feature/communicator/sub_category/breakfast/breakfast_binding.dart';
import 'package:chatter_bee/feature/communicator/sub_category/breakfast/breakfast_screen.dart';
import 'package:chatter_bee/feature/communicator/sub_category/drinks/drinks_binding.dart';
import 'package:chatter_bee/feature/communicator/sub_category/drinks/drinks_screen.dart';
import 'package:chatter_bee/feature/communicator/sub_category/fruits/fruits_binding.dart';
import 'package:chatter_bee/feature/communicator/sub_category/fruits/fruits_screen.dart';
import 'package:chatter_bee/feature/communicator/sub_category/meals/meals_binding.dart';
import 'package:chatter_bee/feature/communicator/sub_category/meals/meals_screen.dart';
import 'package:chatter_bee/feature/communicator/sub_category/snacks/snacks_binding.dart';
import 'package:chatter_bee/feature/communicator/sub_category/snacks/snacks_screen.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/buinding/caregiver_item_buinding.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_all_categories_screen.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_all_quick_speaks_screen.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_home_screen.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_item_screen.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_sub_catagory_screen.dart';
import 'package:chatter_bee/feature/home_screen/communicator/buinding/communicator_home_binding.dart';
import 'package:chatter_bee/feature/home_screen/communicator/buinding/communicator_item_binding.dart';
import 'package:chatter_bee/feature/home_screen/communicator/buinding/communicator_sub_category_binding.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/view/communicator_all_categories_screen.dart';
import 'package:chatter_bee/feature/home_screen/communicator/view/communicator_all_quick_speaks_screen.dart';
import 'package:chatter_bee/feature/home_screen/communicator/view/communicator_home_screen.dart';
import 'package:chatter_bee/feature/home_screen/communicator/view/communicator_item_screen.dart';
import 'package:chatter_bee/feature/home_screen/communicator/view/communicator_sub_category_screen.dart';
import 'package:chatter_bee/feature/invitations/buindings/invitations_buindings.dart';
import 'package:chatter_bee/feature/invitations/view/caregiver_connect_sereen.dart';
import 'package:chatter_bee/feature/invitations/view/communicator_invitations_screen.dart';
import 'package:chatter_bee/feature/navigation_bar/navigation_bar.dart';
import 'package:chatter_bee/feature/navigation_bar/navigation_binding.dart';
import 'package:chatter_bee/feature/role_selection/binding/caregiver_profile_binding.dart';
import 'package:chatter_bee/feature/role_selection/binding/communicator_profile_binding.dart';
import 'package:chatter_bee/feature/role_selection/binding/role_selection_binding.dart';
import 'package:chatter_bee/feature/role_selection/view/caregiver_profile_screen.dart';
import 'package:chatter_bee/feature/role_selection/view/communicator_profile_screen.dart';
import 'package:chatter_bee/feature/role_selection/view/role_selection_screen.dart';
import 'package:chatter_bee/feature/splash_screen/splash_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../feature/home_screen/caregiver/buinding/caregiver_sub_catagory_buinding.dart'
    show CaregiverSubCatagoryBuinding;

final List<GetPage> routes = [
  GetPage(name: AppRoutes.SPLASHSCREEN, page: () => const SplashScreen()),
  GetPage(
    name: AppRoutes.SIGNINSCREEN,
    page: () => LoginScreen(),
    binding: LoginBinding(),
  ),
  GetPage(
    name: AppRoutes.SIGNUPSCREEN,
    page: () => SignUpScreen(),
    binding: SignUpBinding(),
  ),
  GetPage(
    name: AppRoutes.VERIFICATIONSCREEN,
    page: () => VerificationScreen(),
    binding: VerificationBinding(),
  ),
  GetPage(
    name: AppRoutes.FORGOTSCREEN,
    page: () => ForgotPasswordScreen(),
    binding: ForgotPasswordBinding(),
  ),
  GetPage(
    name: AppRoutes.FORGOTOTPSCREEN,
    page: () => ForgotVerificationScreen(),
    binding: ForgotVerificationBinding(),
  ),
  GetPage(
    name: AppRoutes.CREATENEWPASSSCREEN,
    page: () => CreateNewPasswordScreen(),
    binding: CreateNewPasswordBinding(),
  ),
  GetPage(
    name: AppRoutes.ROLESELECTION,
    page: () => RoleSelectionScreen(),
    binding: RoleSelectionBinding(),
  ),
  GetPage(
    name: AppRoutes.CAREGIVERPROFILE,
    page: () => CaregiverProfileScreen(),
    binding: CaregiverProfileBinding(),
  ),
  GetPage(
    name: AppRoutes.COMMUNICATORPROFILE,
    page: () => CommunicatorProfileScreen(),
    binding: CommunicatorProfileBinding(),
  ),
  GetPage(
    name: AppRoutes.NAVIGATIONBAR,
    page: () => NavigationScreen(),
    binding: NavigationBinding(),
  ),
  GetPage(
    name: AppRoutes.PROFILE,
    page: () => ProfileScreen(),
    binding: ProfileBinding(),
  ),
  GetPage(
    name: AppRoutes.COMMUNICATORHOMESCREEN,
    page: () => CommunicatorHomeScreen(),
    binding: CommunicatorHomeBinding(),
  ),
  GetPage(
    name: AppRoutes.SUBSCRIPTION,
    page: () => SubscriptionScreen(),
    binding: SubscriptionBinding(),
  ),

  GetPage(
    name: AppRoutes.CHANGEPASSWORD,
    page: () => ChangePasswordScreen(),
    binding: ChangePasswordBinding(),
  ),
  GetPage(
    name: AppRoutes.PRIVACYPOLICY,
    page: () => PrivacyPolicyScreen(),
    binding: PrivacyPolicyBinding(),
  ),
  GetPage(
    name: AppRoutes.SUPPORT,
    page: () => SupportScreen(),
    binding: SupportBonding(),
  ),
  GetPage(
    name: AppRoutes.TEXT_TO_SPEAK,
    page: () => TextToSpeakScreen(),
    binding: TextToSpeakBinding(),
  ),
  GetPage(
    name: AppRoutes.EMOTIONS,
    page: () => EmotionsScreen(),
    binding: EmotionsBinding(),
  ),
  GetPage(
    name: AppRoutes.ACTIVITIES,
    page: () => ActivitiesScreen(),
    binding: ActivitiesBinding(),
  ),
  GetPage(
    name: AppRoutes.PEOPLE,
    page: () => PeopleScreen(),
    binding: PeopleBinding(),
  ),
  GetPage(
    name: AppRoutes.VISUAL_SCHEDULES,
    page: () => VisualSchedulesScreen(),
    binding: VisualSchedulesBinding(),
  ),
  GetPage(
    name: AppRoutes.ADD_ACTIVITY,
    page: () => const AddActivityScreen(),
    binding: AddActivityBinding(),
  ),
  GetPage(
    name: AppRoutes.PLACES,
    page: () => const PlacesScreen(),
    binding: PlacesBinding(),
  ),
  GetPage(
    name: AppRoutes.FOOD_DRINK,
    page: () => const FoodDrinkScreen(),
    binding: FoodDrinkBinding(),
  ),

  GetPage(
    name: AppRoutes.BREAKFAST,
    page: () => const BreakfastScreen(),
    binding: BreakfastBinding(),
  ),
  GetPage(
    name: AppRoutes.MEALS,
    page: () => const MealsScreen(),
    binding: MealsBinding(),
  ),
  GetPage(
    name: AppRoutes.DRINKS,
    page: () => const DrinksScreen(),
    binding: DrinksBinding(),
  ),
  GetPage(
    name: AppRoutes.FRUITS,
    page: () => const FruitsScreen(),
    binding: FruitsBinding(),
  ),
  GetPage(
    name: AppRoutes.SNACKS,
    page: () => const SnacksScreen(),
    binding: SnacksBinding(),
  ),

  GetPage(
    name: AppRoutes.HEALTH,
    page: () => const HealthScreen(),
    binding: HealthBinding(),
  ),
  GetPage(
    name: AppRoutes.GREETINGS,
    page: () => const GreetingsScreen(),
    binding: GreetingsBinding(),
  ),
  GetPage(
    name: AppRoutes.QUESTION,
    page: () => const QuestionScreen(),
    binding: QuestionBinding(),
  ),
  GetPage(
    name: AppRoutes.ACTION,
    page: () => const ActionScreen(),
    binding: ActionBinding(),
  ),
  GetPage(
    name: AppRoutes.THINGS,
    page: () => const ThingsScreen(),
    binding: ThingsBinding(),
  ),
  GetPage(
    name: AppRoutes.CORE_WORDS,
    page: () => const CoreWordsScreen(),
    binding: CoreWordsBinding(),
  ),
  GetPage(
    name: AppRoutes.CAREGIVER_CONNECTIONS,
    page: () => const CaregiverConnectionsScreen(),
    binding: CaregiverInvitationBinding(),
  ),
  GetPage(
    name: AppRoutes.COMMUNICATOR_INVITATIONS,
    page: () => const CommunicatorInvitationsScreen(),
    binding: CommunicatorInvitationBinding(),
  ),
  GetPage(
    name: '/sub-category',
    page: () => const CaregiverSubCategoryScreen(),
    binding: CaregiverSubCatagoryBuinding(),
  ),
  GetPage(
    name: '/item-screen',
    page: () => const CaregiverItemScreen(),
    binding: CaregiverItemBuinding(),
  ),

  GetPage(
    name: AppRoutes.COMMUNICATOR_SUB_CATEGORY,
    page: () => const CommunicatorSubCategoryScreen(),
    binding: CommunicatorSubCategoryBinding(),
  ),
  GetPage(
    name: AppRoutes.COMMUNICATOR_ITEM,
    page: () => const CommunicatorItemScreen(),
    binding: CommunicatorItemBinding(),
  ),

  GetPage(
    name: AppRoutes.EDITACTIVITY,
    page: () => const EditActivityScreen(),
    binding: EditActivityBuinding(),
  ),

  GetPage(
    name: AppRoutes.CAREGIVER_Home_Screen,
    page: () => const CaregiverHomeScreen(),
  ),


  GetPage(
  name: AppRoutes.COMMUNICATOR_ALL_QUICK_SPEAKS,
  page: () => const CommunicatorAllQuickSpeaksScreen(),
  binding: BindingsBuilder(() {
    if (!Get.isRegistered<CommunicatorHomeController>()) {
      Get.put(CommunicatorHomeController());
    }
  }),
),

GetPage(
  name: AppRoutes.COMMUNICATOR_ALL_CATEGORIES,
  page: () => const CommunicatorAllCategoriesScreen(),
  binding: BindingsBuilder(() {
    if (!Get.isRegistered<CommunicatorHomeController>()) {
      Get.put(CommunicatorHomeController());
    }
  }),
),


  GetPage(
  name: AppRoutes.CAREGIVER_ALL_QUICK_SPEAKS,
  page: () => const CaregiverAllQuickSpeaksScreen(),
  binding: BindingsBuilder(() {
    if (!Get.isRegistered<CaregiverHomeController>()) {
      Get.lazyPut(() => CaregiverHomeController());
    }
  }),
),

GetPage(
  name: AppRoutes.CAREGIVER_ALL_CATEGORIES,
  page: () => const CaregiverAllCategoriesScreen(),
  binding: BindingsBuilder(() {
    if (!Get.isRegistered<CaregiverHomeController>()) {
      Get.lazyPut(() => CaregiverHomeController());
    }
  }),
),
];

class AppRoutes {
  AppRoutes._();
  static const String SPLASHSCREEN = "/";
  static const String SIGNINSCREEN = "/SignInScreen";
  static const String SIGNUPSCREEN = "/SignUpScreen";
  static const String VERIFICATIONSCREEN = "/VerificationScreen";
  static const String FORGOTSCREEN = "/ForgotPasswordScreen";
  static const String FORGOTOTPSCREEN = "/ForgotVerificationScreen";
  static const String CREATENEWPASSSCREEN = "/CreateNewPasswordScreen";
  static const String ROLESELECTION = "/RoleSelectionScreen";
  static const String CAREGIVERPROFILE = "/CaregiverProfileScreen";
  static const String COMMUNICATORPROFILE = "/CommunicatorProfileScreen";
  static const String NAVIGATIONBAR = '/navigation';
  static const String PROFILE = '/Profile';
  static const String COMMUNICATORHOMESCREEN = '/CommunicatorHomeScreen';
  static const String SUBSCRIPTION = '/Subscription';
  static const String EDITPROFILE = '/EditProfile';
  static const String CHANGEPASSWORD = '/ChangePassword';
  static const String PRIVACYPOLICY = '/PrivacyPolicy';
  static const String SUPPORT = '/Support';
  static const String LANGUAGESCREEN = '/LanguageScreen';
  static const String TEXT_TO_SPEAK = '/text-to-speak';
  static const String EMOTIONS = '/emotions';
  static const String ACTIVITIES = '/activities';
  static const String PEOPLE = '/people';
  static const String VISUAL_SCHEDULES = '/visual-schedules';
  static const String ADD_ACTIVITY = '/add-activity';
  static const String PLACES = '/places';
  static const String FOOD_DRINK = '/food_drink';

  static const String BREAKFAST = '/breakfast';
  static const String MEALS = '/meals';
  static const String DRINKS = '/drinks';
  static const String FRUITS = '/fruits';
  static const String SNACKS = '/snacks';

  static const String HEALTH = '/health';
  static const String GREETINGS = '/greetings';
  static const String QUESTION = '/question';
  static const String ACTION = '/action';
  static const String THINGS = '/things';
  static const String CORE_WORDS = '/core_words';
  static const String ADD_BUTTON = '/add-button';
  static const String EDIT_BUTTON = '/edit-button';
  static const String EDITACTIVITY = '/edit-activity';

  static const String CAREGIVER_CONNECTIONS = '/caregiver-connections';
  static const String COMMUNICATOR_INVITATIONS = '/communicator-invitations';
  static const String COMMUNICATOR_SUB_CATEGORY = '/communicator-sub-category';
  static const String COMMUNICATOR_ITEM = '/communicator-item';


  static const COMMUNICATOR_ALL_QUICK_SPEAKS = '/communicator-all-quick-speaks';
  static const COMMUNICATOR_ALL_CATEGORIES   = '/communicator-all-categories';

  static const CAREGIVER_ALL_QUICK_SPEAKS = '/caregiver-all-quick-speaks';
  static const CAREGIVER_ALL_CATEGORIES   = '/caregiver-all-categories';
  static const CAREGIVER_Home_Screen   = '/caregiver-Home-screen';

}
