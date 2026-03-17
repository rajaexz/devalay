
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SharingService {
  // Consistent method to create shareable links
   static const String baseUrl = 'https://devalay.org';
static Future<void> shareContent({
    required String contentType,
    required String id,
    BuildContext? context,
  }) async {
    try {
      // Normalize the content type to match API expectations
      final String normalizedType = _normalizeContentType(contentType);
      
      // Create the shareable URL following your API pattern
      final String url = '$baseUrl/api/$normalizedType/$id/';
      
      // Get a user-friendly title for the share dialog
      final String shareTitle = _getShareTitle(normalizedType);
      
      // Share the URL
      await Share.share(
        url,
        subject: 'Check out this $shareTitle on Devalay',
      );
      
      debugPrint('Shared URL: $url');
    } catch (e) {
      debugPrint('Error sharing content: $e');
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
   static String _getShareTitle(String normalizedType) {
    switch (normalizedType) {
      case 'Devalay':
        return 'temple';
      case 'Post':
        return 'post';
      case 'Puja':
        return 'puja';
      case 'Festivel':
        return 'festival';
      case 'Dev':
        return 'deity';
      case 'Devotees':
        return 'devotee';
      case 'Event':
        return 'event';
      default:
        return normalizedType.toLowerCase();
    }
  }
  // Helper method to normalize content type
  static String _normalizeContentType(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'event':
      case 'evnet':
        return 'Event';
      case 'festival':
      case 'festivel':
        return 'Festival';
      case 'devalay':
      case 'temple':
        return 'Devalay';
      case 'puja':
        return 'Puja';
      case 'post':
        return 'Post';
      default:
        // Return the original with first letter capitalized
        return contentType.substring(0, 1).toUpperCase() + contentType.substring(1);
    }
  }
}