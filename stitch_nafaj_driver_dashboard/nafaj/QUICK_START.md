# Nafaj - Quick Start Guide

## 🚀 Quick Start (5 minutes)

### 1. Navigate to Project
```bash
cd nafaj
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Run App
```bash
flutter run
```

## 🎨 Using the Design System

### Import Widgets
```dart
// All custom widgets
import 'package:nafaj/widgets/index.dart';

// Or individual imports
import 'package:nafaj/widgets/custom_button.dart';
import 'package:nafaj/widgets/custom_input.dart';
import 'package:nafaj/widgets/custom_card.dart';
```

### Common Patterns

#### Button Examples
```dart
// Primary Button
CustomButton(
  label: 'Sign In',
  onPressed: handleLogin,
)

// With Loading State
CustomButton(
  label: 'Submit',
  onPressed: handleSubmit,
  isLoading: isLoading,
)

// Disabled Button
CustomButton(
  label: 'Disabled',
  isEnabled: false,
  onPressed: () {},
)

// Outline Button
CustomOutlineButton(
  label: 'Cancel',
  onPressed: handleCancel,
)
```

#### Input Examples
```dart
// Basic Input
CustomInput(
  label: 'Full Name',
  hintText: 'Enter your name',
  prefixIcon: Icons.person,
)

// Email Input
CustomInput(
  label: 'Email',
  hintText: 'example@mail.com',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
  validator: (value) {
    if (!ValidationUtils.isValidEmail(value ?? '')) {
      return 'Invalid email';
    }
    return null;
  },
)

// Password Input
CustomInput(
  label: 'Password',
  hintText: 'Enter password',
  obscureText: true,
  prefixIcon: Icons.lock,
  suffixIcon: Icons.visibility,
)

// Phone Input
CustomPhoneInput(
  label: 'Phone',
  countryCode: '+249',
  controller: phoneController,
  validator: (value) {
    if (!ValidationUtils.isValidPhoneNumber(value ?? '')) {
      return 'Invalid phone';
    }
    return null;
  },
)
```

#### Card Examples
```dart
// Basic Card
CustomCard(
  child: Column(
    children: [
      Text('Card Title'),
      SizedBox(height: 8),
      Text('Card Content'),
    ],
  ),
)

// Card with Image
CustomCardWithImage(
  imageUrl: 'https://example.com/image.jpg',
  child: Text(
    'Title',
    style: TextStyle(color: Colors.white),
  ),
)

// Tappable Card
CustomCard(
  onTap: () => handleCardTap(),
  child: Text('Tap me'),
)
```

#### App Bar Example
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBar(
      title: 'Home',
      showBackButton: false,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {},
        ),
      ],
    ),
    body: // your content
  );
}
```

#### Section Header
```dart
SectionHeader(
  title: 'Popular Jobs',
  actionLabel: 'See All',
  onActionPressed: () => Navigator.push(...),
)
```

#### Empty State
```dart
EmptyState(
  icon: Icons.inbox,
  title: 'No Messages',
  subtitle: 'You don\'t have any messages yet',
  actionLabel: 'Go Back',
  onActionPressed: () => Navigator.pop(context),
)
```

#### Loading Indicator
```dart
LoadingIndicator(
  message: 'Loading jobs...',
)
```

## 🔍 Validation Utilities

```dart
import 'package:nafaj/utils/validators.dart';

// Email validation
bool isValidEmail = ValidationUtils.isValidEmail('user@example.com');

// Phone validation
bool isValidPhone = ValidationUtils.isValidPhoneNumber('123456789');

// Password validation (min 6 chars, needs number)
bool isValidPassword = ValidationUtils.isValidPassword('pass123');

// String utilities
String capitalized = StringUtils.capitalize('hello');      // "Hello"
String truncated = StringUtils.truncate('Hello World', 8); // "Hello Wo..."
String formatted = StringUtils.formatCurrency(99.99);      // "$99.99"
String phone = StringUtils.formatPhoneNumber('123456789'); // "+12 345 6789"

// Date utilities
String dateStr = DateTimeUtils.formatDate(DateTime.now());
String timeStr = DateTimeUtils.formatTime(DateTime.now());
String timeDiff = DateTimeUtils.getTimeDifference(DateTime.now().subtract(
  Duration(hours: 2),
)); // "2h ago"
```

## 📱 Screen Navigation

### Navigate to a Screen
```dart
Navigator.pushNamed(context, '/nafaj_marketplace_home');

// Navigate and replace
Navigator.pushReplacementNamed(context, '/driver_login');

// Navigate with arguments
Navigator.pushNamed(
  context,
  '/job_details_contact_info',
  arguments: jobId,
);
```

### Available Routes
- `/nafaj_splash_screen_blinkit_style` - Splash
- `/nafaj_phone_login_screen` - Phone Login
- `/driver_login` - Driver Login
- `/driver_sign_up` - Driver Sign Up
- `/nafaj_marketplace_home` - Marketplace Home
- `/nafaj_wallet_transactions` - Wallet
- And 20+ more screens

## 🎨 Theme System

### Access Theme Colors
```dart
import 'package:nafaj/theme/app_theme.dart';

Container(
  color: AppTheme.primaryColor,      // Orange
  child: Text('Primary Color'),
)

Container(
  color: AppTheme.successColor,      // Green
  child: Text('Success Color'),
)

Text(
  'Error',
  style: TextStyle(
    color: AppTheme.errorColor,      // Red
  ),
)
```

### Use Text Styles
```dart
Text(
  'Large Headline',
  style: Theme.of(context).textTheme.displayLarge,
)

Text(
  'Body Text',
  style: Theme.of(context).textTheme.bodyMedium,
)

Text(
  'Small Label',
  style: Theme.of(context).textTheme.labelSmall,
)
```

## 🛠️ Development Tips

### 1. Hot Reload
```bash
# Automatically reload on file changes
flutter run

# In the terminal during run, press 'r' to hot reload
# Press 'R' for full restart
```

### 2. Check Errors
```bash
# Analyze code
flutter analyze

# Check outdated packages
flutter pub outdated
```

### 3. Get New Dependencies
```bash
# After updating pubspec.yaml
flutter pub get
```

### 4. Test Different Devices
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

## 📝 Common Issues & Fixes

### Issue: Dependencies not updating
**Solution**: 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Build fails on Windows
**Solution**: Ensure Developer Mode is enabled:
1. Settings > System > About > Advanced system settings
2. Developer Mode > ON

### Issue: Hot reload not working
**Solution**: Use full restart:
- Press 'R' in terminal (not 'r')

## 🎯 Project Structure

```
lib/
├── main.dart                 # App entry
├── constants.dart           # Constants & strings
├── routes/app_routes.dart   # Navigation
├── screens/                 # Screens
├── theme/app_theme.dart     # Design system
├── widgets/                 # Components
└── utils/validators.dart    # Utilities
```

## 🤝 Best Practices

1. **Always use custom components** instead of raw Flutter widgets
2. **Use theme colors** from `AppTheme` class
3. **Use text styles** from theme instead of custom styles
4. **Validate forms** using `ValidationUtils`
5. **Log errors** properly for debugging
6. **Use constants** from `constants.dart`

## 💡 Example Screen Template

```dart
import 'package:flutter/material.dart';
import 'package:nafaj/theme/app_theme.dart';
import 'package:nafaj/widgets/index.dart';
import 'package:nafaj/constants.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Example',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Form Section',
            ),
            SizedBox(height: AppConstants.paddingMedium),
            CustomInput(
              label: 'Input Label',
              hintText: 'Enter text',
              controller: _controller,
            ),
            SizedBox(height: AppConstants.paddingLarge),
            CustomButton(
              label: AppStrings.submit,
              onPressed: () => print('Submitted'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📞 Need Help?

Check the complete documentation in `SETUP_GUIDE.md`

---

**Happy Coding! 🚀**
