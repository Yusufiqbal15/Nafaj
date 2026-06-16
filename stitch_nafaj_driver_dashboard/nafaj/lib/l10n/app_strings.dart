/// Central string table for EN / Sudanese-AR.
/// Usage:  AppStrings.of(context).heroTitle
/// Or:     AppStrings.direct(isArabic: true).heroTitle
class AppStrings {
  final bool isArabic;
  const AppStrings._(this.isArabic);

  factory AppStrings.direct({required bool isArabic}) =>
      AppStrings._(isArabic);

  // ── Welcome / Splash ─────────────────────────────────────────
  String get heroTitle =>
      isArabic ? 'توصيل ذكي\nما في أسهل منه' : 'Smart Shipping\nMade Simple';
  String get heroSubtitle =>
      isArabic
          ? 'تابع شحنتك خطوة بخطوة مع التتبع الفوري'
          : 'Stay updated every step of the way with live shipment tracking.';
  String get getStarted => isArabic ? 'ابدأ الآن' : 'Get Started';
  String get promoPrefix =>
      isArabic ? 'أول توصيل مجاني! استخدم الكود ' : 'First delivery free! Use code ';

  // ── Role Buttons ─────────────────────────────────────────────
  String get driver => isArabic ? 'سائق' : 'DRIVER';
  String get vendor => isArabic ? 'تاجر' : 'VENDOR';
  String get login => isArabic ? 'دخول' : 'LOGIN';

  // ── Footer ───────────────────────────────────────────────────
  String get faqs => isArabic ? 'أسئلة شائعة' : 'FAQs';
  String get support => isArabic ? 'الدعم' : 'Support';
  String get aboutUs => isArabic ? 'عنا' : 'About Us';

  // ── Auth screens ─────────────────────────────────────────────
  String get emailLabel => isArabic ? 'البريد الإلكتروني' : 'Email Address';
  String get passwordLabel => isArabic ? 'كلمة المرور' : 'Password';
  String get forgotPassword => isArabic ? 'نسيت كلمة المرور؟' : 'Forgot password?';
  String get loginBtn => isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get noAccount => isArabic ? 'ليس لديك حساب؟ ' : "Don't have an account? ";
  String get createAccount => isArabic ? 'إنشاء حساب' : 'Create Account';
  String get secureLogin =>
      isArabic ? 'دخول آمن ومشفر عبر نفج' : 'Secure & encrypted login via Nafaj';

  // ── Driver Portal ─────────────────────────────────────────────
  String get driverPortal => isArabic ? 'بوابة السائق' : 'Driver Portal';
  String get driverWelcome => isArabic ? 'مرحباً بك في نفج' : 'Welcome to Nafaj';
  String get driverSubtitle =>
      isArabic ? 'سجّل دخولك كسائق وابدأ رحلتك' : 'Sign in as driver and start earning';
  String get loginAsDriver =>
      isArabic ? 'تسجيل الدخول كسائق' : 'Sign In as Driver';
  String get noDriverAccount =>
      isArabic ? 'ليس لديك حساب؟ ' : "Don't have an account? ";
  String get createDriverAccount =>
      isArabic ? 'إنشاء حساب جديد' : 'Create New Account';

  // ── Vendor Portal ─────────────────────────────────────────────
  String get vendorPortal => isArabic ? 'بوابة التجار' : 'Vendor Portal';
  String get vendorWelcome =>
      isArabic ? 'لوحة تحكم التاجر' : 'Merchant Dashboard';
  String get vendorSubtitle =>
      isArabic
          ? 'سجّل دخولك لإدارة متجرك وتتبع الطلبات'
          : 'Sign in to manage your store and track orders';
  String get loginAsVendor =>
      isArabic ? 'تسجيل الدخول كتاجر' : 'Sign In as Vendor';
  String get noVendorAccount =>
      isArabic ? 'ليس لديك متجر؟ ' : "Don't have a store? ";
  String get createVendorAccount =>
      isArabic ? 'سجّل متجرك الآن' : 'Register Your Store';
  String get vendorPlatform =>
      isArabic ? 'منصة نفج الموثوقة للتجار' : 'Nafaj — Trusted Merchant Platform';

  // ── Feature chips (Vendor) ─────────────────────────────────────
  String get manageOrders => isArabic ? 'إدارة الطلبات' : 'Manage Orders';
  String get salesReport => isArabic ? 'تقارير المبيعات' : 'Sales Reports';
  String get products => isArabic ? 'المنتجات' : 'Products';
}
