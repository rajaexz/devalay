import 'package:intl/intl.dart';

class HelperClass {
  String slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  String formatDate(String dateString) {
    final DateTime parsedDate = DateTime.parse(dateString);
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(parsedDate);
  }

  String getImageName(String url) {
    return Uri.parse(url).pathSegments.last;
  }

static String formatDate2(DateTime? date) {
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}


static String formatTime(String? time) {
  if (time == null || time.isEmpty) return '';
  
  // Parse the time string (assuming format like "09:48:00")
  try {
    final timeParts = time.split(':');
    if (timeParts.length >= 2) {
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      
      // Convert to 12-hour format
      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      
      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    }
  } catch (e) {
    print('Error parsing time: $e');
  }
  
  return time;
}
  

  static String countForAll(int count) {     
    if (count > 1000) {
      return "${(count / 1000).toStringAsFixed(1)}k";
    }
    return count.toString();
  }

static String timeAgo(String dateTimeString) {
  DateTime postedDate = DateTime.tryParse(dateTimeString)?.toLocal() ?? DateTime.now();
  DateTime now = DateTime.now();
  Duration difference = now.difference(postedDate);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d';
  } else {
    // If more than 1 month ago, show as: "May 10" or "May 10, 2024" if not the same year
    if (postedDate.year == now.year) {
      return DateFormat('MMM d').format(postedDate); // e.g., "May 10"
    } else {
      return DateFormat('MMM d, yyyy').format(postedDate); // e.g., "May 10, 2024"
    }
  }
}


  bool hasValidationErrors(Map response) {
    // Check for your API's specific error indicators (customize this)
    return response.containsKey('city') ||
        response.containsKey('country') ||
        response.containsKey('email') ||
        response.containsKey('gender') ||
        response.containsKey('phone');
  }

  String formatValidationErrors(Map<String, dynamic> errors) {
    final messages = <String>[];

    errors.forEach((field, value) {
      messages.add('$field: $value');
    });

    return messages.join('\n');
  }


     static String getCount(int count) {
    return formatCountCompact(count);
  }

  /// Formats numbers into compact human-readable strings using Indian-style units.
  ///
  /// Rules:
  /// - < 1,000: plain number (e.g., 999)
  /// - 1,000 – < 1,00,000: K (thousand) (e.g., 1.2K)
  /// - 1,00,000 – < 1,00,00,000: L (lakh) (e.g., 2.5L)
  /// - ≥ 1,00,00,000: M (million) and B (billion) for larger numbers
  static String formatCountCompact(int count) {
    if (count < 1000) {
      return count.toString();
    }

    if (count < 100000) { // < 1 lakh
      final value = count / 1000.0;
      return '${_trimTrailingZeros(value)}K';
    }

    if (count < 10000000) { // < 1 crore
      final value = count / 100000.0;
      return '${_trimTrailingZeros(value)}L';
    }

    if (count < 1000000000) { // < 1 billion
      final value = count / 1000000.0; // represent as millions
      return '${_trimTrailingZeros(value)}M';
    }

    // 1 billion and above
    final value = count / 1000000000.0;
    return '${_trimTrailingZeros(value)}B';
  }

  static String _trimTrailingZeros(double value) {
    final str = value.toStringAsFixed(1);
    return str.endsWith('.0') ? str.substring(0, str.length - 2) : str;
  }


  // i want counter to count 1 - 1000 use 1K , 1000-100000lac , 1m
}

String slugify(String str) {
  return str
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
      .replaceAll(
          RegExp(r'[^\w\-]'), '') // Remove non-word characters except hyphens
      .replaceAll(RegExp(r'\-+'), '-') // Replace multiple hyphens with single
      .replaceAll(RegExp(r'^-+'), '') // Remove leading hyphens
      .replaceAll(RegExp(r'-+$'), ''); // Remove trailing hyphens
}





