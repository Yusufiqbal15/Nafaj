class ValidationUtils {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Phone validation (basic)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{7,15}$');
    return phoneRegex.hasMatch(phone);
  }

  // Password validation (min 6 chars, at least 1 number)
  static bool isValidPassword(String password) {
    if (password.length < 6) return false;
    return password.contains(RegExp(r'[0-9]'));
  }

  // Required field
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  // Matching values
  static bool isMatching(String value1, String value2) {
    return value1 == value2;
  }

  // URL validation
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class StringUtils {
  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Truncate text with ellipsis
  static String truncate(
    String text,
    int maxLength, {
    String ellipsis = '...',
  }) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Format phone number (basic)
  static String formatPhoneNumber(String phone) {
    if (phone.length < 7) return phone;
    return '+${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
  }

  // Remove all spaces
  static String removeSpaces(String text) {
    return text.replaceAll(' ', '');
  }

  // Check if string contains only numbers
  static bool isNumeric(String text) {
    return int.tryParse(text) != null;
  }
}

class DateTimeUtils {
  // Format date to readable format
  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Format time
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get time difference (e.g., "2 hours ago")
  static String getTimeDifference(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }
}
