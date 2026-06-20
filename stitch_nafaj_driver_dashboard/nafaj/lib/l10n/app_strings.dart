/// Central string table for EN / Arabic (Modern Standard Arabic).
/// Usage:  AppStrings.direct(isArabic: true).heroTitle
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
      isArabic ? 'دخول آمن ومشفر عبر نفاج' : 'Secure & encrypted login via Nafaj';
  String get fillEmailPassword =>
      isArabic ? 'الرجاء إدخال البريد الإلكتروني وكلمة المرور' : 'Please enter your email and password';
  String get loginFailed => isArabic ? 'فشل تسجيل الدخول' : 'Login failed';
  String get connectionError =>
      isArabic ? 'خطأ في الاتصال، يرجى المحاولة مرة أخرى' : 'Connection error, please try again';
  String get accountRejected =>
      isArabic ? 'تم رفض حسابك. يرجى التواصل مع دعم نفاج.' : 'Your account has been rejected. Please contact Nafaj support.';

  // ── Driver Portal ─────────────────────────────────────────────
  String get driverPortal => isArabic ? 'بوابة السائق' : 'Driver Portal';
  String get driverWelcome => isArabic ? 'مرحباً بك في نفاج' : 'Welcome to Nafaj';
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
      isArabic ? 'منصة نفاج الموثوقة للتجار' : 'Nafaj — Trusted Merchant Platform';

  // ── Feature chips (Vendor) ─────────────────────────────────────
  String get manageOrders => isArabic ? 'إدارة الطلبات' : 'Manage Orders';
  String get salesReport => isArabic ? 'تقارير المبيعات' : 'Sales Reports';
  String get products => isArabic ? 'المنتجات' : 'Products';

  // ── Driver Sign Up ────────────────────────────────────────────
  String get driverRegistration => isArabic ? 'تسجيل السائق' : 'Driver Registration';
  String get stepOf3 => isArabic ? 'خطوة' : 'Step';
  String get of3 => isArabic ? 'من 3' : 'of 3';
  String get stepPersonalDetails => isArabic ? 'البيانات الشخصية' : 'Personal Details';
  String get stepDocumentSubmit => isArabic ? 'تقديم الوثائق' : 'Document Submit';
  String get stepConfirmDetails => isArabic ? 'تأكيد البيانات' : 'Confirm Details';
  String get becomeNafajDriver => isArabic ? 'انضم إلى نفاج كسائق' : 'Become a Nafaj Driver';
  String get driverSignUpSubtitle =>
      isArabic
          ? 'أدخل بياناتك وابدأ الكسب على جدولك الخاص'
          : 'Enter your details to start earning on your own schedule.';
  String get fullName => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get enterFullName => isArabic ? 'أدخل اسمك الكامل' : 'Enter your full name';
  String get enterEmail => isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email';
  String get createStrongPassword => isArabic ? 'أنشئ كلمة مرور قوية' : 'Create strong password';
  String get phoneNumber => isArabic ? 'رقم الهاتف' : 'Phone Number';
  String get cityState => isArabic ? 'المدينة / الولاية (السودان)' : 'City / State (Sudan)';
  String get selectLocation => isArabic ? 'اختر موقعك' : 'Select your location';
  String get vehicleType => isArabic ? 'نوع المركبة' : 'Vehicle Type';
  String get motorcycle => isArabic ? 'دراجة نارية' : 'Motorcycle';
  String get rickshaw => isArabic ? 'ركشة' : 'Rickshaw';
  String get car => isArabic ? 'سيارة' : 'Car';
  String get nextStep => isArabic ? 'الخطوة التالية' : 'Next Step';
  String get alreadyHaveAccount => isArabic ? 'لديك حساب بالفعل؟ ' : 'Already have an account? ';
  String get logIn => isArabic ? 'تسجيل الدخول' : 'Log in';
  String get fillAllFields => isArabic ? 'يرجى ملء جميع الحقول' : 'Please fill all fields';
  String get submitDocuments => isArabic ? 'تقديم الوثائق' : 'Submit Documents';
  String get documentsSubtitle =>
      isArabic
          ? 'يرجى تقديم بيانات الهوية وتفاصيل القيادة'
          : 'Please provide your identification and driving details.';
  String get drivingLicenseNumber => isArabic ? 'رقم رخصة القيادة' : 'Driving License Number';
  String get enterLicenseNumber => isArabic ? 'أدخل رقم الرخصة' : 'Enter license number';
  String get nationalIdNumber => isArabic ? 'رقم بطاقة الهوية الوطنية' : 'Nationality ID Number';
  String get enterNationalId => isArabic ? 'أدخل رقم الهوية الوطنية' : 'Enter national ID';
  String get provideAllDocuments => isArabic ? 'يرجى تقديم جميع الوثائق' : 'Please provide all documents';
  String get continueToReview => isArabic ? 'المتابعة إلى المراجعة' : 'Continue to Review';
  String get confirmDetailsTitle => isArabic ? 'تأكيد البيانات' : 'Confirm Details';
  String get reviewBeforeSubmit =>
      isArabic ? 'يرجى مراجعة بياناتك قبل الإرسال' : 'Please review your details before submitting.';
  String get summaryEmail => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get summaryPhone => isArabic ? 'الهاتف' : 'Phone';
  String get summaryCity => isArabic ? 'المدينة' : 'City';
  String get summaryVehicle => isArabic ? 'المركبة' : 'Vehicle';
  String get summaryLicense => isArabic ? 'رقم الرخصة' : 'License No.';
  String get summaryNationalId => isArabic ? 'الهوية الوطنية' : 'Nationality ID';
  String get confirmAndProceed => isArabic ? 'تأكيد والمتابعة' : 'Confirm & Proceed';
  String get termsAgreement =>
      isArabic
          ? 'بالمتابعة، أنت توافق على شروط خدمة نفاج وسياسة الخصوصية'
          : "By continuing, you agree to Nafaj's Terms of Service and Privacy Policy.";
  String get registrationSuccess =>
      isArabic ? 'تم التسجيل بنجاح! في انتظار موافقة الإدارة' : 'Registration successful! Awaiting admin approval.';
  String get registrationFailed => isArabic ? 'فشل إنشاء الحساب' : 'Registration failed';
  String get errorPrefix => isArabic ? 'خطأ: ' : 'Error: ';

  // City names
  String get cityKhartoum => isArabic ? 'الخرطوم' : 'Khartoum';
  String get cityOmdurman => isArabic ? 'أم درمان' : 'Omdurman';
  String get cityBahri => isArabic ? 'الخرطوم بحري' : 'Khartoum North (Bahri)';
  String get cityPortSudan => isArabic ? 'بور سودان' : 'Port Sudan';
  String get cityWadMadani => isArabic ? 'ود مدني' : 'Wad Madani';
  List<String> get cities =>
      isArabic
          ? ['الخرطوم', 'أم درمان', 'الخرطوم بحري', 'بور سودان', 'ود مدني']
          : ['Khartoum', 'Omdurman', 'Khartoum North (Bahri)', 'Port Sudan', 'Wad Madani'];

  // ── Driver Dashboard ──────────────────────────────────────────
  String get online => isArabic ? 'متصل' : 'Online';
  String get offline => isArabic ? 'غير متصل' : 'Offline';
  String get readyForOrders => isArabic ? 'جاهز للطلبات' : 'Ready for orders';
  String get tapToGoOnline => isArabic ? 'اضغط للاتصال' : 'Tap to go online';
  String get networkLabel => isArabic ? 'شبكة 3G' : '3G NETWORK';
  String get highStrength => isArabic ? 'إشارة قوية' : 'High Strength';
  String get searchRouteOrRestaurant =>
      isArabic ? 'ابحث عن المسار أو المطعم' : 'Search route or restaurant';
  String activeOrdersCount(int count) =>
      isArabic ? '$count طلبات نشطة' : '$count Active Orders';
  String get availableOrders => isArabic ? 'الطلبات المتاحة' : 'Available Orders';
  String ordersCount(int count) =>
      isArabic ? '$count طلبات' : '$count orders';
  String get findingOrders => isArabic ? 'جارٍ البحث عن الطلبات...' : 'Finding available orders...';
  String get searchingNearby => isArabic ? 'نبحث عن طلبات قريبة منك' : "We're searching for orders near you";
  String get noOrdersAvailable => isArabic ? 'لا توجد طلبات متاحة' : 'No orders available';
  String get ordersAppearWhenVendors =>
      isArabic
          ? 'ستظهر الطلبات هنا عندما يؤكدها التجار'
          : 'Orders will appear here when vendors\nconfirm their orders';
  String get refresh => isArabic ? 'تحديث' : 'Refresh';
  String get earnings => isArabic ? 'الأرباح' : 'EARNINGS';
  String get distance => isArabic ? 'المسافة' : 'Distance';
  String get estTime => isArabic ? 'الوقت المقدر' : 'Est. Time';
  String get order => isArabic ? 'الطلب' : 'Order';
  String get slideToAccept => isArabic ? 'اسحب للقبول' : 'Slide to Accept';
  String get accepted => isArabic ? 'تم القبول!' : 'Accepted!';
  String get connectionErrorPrefix => isArabic ? 'خطأ في الاتصال: ' : 'Connection Error: ';
  String get activeDelivery => isArabic ? 'توصيل نشط' : 'Active Delivery';
  String get activeDeliveryMessage =>
      isArabic
          ? 'لديك توصيل نشط بالفعل. يرجى إكماله قبل قبول طلب جديد.'
          : 'You already have an active delivery in progress. Please complete it before accepting a new order.';
  String get ok => isArabic ? 'حسناً' : 'OK';
  String get viewActiveOrder => isArabic ? 'عرض الطلب النشط' : 'View Active Order';
  String get orderAcceptedSuccess =>
      isArabic ? 'تم قبول الطلب بنجاح! جارٍ التوجيه للتتبع...' : 'Order accepted successfully! Redirecting to tracking...';
  String get failedToAcceptOrder => isArabic ? 'فشل قبول الطلب' : 'Failed to accept order';
  String get youAreHere => isArabic ? 'موقعك الحالي' : 'You are here';

  // ── Bottom Navigation ─────────────────────────────────────────
  String get navMap => isArabic ? 'الخريطة' : 'Map';
  String get navHistory => isArabic ? 'السجل' : 'History';
  String get navWallet => isArabic ? 'المحفظة' : 'Wallet';
  String get navProfile => isArabic ? 'ملفي' : 'Profile';

  // ── Driver Wallet ─────────────────────────────────────────────
  String get myWallet => isArabic ? 'محفظتي' : 'My Wallet';
  String get availableBalance => isArabic ? 'الرصيد المتاح' : 'Available Balance';
  String get withdraw => isArabic ? 'سحب' : 'Withdraw';
  String get history => isArabic ? 'السجل' : 'History';
  String get perDelivery => isArabic ? 'لكل توصيل' : 'Per Delivery';
  String get totalDone => isArabic ? 'إجمالي المنجز' : 'Total Done';
  String get thisWeek => isArabic ? 'هذا الأسبوع' : 'This Week';
  String get thisWeekEarnings => isArabic ? 'أرباح هذا الأسبوع' : "This Week's Earnings";
  String get deliveries => isArabic ? 'التوصيلات' : 'Deliveries';
  String get totalAllTime => isArabic ? 'إجمالي الكل' : 'Total All-Time';
  String get perOrder => isArabic ? 'لكل طلب' : 'Per Order';
  String get weekDeliveries => isArabic ? 'توصيلات الأسبوع' : 'Week Deliveries';
  String get weekEarnings => isArabic ? 'أرباح الأسبوع' : 'Week Earnings';
  String earningsTabLabel(int count) =>
      isArabic ? 'الأرباح ($count)' : 'Earnings ($count)';
  String deliveriesTabLabel(int count) =>
      isArabic ? 'التوصيلات ($count)' : 'Deliveries ($count)';
  String get noTransactionsYet => isArabic ? 'لا توجد معاملات بعد' : 'No transactions yet';
  String get completeDeliveriesEarn =>
      isArabic ? 'أكمل التوصيلات لكسب 500 SDG لكل منها' : 'Complete deliveries to earn 500 SDG each';
  String get noDeliveriesYet => isArabic ? 'لا توجد توصيلات بعد' : 'No deliveries yet';
  String get completedDeliveriesHere =>
      isArabic ? 'ستظهر توصيلاتك المكتملة هنا' : 'Your completed deliveries will appear here';
  String get deliveryFee => isArabic ? 'رسوم التوصيل' : 'Delivery Fee';
  String get bonus => isArabic ? 'مكافأة' : 'Bonus';
  String get withdrawal => isArabic ? 'سحب' : 'Withdrawal';
  String balanceLabel(String amount) =>
      isArabic ? 'الرصيد: $amount SDG' : 'Balance: $amount SDG';
  String get todayPrefix => isArabic ? 'اليوم، ' : 'Today, ';
  String get yesterdayPrefix => isArabic ? 'أمس، ' : 'Yesterday, ';
  String get deliveredBadge => isArabic ? 'تم التوصيل' : 'DELIVERED';
  String get customerPrefix => isArabic ? 'العميل: ' : 'Customer: ';
  String orderAmountLabel(String amount) =>
      isArabic ? 'الطلب: $amount SDG' : 'Order: $amount SDG';
  String weekDeliveriesCalc(int count) =>
      isArabic ? '$count × 500 SDG' : '$count × 500 SDG';

  // ── Driver Profile ────────────────────────────────────────────
  String get myProfile => isArabic ? 'ملفي الشخصي' : 'My Profile';
  String get verifiedDriver => isArabic ? 'سائق موثق' : 'Verified Driver';
  String get rating => isArabic ? 'التقييم' : 'Rating';
  String get deliveriesCount => isArabic ? 'التوصيلات' : 'Deliveries';
  String get member => isArabic ? 'عضو' : 'Member';
  String get vehicleInformation => isArabic ? 'معلومات المركبة' : 'Vehicle Information';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get vehicleTypeLabel => isArabic ? 'نوع المركبة' : 'Vehicle Type';
  String get model => isArabic ? 'الطراز' : 'Model';
  String get plateNumber => isArabic ? 'رقم اللوحة' : 'Plate Number';
  String get licenseExpiry => isArabic ? 'تاريخ انتهاء الرخصة' : 'License Expiry';
  String get personalInformation => isArabic ? 'المعلومات الشخصية' : 'Personal Information';
  String get fullNameLabel => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get nationalIdLabel => isArabic ? 'الهوية الوطنية' : 'National ID';
  String get cityLabel => isArabic ? 'المدينة' : 'City';
  String get joinDate => isArabic ? 'تاريخ الانضمام' : 'Join Date';
  String get quickActions => isArabic ? 'الإجراءات السريعة' : 'Quick Actions';
  String get deliveryHistory => isArabic ? 'سجل التوصيل' : 'Delivery History';
  String get viewAllPastDeliveries =>
      isArabic ? 'عرض جميع التوصيلات السابقة' : 'View all past deliveries';
  String get walletAndPayments => isArabic ? 'المحفظة والمدفوعات' : 'Wallet & Payments';
  String get checkBalanceSettlements =>
      isArabic ? 'التحقق من الرصيد والتسويات' : 'Check balance and settlements';
  String get supportAction => isArabic ? 'الدعم' : 'Support';
  String get getHelpFromTeam => isArabic ? 'احصل على المساعدة من فريقنا' : 'Get help from our team';
  String get documents => isArabic ? 'الوثائق' : 'Documents';
  String get manageDocuments => isArabic ? 'إدارة وثائقك' : 'Manage your documents';
  String get logOut => isArabic ? 'تسجيل الخروج' : 'Log Out';
  String get signOutAccount => isArabic ? 'تسجيل الخروج من حسابك' : 'Sign out of your account';

  // ── Driver Delivery History ───────────────────────────────────
  String get deliveryHistoryTitle => isArabic ? 'سجل التوصيل' : 'Delivery History';
  String get total => isArabic ? 'الإجمالي' : 'Total';
  String get completed => isArabic ? 'المكتمل' : 'Completed';
  String get cancelled => isArabic ? 'الملغي' : 'Cancelled';
  String get tabAll => isArabic ? 'الكل' : 'All';
  String get tabCompleted => isArabic ? 'المكتملة' : 'Completed';
  String get tabCancelled => isArabic ? 'الملغاة' : 'Cancelled';
  String get noDeliveryHistory => isArabic ? 'لا يوجد سجل توصيل بعد' : 'No delivery history yet';
  String get acceptOrdersToSee => isArabic ? 'اقبل الطلبات لتراها هنا' : 'Accept orders to see them here';
  String get statusCompleted => isArabic ? 'مكتمل' : 'Completed';
  String get statusCancelled => isArabic ? 'ملغي' : 'Cancelled';
  String get statusAwaitingConfirmation => isArabic ? 'في انتظار التأكيد' : 'Awaiting Confirmation';
  String get statusInProgress => isArabic ? 'قيد التنفيذ' : 'In Progress';
  String get statusPending => isArabic ? 'معلق' : 'Pending';
  String get tapToContinueTracking => isArabic ? 'اضغط للمتابعة' : 'Tap to continue tracking';
  String get waitingForCustomerConfirmation =>
      isArabic ? 'في انتظار تأكيد العميل' : 'Waiting for customer confirmation';
  String get loginAsDriverToView =>
      isArabic ? 'يرجى تسجيل الدخول كسائق لعرض سجل التوصيل' : 'Please login as a driver to view delivery history';
  String get loginAction => isArabic ? 'تسجيل الدخول' : 'Login';
  String get waitingCustomerDelivery =>
      isArabic ? '⏳ في انتظار تأكيد العميل' : '⏳ Waiting for customer to confirm delivery';
  String get errorLoadingDeliveries =>
      isArabic ? 'خطأ في تحميل التوصيلات. يرجى التحقق من الاتصال.' : 'Error loading deliveries. Please check your connection.';

  // ── Pending Approval ─────────────────────────────────────────
  String get pendingApproval => isArabic ? 'في انتظار الموافقة' : 'Pending Approval';
  String get pendingApprovalMessage =>
      isArabic
          ? 'تم استلام طلبك وهو قيد المراجعة من قبل الإدارة'
          : 'Your application has been received and is under review by our team';
  String get accountUnderReview =>
      isArabic ? 'حسابك قيد المراجعة' : 'Your account is under review';
  String get accountRejectedStatus =>
      isArabic ? 'تم رفض حسابك.\nيرجى التواصل مع دعم نفاج.' : 'Your account has been rejected.\nPlease contact nafaj support.';
  String get accountRejectedSnack =>
      isArabic ? 'تم رفض الحساب. تواصل مع الدعم.' : 'Account rejected. Contact support for assistance.';
  String get stillPendingSnack =>
      isArabic ? 'لا يزال معلقاً. سنُعلمك عند الموافقة.' : "Still pending. We'll notify you once approved.";
  String get couldNotCheckStatus =>
      isArabic ? 'تعذّر التحقق من الحالة' : 'Could not check status';
  String get networkError => isArabic ? 'خطأ في الشبكة. حاول مجدداً.' : 'Network error. Please try again.';
  String get logOutAction => isArabic ? 'تسجيل الخروج' : 'Log out';
  String get registrationSubmitted =>
      isArabic ? 'تم تقديم التسجيل' : 'Registration submitted';
  String get yourDetailsSaved =>
      isArabic ? 'تم حفظ بياناتك' : 'Your details have been saved';
  String get adminReviewInProgress =>
      isArabic ? 'المراجعة الإدارية جارية' : 'Admin review in progress';
  String get nafajTeamVerifying =>
      isArabic ? 'فريق نفاج يتحقق من معلوماتك' : 'Nafaj team is verifying your information';
  String get accessGrantedAfterApproval =>
      isArabic ? 'يُمنح الوصول بعد الموافقة' : 'Access granted after approval';
  String get youllBeRedirected =>
      isArabic ? 'ستُحوَّل تلقائياً' : "You'll be redirected automatically";
  String get checkApprovalStatus =>
      isArabic ? 'التحقق من حالة الموافقة' : 'Check Approval Status';
  String get autoCheckInfo =>
      isArabic
          ? 'تُفحص الحالة تلقائياً كل 30 ثانية. اضغط الزر أعلاه للفحص الفوري.'
          : 'Status is checked automatically every 30 seconds. Tap the button above to check immediately.';

  // ── Order Tracking (Driver) ──────────────────────────────────
  String get orderTracking => isArabic ? 'تتبع الطلب' : 'Order Tracking';
  String get deliveryTo => isArabic ? 'التوصيل إلى: ' : 'Delivery to: ';
  String get stageTitleHeadingToPickup => isArabic ? 'في الطريق للاستلام' : 'Heading to Pickup';
  String get stageSubtitleHeadingToPickup => isArabic ? 'أنت في طريقك إلى المطعم' : 'On your way to the restaurant';
  String get stageTitlePickupDone => isArabic ? 'تم الاستلام' : 'Pickup Done';
  String get stageSubtitlePickupDone => isArabic ? 'التقط صورة كدليل على الاستلام' : 'Take a photo as proof of pickup';
  String get stageTitleOutForDelivery => isArabic ? 'خرج للتوصيل' : 'Out for Delivery';
  String get stageSubtitleOutForDelivery => isArabic ? 'في الطريق إلى العميل' : 'On the way to the customer';
  String get stageTitleUploadDeliveryProof => isArabic ? 'رفع دليل التوصيل' : 'Upload Delivery Proof';
  String get stageSubtitleUploadDeliveryProof =>
      isArabic ? 'التقط صورة — سيؤكد العميل الاستلام' : 'Take a photo — customer will confirm receipt';
  String get changeImage => isArabic ? 'تغيير الصورة' : 'Change Image';
  String get requiredToCompleteStage => isArabic ? 'مطلوبة لإكمال هذه المرحلة' : 'Required to complete this stage';
  String get uploadImageToContinue => isArabic ? 'ارفع صورة للمتابعة' : 'Upload Image to Continue';
  String get completeStage => isArabic ? 'إكمال المرحلة' : 'Complete Stage';
  String get stageDone => isArabic ? 'تم' : 'Done';
  String get stageCurrent => isArabic ? 'الحالية' : 'Current';
  String get onYourWayTakePhoto => isArabic ? 'استمر! التقط صورة عند الوصول.' : 'On your way! Take a pickup photo when you arrive.';
  String get deliveryProofUploaded =>
      isArabic ? '✅ تم رفع دليل التوصيل! في انتظار تأكيد العميل.' : '✅ Delivery proof uploaded! Waiting for customer confirmation.';
  String get stageCompleted => isArabic ? 'اكتملت المرحلة!' : 'Stage completed!';
  String get pleaseUploadPhotoForStage =>
      isArabic ? 'يرجى التقاط صورة أو رفعها لإكمال هذه المرحلة' : 'Please take/upload a photo to complete this stage';
  String tapToImageType(String imageType, bool isWeb) {
    final typeLabel = isArabic
        ? (imageType == 'pickup' ? 'صورة الاستلام' : 'صورة التوصيل')
        : '$imageType image';
    return isArabic
        ? 'اضغط ${isWeb ? 'لاختيار' : 'لالتقاط'} $typeLabel'
        : '${isWeb ? 'Tap to select' : 'Tap to capture'} $typeLabel';
  }

  // ── Bottom Navigation (User) ──────────────────────────────────
  String get navHome => isArabic ? 'الرئيسية' : 'Home';
  String get navOrders => isArabic ? 'الطلبات' : 'Orders';
  String get navCategories => isArabic ? 'الفئات' : 'Categories';
  String get navJobsUser => isArabic ? 'الوظائف' : 'Jobs';
  String get navProfileUser => isArabic ? 'ملفي' : 'Profile';

  // ── Home Screen ───────────────────────────────────────────────
  String get nafajIn => isArabic ? 'نفاج في' : 'Nafaj in';
  String get minutesDelivery => isArabic ? '١٥ دقيقة' : '15 minutes';
  String get searchHintHome => isArabic ? 'ابحث عن "منتج"' : 'Search "power bank"';
  String get featuredForYou => isArabic ? 'منتجات مميزة لك' : 'Featured for You';
  String get seeAll => isArabic ? 'عرض الكل' : 'See all';
  String get popularShops => isArabic ? 'المتاجر الشهيرة' : 'Popular Shops';
  String shopsCategoryLabel(String cat) => isArabic ? 'متاجر: $cat' : 'Shops: $cat';
  String get noProductsAvailable => isArabic ? 'لا توجد منتجات' : 'No products available';
  String get noShopsAvailable => isArabic ? 'لا توجد متاجر' : 'No shops available';
  String get addBtn => isArabic ? 'أضف' : 'ADD';
  String itemsCartCount(int count) => isArabic ? '$count عناصر' : '$count Items';
  String get proceedBtn => isArabic ? 'المتابعة' : 'PROCEED';
  String get editAddressTitle => isArabic ? 'تعديل العنوان' : 'Edit Address';
  String get enterAddress => isArabic ? 'أدخل عنوانك' : 'Enter your address';
  String get catFood => isArabic ? 'طعام' : 'Food';
  String get catPharmacy => isArabic ? 'صيدلية' : 'Pharmacy';
  String get catJobsHome => isArabic ? 'وظائف' : 'Jobs';
  String get catClassifieds => isArabic ? 'إعلانات' : 'Classifieds';
  String get catGrocery => isArabic ? 'بقالة' : 'Grocery';
  String get catCourier => isArabic ? 'توصيل' : 'Courier';
  String get catServices => isArabic ? 'خدمات' : 'Services';
  String get catMore => isArabic ? 'المزيد' : 'More';
  String get fastTag => isArabic ? 'سريع' : 'Fast';
  String get promoFreshVeg => isArabic ? 'خضروات\nطازجة' : 'Fresh\nVegetables';
  String get promoPharmacyEssentials => isArabic ? 'أدوية\nأساسية' : 'Pharmacy\nEssentials';
  String get promoDeliveryCourier => isArabic ? 'توصيل\nوشحن' : 'Delivery &\nCourier';
  String get promoCareerJobs => isArabic ? 'مهن\nووظائف' : 'Career &\nJobs';
  String productsCountLabel(int count) => isArabic ? '$count منتج' : '$count products';

  // ── Orders Screen ──────────────────────────────────────────────
  String get myOrders => isArabic ? 'طلباتي' : 'My Orders';
  String ordersTotal(int count) => isArabic ? '$count طلبات' : '$count orders';
  String get filterAll => isArabic ? 'الكل' : 'All';
  String get filterPending => isArabic ? 'معلق' : 'Pending';
  String get filterDelivered => isArabic ? 'تم التوصيل' : 'Delivered';
  String get retryBtn => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get noOrdersYet => isArabic ? 'لا توجد طلبات بعد' : 'No orders yet';
  String get ordersWillAppearHere => isArabic ? 'ستظهر طلباتك هنا' : 'Your orders will appear here';
  String get confirmDeliveryDialogTitle => isArabic ? 'تأكيد التوصيل' : 'Confirm Delivery';
  String get confirmDeliveryDialogMsg =>
      isArabic
          ? 'هل استلمت طلبك بنجاح؟ سيُسجَّل الطلب كـ "تم التوصيل".'
          : 'Have you received your order successfully? This will mark the order as delivered.';
  String get yesConfirmBtn => isArabic ? 'نعم، تأكيد' : 'Yes, Confirm';
  String get confirmingDeliveryMsg => isArabic ? 'جارٍ تأكيد التوصيل...' : 'Confirming delivery...';
  String get deliveryConfirmedSuccess => isArabic ? '✅ تم تأكيد التوصيل بنجاح!' : '✅ Delivery confirmed successfully!';
  String get failedToConfirmDelivery => isArabic ? 'فشل تأكيد التوصيل' : 'Failed to confirm delivery';
  String get viewDetailsBtn => isArabic ? 'عرض التفاصيل' : 'View Details';
  String get confirmDeliveryBtn => isArabic ? '✓ تأكيد التوصيل' : '✓ Confirm Delivery';
  String get trackOrderBtn => isArabic ? 'تتبع الطلب' : 'Track Order';
  String get totalAmountLabel => isArabic ? 'المبلغ الإجمالي' : 'Total Amount';
  String get orderDetailsTitle => isArabic ? 'تفاصيل الطلب' : 'Order Details';
  String get orderNumberLabel => isArabic ? 'رقم الطلب' : 'Order Number';
  String get vendorNameLabel => isArabic ? 'البائع' : 'Vendor';
  String get vendorEmailLabel => isArabic ? 'بريد البائع' : 'Vendor Email';
  String get deliveryAddressLabel => isArabic ? 'عنوان التوصيل' : 'Delivery Address';
  String get paymentMethodLabel => isArabic ? 'طريقة الدفع' : 'Payment Method';
  String get orderItemsLabel => isArabic ? 'العناصر' : 'Items';
  String moreItemsLabel(int count) => isArabic ? '+$count عناصر إضافية' : '+$count more items';
  String itemsListCount(int count) => isArabic ? 'العناصر ($count)' : 'Items ($count)';
  String get statusPendingLabel => isArabic ? 'معلق' : 'Pending';
  String get statusConfirmedLabel => isArabic ? 'تم التأكيد' : 'Confirmed';
  String get statusPreparingLabel => isArabic ? 'قيد التحضير' : 'Preparing';
  String get statusReadyLabel => isArabic ? 'جاهز' : 'Ready';
  String get statusPickedUpLabel => isArabic ? 'تم الاستلام' : 'Picked Up';
  String get statusOutForDeliveryLabel => isArabic ? 'خرج للتوصيل' : 'Out for Delivery';
  String get statusArrivingSoonLabel => isArabic ? 'يصل قريباً' : 'Arriving Soon';
  String get statusConfirmReceiptLabel => isArabic ? 'تأكيد الاستلام' : 'Confirm Receipt';
  String get statusDeliveredLabel => isArabic ? 'تم التوصيل' : 'Delivered';
  String get statusCancelledLabel => isArabic ? 'ملغي' : 'Cancelled';

  // ── Categories Screen ──────────────────────────────────────────
  String get groceryAndKitchen => isArabic ? 'بقالة ومطبخ' : 'Grocery & Kitchen';
  String get dailyEssentialsSubtitle =>
      isArabic ? 'احتياجات يومية تُوصَّل فوراً' : 'DAILY ESSENTIALS DELIVERED INSTANTLY';
  String get snacksAndDrinks => isArabic ? 'وجبات خفيفة ومشروبات' : 'Snacks & Drinks';
  String get sudaneseFavoritesSubtitle =>
      isArabic ? 'المفضلات السودانية وأكثر' : 'SUDANESE FAVORITES AND MORE';
  String get exploreNow => isArabic ? 'استكشف الآن' : 'EXPLORE NOW';
  String get searchFreshMeatHint =>
      isArabic ? 'ابحث عن "لحم طازج" أو "مخبوزات"' : "Search 'Fresh Meat' or 'Bakery'";
  String get deliveringToLabel => isArabic ? 'التوصيل إلى' : 'DELIVERING TO';
  String get catVegetablesFruits => isArabic ? 'خضروات وفواكه' : 'Vegetables & Fruits';
  String get catRiceDal => isArabic ? 'دقيق، أرز وعدس' : 'Atta, Rice & Dal';
  String get catOilGhee => isArabic ? 'زيت، سمن وتوابل' : 'Oil, Ghee & Masala';
  String get catDairyEggs => isArabic ? 'ألبان، خبز وبيض' : 'Dairy, Bread & Eggs';
  String get catBakeryBiscuits => isArabic ? 'مخبوزات وبسكويت' : 'Bakery & Biscuits';
  String get catSnacksMunchies => isArabic ? 'وجبات خفيفة' : 'Snacks & Munchies';
  String get catChickenMeat => isArabic ? 'دجاج، لحم وسمك' : 'Chicken, Meat & Fish';
  String get catKitchenware => isArabic ? 'أدوات وأجهزة مطبخ' : 'Kitchenware & Appliances';
  String get catChipsNamkeen => isArabic ? 'شيبس ومكسرات' : 'Chips & Namkeen';
  String get catSweetsChocolates => isArabic ? 'حلويات وشوكولاتة' : 'Sweets & Chocolates';
  String get catDrinksJuices => isArabic ? 'مشروبات وعصائر' : 'Drinks & Juices';
  String get catTeaCoffee => isArabic ? 'شاي، قهوة ومشروبات حليب' : 'Tea, Coffee & Milk Drinks';
  String get promoSudaneseCoffee =>
      isArabic ? 'قهوة سودانية طازجة\nمطحونة وحبوب' : 'Fresh Sudanese Coffee\nBeans & Ground';
  String get promoHibiscusJuices =>
      isArabic ? 'كركدي منعش\nوعصائر محلية' : 'Refreshing Hibiscus\n& Local Juices';
  String get promoQuickOrderSend =>
      isArabic ? 'طلب سريع\nأرسل طردك الآن' : 'Quick Order\nSend Packages Now';

  // ── Category Products Screen ───────────────────────────────────
  String get shopsNearYouLabel => isArabic ? 'منتجات الفئة' : 'Category Products';
  String shopsNearbyCount(int count) => isArabic ? '$count منتج' : '$count products';
  String searchInCategoryHint(String cat) =>
      isArabic ? 'البحث في $cat...' : 'Search in $cat...';

  // ── Profile / Settings ─────────────────────────────────────────
  String get changeLanguageLabel => isArabic ? 'تغيير إلى الإنجليزية' : 'Switch to Arabic';
  String get languageLabel => isArabic ? 'اللغة' : 'Language';
  String get currentLanguageLabel => isArabic ? 'العربية' : 'English';

  // ── Jobs Portal ────────────────────────────────────────────────
  String get nafajJobsTitle => isArabic ? 'وظائف نفاج' : 'Nafaj Jobs';
  String get welcomeToNafajJobs => isArabic ? 'مرحباً بوظائف نفاج' : 'Welcome to Nafaj Jobs';
  String get jobsPortalSubtitle => isArabic ? 'اختر مسارك لاستكشاف الفرص في السودان' : 'Select your path to start exploring opportunities in Sudan';
  String get iAmJobSeeker => isArabic ? 'أنا باحث عن عمل' : 'I am a Job Seeker';
  String get jobSeekerDesc => isArabic ? 'اكتشف خطوتك المهنية القادمة. تصفح آلاف الوظائف في الخرطوم وخارجها.' : 'Discover your next career move. Browse thousands of jobs across Khartoum and beyond.';
  String get iAmEmployer => isArabic ? 'أنا صاحب عمل' : 'I am an Employer';
  String get employerDesc => isArabic ? 'ابحث عن أفضل المواهب لعملك. انشر الوظائف وأدِر الطلبات بسهولة.' : 'Find the best talent for your business. Post jobs and manage applications seamlessly.';
  String get needHelp => isArabic ? 'تحتاج مساعدة؟ ' : 'Need help? ';
  String get contactSupport => isArabic ? 'تواصل مع الدعم' : 'Contact Support';

  // ── Profile Management Screen ──────────────────────────────────
  String get platinumMember => isArabic ? 'عضو بلاتيني' : 'PLATINUM MEMBER';
  String get profileOrders => isArabic ? 'الطلبات' : 'Orders';
  String get profileJobs => isArabic ? 'الوظائف' : 'Jobs';
  String get profilePoints => isArabic ? 'النقاط' : 'Points';
  String get personalManagement => isArabic ? 'إدارة الملف الشخصي' : 'Personal Management';
  String get personalInformationMenu => isArabic ? 'المعلومات الشخصية' : 'Personal Information';
  String get editNamePhoneEmail => isArabic ? 'تعديل الاسم والهاتف والبريد' : 'Edit name, phone, email';
  String get savedAddresses => isArabic ? 'العناوين المحفوظة' : 'Saved Addresses';
  String get savedAddressesSubtitle => isArabic ? 'المنزل، المكتب، مواقع أخرى' : 'Home, Office, Other locations';
  String get notificationsMenu => isArabic ? 'الإشعارات' : 'Notifications';
  String get notificationsSubtitle => isArabic ? 'تحديثات، عروض، تنبيهات' : 'Updates, Promos, Alerts';
  String get financialSection => isArabic ? 'المالية' : 'Financial';
  String get nafajWalletMenu => isArabic ? 'محفظة نفاج' : 'Nafaj Wallet';
  String get walletBalanceLabel => isArabic ? 'الرصيد: 25,500 SDG' : 'Balance: SDG 25,500';
  String get paymentMethods => isArabic ? 'طرق الدفع' : 'Payment Methods';
  String get paymentMethodsSubtitle => isArabic ? 'بطاقات، بنكك، قسائم' : 'Cards, Bankak, Vouchers';
  String get securityAndMore => isArabic ? 'الأمان والمزيد' : 'Security & More';
  String get securitySettings => isArabic ? 'إعدادات الأمان' : 'Security Settings';
  String get securitySubtitle => isArabic ? 'كلمة المرور، البصمة' : 'Password, Biometrics';
  String get helpAndSupport => isArabic ? 'المساعدة والدعم' : 'Help & Support';
  String get helpSubtitle => isArabic ? 'الأسئلة الشائعة، تواصل معنا، الشروط' : 'FAQs, Contact us, Terms';
  String get aboutNafaj => isArabic ? 'عن نفاج' : 'About Nafaj';
  String get appVersion => isArabic ? 'الإصدار 2.4.0' : 'Version 2.4.0';
  String get logoutAccount => isArabic ? 'تسجيل الخروج' : 'LOGOUT ACCOUNT';
  String get availableBalanceLabel => isArabic ? 'الرصيد المتاح' : 'Available Balance';
  String get topUpBankak => isArabic ? 'شحن عبر بنكك' : 'Top Up via Bankak';

  // ── Job Creator / Post a Job ──────────────────────────────────
  String get postAJob => isArabic ? 'نشر وظيفة جديدة' : 'Post a New Job';
  String get myJobs => isArabic ? 'وظائفي' : 'My Jobs';
  String get totalJobsPosted => isArabic ? 'إجمالي الوظائف المنشورة' : 'Total Jobs Posted';
  String get tellUsWhatYouNeed => isArabic ? 'أخبرنا بما تحتاج' : 'Tell us what you need';
  String get postJobSubtitle => isArabic
      ? 'أدخل التفاصيل للعثور على أفضل الكفاءات في السودان.'
      : 'Provide details to find the best talent in Sudan.';
  String get creatorName => isArabic ? 'اسم صاحب العمل' : 'Creator Name';
  String get creatorNameHint => isArabic ? 'أدخل اسمك أو شركتك' : 'Enter your name or company';
  String get jobTitle => isArabic ? 'المسمى الوظيفي' : 'Job Title';
  String get jobTitleHint => isArabic ? 'مثال: سائق توصيل، محاسب' : 'e.g. Delivery Driver, Accountant';
  String get sectorLabel => isArabic ? 'القطاع' : 'Sector';
  String get selectSector => isArabic ? 'اختر قطاعاً' : 'Select a sector';
  String get jobTypeLabel => isArabic ? 'نوع الوظيفة' : 'Job Type';
  String get locationLabel => isArabic ? 'الموقع' : 'Location';
  String get locationHint => isArabic ? 'مثال: الخرطوم' : 'e.g. Khartoum, SD';
  String get salaryLabel => isArabic ? 'الراتب' : 'Salary';
  String get salaryHint => isArabic ? 'مثال: 300,000 - 500,000 جنيه' : 'e.g. 300,000 - 500,000 SDG';
  String get jobDescriptionLabel => isArabic ? 'وصف الوظيفة' : 'Job Description';
  String get jobDescHint => isArabic
      ? 'صِف المهام والمتطلبات...'
      : 'Describe the responsibilities and requirements...';
  String get postJobBtn => isArabic ? 'نشر الوظيفة' : 'Post Job';
  String get jobPostedTitle => isArabic ? 'تم نشر الوظيفة!' : 'Job Posted!';
  String get jobPostedDesc => isArabic ? 'تم نشر وظيفتك بنجاح.' : 'Your job has been posted successfully.';
  String get viewMyListings => isArabic ? 'عرض إعلاناتي' : 'View My Listings';
  String get postAnotherJob => isArabic ? 'نشر وظيفة أخرى' : 'Post Another Job';
  String get selectSectorFirst => isArabic ? 'الرجاء اختيار قطاع' : 'Please select a sector';
  String get requiredField => isArabic ? 'مطلوب' : 'Required';
  String get negotiable => isArabic ? 'قابل للتفاوض' : 'Negotiable';

  // ── Job Seeker / Categories ───────────────────────────────────
  String get browseJobs => isArabic ? 'تصفح الوظائف' : 'Browse Jobs';
  String get findDreamJob => isArabic ? 'ابحث عن\nوظيفة أحلامك' : 'Find Your\nDream Job';
  String get searchCategories => isArabic ? 'ابحث في الفئات...' : 'Search categories...';
  String get allIndustries => isArabic ? 'جميع القطاعات' : 'All Industries';
  String get sectorsCount => isArabic ? 'قطاع' : 'sectors';
  String get jobsCount => isArabic ? 'وظيفة' : 'jobs';
  String get jobSingle => isArabic ? 'وظيفة' : 'job';

  // ── Job Seeker / Listings ─────────────────────────────────────
  String get jobsAvailable => isArabic ? 'وظيفة متاحة' : 'jobs available';
  String get jobAvailableSingle => isArabic ? 'وظيفة متاحة' : 'job available';
  String get filterLabel => isArabic ? 'تصفية' : 'Filter';
  String get searchInLabel => isArabic ? 'ابحث في' : 'Search in';
  String get noJobsYet => isArabic ? 'لا توجد وظائف' : 'No jobs yet';
  String get noJobsPosted => isArabic ? 'لم يتم نشر وظائف في هذا القطاع بعد.' : 'No jobs have been posted in this category yet.';
  String get salaryTag => isArabic ? 'الراتب' : 'SALARY';
  String get viewDetails => isArabic ? 'عرض التفاصيل' : 'View Details';
  String get newLabel => isArabic ? 'جديد' : 'NEW';
  String get postedLabel => isArabic ? 'نُشر' : 'Posted';

  // ── Job Details ───────────────────────────────────────────────
  String get jobDetailsTitle => isArabic ? 'تفاصيل الوظيفة' : 'Job Details';
  String get contactEmployer => isArabic ? 'التواصل مع صاحب العمل' : 'Contact Employer';
  String get postedBy => isArabic ? 'نشر بواسطة' : 'Posted by';
  String get whatsappLabel => isArabic ? 'واتساب' : 'WHATSAPP';
  String get phoneCallLabel => isArabic ? 'اتصال هاتفي' : 'PHONE CALL';
  String get applyNow => isArabic ? 'قدّم الآن' : 'Apply Now';
  String get shareJob => isArabic ? 'مشاركة' : 'Share';
  String get saveJob => isArabic ? 'حفظ' : 'Save';

  // ── Job Creator / My Listings ─────────────────────────────────
  String get myListings => isArabic ? 'قوائمي' : 'My Listings';
  String get totalViews => isArabic ? 'المشاهدات' : 'Total Views';
  String get totalApplicants => isArabic ? 'المتقدمون' : 'Applicants';
  String get activeJobsSection => isArabic ? 'الوظائف النشطة' : 'Active Jobs';
  String get allActive => isArabic ? 'كلها نشطة' : 'All Active';
  String get noJobsPostedYet => isArabic ? 'لم تنشر وظائف بعد' : 'No jobs posted yet';
  String get tapToPostFirstJob => isArabic ? 'اضغط + لنشر وظيفتك الأولى' : 'Tap + to post your first job';
  String get activeStatus => isArabic ? 'نشط' : 'ACTIVE';
  String get viewApplicants => isArabic ? 'عرض المتقدمين' : 'View Applicants';
  String get navJobsPortal => isArabic ? 'الوظائف' : 'Jobs';
  String get navMessages => isArabic ? 'الرسائل' : 'Messages';
  String postedTimeAgo(String ago) => isArabic ? 'نُشر $ago' : 'Posted $ago';
  String activeJobsCount(int count) => isArabic ? 'الوظائف النشطة ($count)' : 'Active Jobs ($count)';

  // ── General ──────────────────────────────────────────────────
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get back => isArabic ? 'رجوع' : 'Back';
  String get next => isArabic ? 'التالي' : 'Next';
  String get done => isArabic ? 'تم' : 'Done';
  String get loading => isArabic ? 'جارٍ التحميل...' : 'Loading...';
  String get error => isArabic ? 'خطأ' : 'Error';
  String get success => isArabic ? 'نجاح' : 'Success';
  String get noInternetConnection =>
      isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
  String get tryAgain => isArabic ? 'حاول مجدداً' : 'Try Again';
  String get unknown => isArabic ? 'غير معروف' : 'Unknown';
  String get naLabel => isArabic ? 'غير متاح' : 'N/A';
}
