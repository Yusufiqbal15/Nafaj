import 'package:flutter/material.dart';
import '../screens/driver_dashboard_animated_3d.dart';
import '../screens/driver_delivery_history.dart';
import '../screens/driver_profile.dart';
import '../screens/driver_wallet.dart';
import '../screens/driver_login.dart';
import '../screens/driver_sign_up.dart';
import '../screens/driver_order_tracking_detailed.dart';
import '../screens/job_creator_my_listings.dart';
import '../screens/job_creator_post_a_job.dart';
import '../screens/job_details_contact_info.dart';
import '../screens/job_seeker_categories.dart';
import '../screens/job_seeker_listings.dart';
import '../screens/live_support_chat.dart';
import '../screens/nafaj_category_grid_blinkit_style.dart';
import '../screens/nafaj_home_exact_header_match.dart';
import '../screens/nafaj_job_listings_marketplace_orange_theme.dart';
import '../screens/nafaj_job_portal_selection.dart';
import '../screens/nafaj_marketplace_home.dart';
import '../screens/nafaj_otp_verification_screen.dart';
import '../screens/nafaj_phone_login_screen.dart';
import '../screens/nafaj_profile_setup_screen.dart';
import '../screens/nafaj_user_sign_up.dart';
import '../screens/nafaj_side_menu_wallet.dart';
import '../screens/nafaj_splash_screen_blinkit_style.dart';
import '../screens/pending_approval_screen.dart';
import '../screens/nafaj_vendor_order_manager_1.dart';
import '../screens/nafaj_vendor_order_manager_2.dart';
import '../screens/nafaj_wallet_top_up_options.dart';
// import '../screens/nafaj_wallet_transactions.dart';
import '../screens/nafaj_welcome_professional.dart';
import '../screens/product_feed_orange_header.dart';
import '../screens/quick_order_final_summary.dart';
import '../screens/quick_order_package_details.dart';
import '../screens/quick_order_vehicle_type.dart';
import '../screens/restaurant_menu_view_orange_header.dart';
import '../screens/vendor_login.dart';
import '../screens/vendor_registration.dart';
import '../screens/vendor_sign_up.dart';
import '../screens/vendor_shop_type.dart';
import '../screens/vendor_dashboard.dart';
import '../screens/vendor_sales_report.dart';
import '../screens/vendor_orders_manager.dart';
import '../screens/order_tracking.dart';
import '../screens/category_products_screen.dart';
import '../screens/delivery_request_form.dart';
import '../screens/delivery_tracking_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/nafaj_delivery_portal.dart';
import '../screens/nafaj_profile_management.dart';
import '../screens/user_orders_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      // ── Job Portal Routes ──
      '/nafaj_job_portal_selection': (context) =>
          const NafajJobPortalSelectionScreen(),
      '/job_seeker_categories': (context) => const JobSeekerCategoriesScreen(),
      '/job_seeker_listings': (context) => const JobSeekerListingsScreen(),
      '/job_creator_post_a_job': (context) => const JobCreatorPostAJobScreen(),
      '/job_creator_my_listings': (context) =>
          const JobCreatorMyListingsScreen(),
      '/job_details': (context) {
        final job = ModalRoute.of(context)!.settings.arguments;
        return JobDetailsContactInfoScreen(job: job as dynamic);
      },

      // ── Approval Routes ──
      '/pending_approval': (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final userType = args?['userType'] as String? ?? 'vendor';
        return PendingApprovalScreen(userType: userType);
      },

      // ── Driver Routes ──
      '/driver_dashboard_animated_3d': (context) =>
          const DriverDashboardAnimated3DScreen(),
      '/driver_delivery_history': (context) =>
          const DriverDeliveryHistoryScreen(),
      '/driver_wallet': (context) => const DriverWalletScreen(),
      '/driver_profile': (context) => const DriverProfileScreen(),
      '/driver_order_tracking_detailed': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return DriverOrderTrackingDetailedScreen(orderData: args);
      },

      // ── Existing Routes ──
      '/driver_login': (context) => const DriverLoginScreen(),
      '/driver_sign_up': (context) => const DriverSignUpScreen(),
      '/live_support_chat': (context) => const LiveSupportChatScreen(),
      '/nafaj_category_grid_blinkit_style': (context) =>
          const NafajCategoryGridBlinkitStyleScreen(),
      '/nafaj_home_exact_header_match': (context) =>
          const NafajHomeExactHeaderMatchScreen(),
      '/nafaj_job_listings_marketplace_orange_theme': (context) =>
          const NafajJobListingsMarketplaceOrangeThemeScreen(),
      '/nafaj_marketplace_home': (context) =>
          const NafajMarketplaceHomeScreen(),
      '/nafaj_otp_verification_screen': (context) =>
          const NafajOtpVerificationScreen(),
      '/nafaj_phone_login_screen': (context) => const NafajPhoneLoginScreen(),
      '/nafaj_profile_setup_screen': (context) =>
          const NafajProfileSetupScreen(),
      '/user_sign_up': (context) => const NafajUserSignUpScreen(),
      '/nafaj_side_menu_wallet': (context) => const NafajSideMenuWalletScreen(),
      '/nafaj_splash_screen_blinkit_style': (context) =>
          const NafajSplashScreenBlinkitStyleScreen(),
      '/nafaj_vendor_order_manager_1': (context) =>
          const NafajVendorOrderManager1Screen(),
      '/nafaj_vendor_order_manager_2': (context) =>
          const NafajVendorOrderManager2Screen(),
      '/nafaj_wallet_top_up_options': (context) =>
          const NafajWalletTopUpOptionsScreen(),
      // '/nafaj_wallet_transactions': (context) =>
      //     const NafajWalletTransactionsScreen(),
      '/nafaj_welcome_professional': (context) =>
          const NafajWelcomeProfessionalScreen(),
      '/product_feed_orange_header': (context) =>
          const ProductFeedOrangeHeaderScreen(),
      '/quick_order_final_summary': (context) =>
          const QuickOrderFinalSummaryScreen(),
      '/quick_order_package_details': (context) =>
          const QuickOrderPackageDetailsScreen(),
      '/quick_order_vehicle_type': (context) =>
          const QuickOrderVehicleTypeScreen(),
      '/restaurant_menu_view_orange_header': (context) =>
          const RestaurantMenuViewOrangeHeaderScreen(),
      '/vendor_login': (context) => const VendorLoginScreen(),
      '/vendor_registration': (context) => const VendorRegistrationScreen(),
      '/vendor_sign_up': (context) => const VendorSignUpScreen(),
      '/vendor_shop_type': (context) => const VendorShopTypeScreen(),
      '/vendor_dashboard': (context) => const VendorDashboardScreen(),
      '/vendor_sales_report': (context) => const VendorSalesReportScreen(),
      '/vendor_orders_manager': (context) => const VendorOrdersManagerScreen(),
      '/order_tracking': (context) => const OrderTrackingScreen(),
      '/category_products': (context) => const CategoryProductsScreen(),
      '/delivery_request_form': (context) => const DeliveryRequestFormScreen(),
      '/delivery_tracking': (context) => const DeliveryTrackingScreen(),
      '/delivery_portal': (context) => const NafajDeliveryPortalScreen(),
      '/nafaj_profile_management': (context) =>
          const NafajProfileManagementScreen(),
      '/checkout_screen': (context) => const CheckoutScreen(),
      '/user_orders': (context) => const UserOrdersScreen(),
    };
  }

  static String get initialRoute => '/nafaj_splash_screen_blinkit_style';
}
