# Nafaj Flutter Driver Dashboard

## Project Description
**Nafaj** is a digital platform connecting neighbors and service providers. The name translates to "The Digital Bridge," embodying the mission to connect communities efficiently.

## 🎯 Recent Enhancements

### 1. **Enhanced Theme System**
- **Professional Color Palette**:
  - Primary: Burnt Orange (#CC5500)
  - Extended color semantics (success, error, warning, info)
  - Consistent neutral colors for background and text
  
- **Comprehensive Typography**:
  - Google Fonts integration (Outfit font family)
  - Complete text style hierarchy (display, headline, title, body, label)
  - Consistent letter spacing and weight configurations

- **Dark Theme Support**: Implemented complete dark theme implementation

### 2. **Reusable UI Components Library**
Created a comprehensive set of custom widgets for design consistency:

#### Custom Components:
- **CustomAppBar**: Professional app bar with back button and actions
- **CustomCard**: Flexible card component with borders and shadows
- **CustomCardWithImage**: Card with background image and gradient overlay
- **CustomButton**: Primary button with loading state support
- **CustomOutlineButton**: Outline-style button for secondary actions
- **CustomIconButton**: Circular icon button with styling
- **CustomInput**: Advanced text input with validation support
- **CustomPhoneInput**: Phone number input with country code prefix
- **SectionHeader**: Reusable section headers with action buttons
- **EmptyState**: Standardized empty state UI
- **LoadingIndicator**: Consistent loading indicator
- **AnimatedCounter**: Number counter with animations

### 3. **Animated Splash Screen**
- **Fade & Scale Animations**: Logo animates in with fade and scale effects
- **Enhanced Visual Hierarchy**: Better presentation with shadow effects
- **Loading Indicator**: Shows progress during splash duration
- **Improved UX**: Smoother transition with 3-second splash duration

### 4. **Project Organization**

#### Directory Structure:
```
lib/
├── main.dart                 # App entry point
├── constants.dart            # App constants and strings
├── routes/
│   └── app_routes.dart      # Navigation routes
├── screens/                  # Feature screens
├── theme/
│   └── app_theme.dart       # Centralized theme configuration
├── widgets/                  # Reusable UI components
│   ├── index.dart           # Widget exports
│   ├── custom_app_bar.dart
│   ├── custom_button.dart
│   ├── custom_card.dart
│   ├── custom_input.dart
│   ├── custom_widgets.dart
│   └── nafaj_bottom_nav.dart
└── utils/
    └── validators.dart      # Utility functions
```

### 5. **Utility Packages**
- **ValidationUtils**:
  - Email validation
  - Phone number validation
  - Password strength validation
  - URL validation

- **StringUtils**:
  - Text capitalization
  - Text truncation with ellipsis
  - Currency formatting
  - Phone number formatting

- **DateTimeUtils**:
  - Date formatting
  - Time formatting
  - Relative time display (e.g., "2 hours ago")

### 6. **Updated Dependencies**
Added professional packages:
- **provider**: State management
- **http**: HTTP client for API calls
- **shared_preferences**: Local storage
- **intl**: Date/time and number formatting
- **json_annotation & json_serializable**: JSON serialization
- **build_runner**: Code generation support

### 7. **Constants System**
- **AppConstants**: Spacing, border radius, durations, font sizes, icon sizes
- **AppStrings**: Centralized string resources for easy localization

## 🚀 Getting Started

### Prerequisites
- Flutter 3.11.1 or higher
- Dart 3.11.1 or higher

### Installation

1. **Clone the project** (if applicable):
```bash
cd stitch_nafaj_driver_dashboard/nafaj
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run the app**:
```bash
flutter run
```

### Building for Different Platforms

#### Android:
```bash
flutter build apk
flutter build appbundle  # For Play Store
```

#### iOS:
```bash
flutter build ios
```

#### Web:
```bash
flutter build web
```

#### Windows:
```bash
flutter build windows
```

## 📁 Project Structure

### Routes
All navigation routes are centralized in `lib/routes/app_routes.dart`:
- `/nafaj_splash_screen_blinkit_style` - Splash screen (initial)
- `/nafaj_phone_login_screen` - Phone login
- `/nafaj_otp_verification_screen` - OTP verification
- `/driver_login` - Driver login
- `/driver_sign_up` - Driver registration
- `/nafaj_marketplace_home` - Home marketplace
- And 20+ other screens

## 🎨 Design System

### Colors
```dart
primaryColor      = #CC5500  (Burnt Orange)
primaryLight      = #FF9500  (Light Orange)
primaryDark       = #993300  (Dark Orange)
textPrimary       = #1A1A1A  (Dark Gray)
textSecondary     = #666666  (Medium Gray)
borderColor       = #E0E0E0  (Light Gray)
successColor      = #4CAF50  (Green)
errorColor        = #E74C3C  (Red)
warningColor      = #FFA500  (Orange)
infoColor         = #2196F3  (Blue)
```

### Typography
- **Font Family**: Google Fonts - Outfit
- **Display Large**: 56px, Weight 800
- **Headline Large**: 32px, Weight 700
- **Body Large**: 16px, Weight 400
- **Body Medium**: 14px, Weight 400

### Spacing System
```dart
paddingSmall      = 8px
paddingMedium     = 16px
paddingLarge      = 24px
paddingXLarge     = 32px
```

### Border Radius
```dart
borderRadiusSmall    = 8px
borderRadiusMedium   = 12px
borderRadiusLarge    = 16px
borderRadiusXLarge   = 24px
```

## 📦 Code Quality

### Analysis Status ✅
- Project compiles without errors
- Lint warnings for `withOpacity()` deprecation (existing code)
- All new code follows Dart best practices
- Implements Material Design 3 guidelines

## 🔧 Development Guidelines

### Adding New Screens
1. Create a new file in `lib/screens/`
2. Extend `StatelessWidget` or `StatefulWidget`
3. Register route in `AppRoutes`
4. Use custom components from `lib/widgets/`

### Using Custom Components
```dart
import 'package:nafaj/widgets/index.dart';

CustomButton(
  label: 'Submit',
  onPressed: () => print('Pressed'),
)

CustomInput(
  label: 'Email',
  hintText: 'Enter your email',
  prefixIcon: Icons.email,
)

CustomCard(
  child: Text('Card content'),
  borderRadius: 12,
)
```

### Validation Examples
```dart
import 'package:nafaj/utils/validators.dart';

// Validate email
if (ValidationUtils.isValidEmail(email)) {
  // Valid email
}

// Format phone number
String formatted = StringUtils.formatPhoneNumber(phone);

// Get time difference
String diff = DateTimeUtils.getTimeDifference(dateTime);
```

## 🎯 Next Steps

1. **State Management**: Implement Provider pattern for API calls
2. **API Integration**: Connect to backend services
3. **Local Storage**: Use SharedPreferences for user preferences
4. **Error Handling**: Implement centralized error handling
5. **Testing**: Add unit and widget tests
6. **Localization**: Add multi-language support using intl package

## 📝 Version

- **Current Version**: 1.0.0+1
- **Environment**: SDK >=3.11.1
- **Last Updated**: 2026-03-19

## 🤝 Contributing

When contributing to this project:
1. Use the custom components already defined
2. Follow the established color and typography system
3. Maintain the project structure
4. Test changes across different screen sizes

## 📞 Support

For issues or questions, please refer to the project documentation or contact the development team.

---

**Status**: ✅ Project Ready for Development
