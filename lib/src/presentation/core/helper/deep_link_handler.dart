import 'package:app_links/app_links.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:flutter/material.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();

  Future<void> initAppLinks() async {
    try {
      // Get initial app link (cold start)
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 Initial app link: $initialUri');
        handleAppLink(initialUri);
      }
    } catch (e) {
      debugPrint('❌ Error getting initial app link: $e');
    }

    // Listen for app links while app is running (warm start)
    _appLinks.uriLinkStream.listen((uri) {
      debugPrint('🔗 App link received while running: $uri');
      handleAppLink(uri);
    }, onError: (error) {
      debugPrint('❌ App link stream error: $error');
    });
  }

  Future<void> handleAppLink(Uri uri) async {
    debugPrint('📍 Handling deep link: $uri');
    debugPrint('   Scheme: ${uri.scheme}');
    debugPrint('   Host: ${uri.host}');
    debugPrint('   Path: ${uri.path}');
    debugPrint('   Segments: ${uri.pathSegments}');

    List<String> segments = List.from(uri.pathSegments);
    
    // Handle empty path
    if (segments.isEmpty) {
      debugPrint('⚠️ Empty path, routing to home');
      AppRouter.go(RouterConstant.feedHome);
      return;
    }

    // Remove /api/ or /apis/ prefix if present
    if (segments.isNotEmpty && (segments[0] == 'api' || segments[0] == 'apis')) {
      debugPrint('   Removing prefix: ${segments[0]}');
      segments = segments.sublist(1);
    }
    
    // Check if we still have segments after removing prefix
    if (segments.isEmpty) {
      debugPrint('⚠️ No segments after prefix removal, routing to home');
      AppRouter.go(RouterConstant.feedHome);
      return;
    }
    
    final String pathType = segments[0];
    String? id;
    
    // Extract ID from second segment
    if (segments.length > 1) {
      id = _extractId(segments[1]);
      debugPrint('   Path type: $pathType');
      debugPrint('   Extracted ID: $id');
    } else {
      debugPrint('   Path type: $pathType (no ID)');
    }

    // Check authentication
    bool requiresAuth = _isAuthRequiredPath(pathType);
    if (requiresAuth) {
      final String? isLoggedIn = await PrefManager.getUserSessionId();
      if (isLoggedIn == null) {
        debugPrint('🔒 Auth required but user not logged in. Redirecting to login.');
        AppRouter.go(RouterConstant.loginScreen);
        return;
      }
    }

    // Route to destination
    if (id != null && id.isNotEmpty) {
      _routeToDestination(pathType, id);
    } else {
      _routeToPathWithoutId(pathType);
    }
  }

  /// Extract ID from segment
  /// Handles various formats:
  /// - Pure number: "123" -> "123"
  /// - With wildcard: "123*some-slug" -> "123"
  /// - With slug: "123-temple-name" -> "123"
  String _extractId(String segment) {
    // Pure numeric ID
    if (RegExp(r'^\d+$').hasMatch(segment)) {
      return segment;
    }
    
    // Handle wildcard format: 123*something
    if (segment.contains('*')) {
      final id = segment.split('*').first;
      if (RegExp(r'^\d+$').hasMatch(id)) {
        return id;
      }
    }
    
    // Handle slug format: 123-temple-name
    if (segment.contains('-')) {
      final parts = segment.split('-');
      if (parts.isNotEmpty && RegExp(r'^\d+$').hasMatch(parts[0])) {
        return parts[0];
      }
    }
    
    // Return as-is if no pattern matches
    return segment;
  }

  /// Check if path requires authentication
  bool _isAuthRequiredPath(String pathType) {
    const authRequiredPaths = [
      'Devalay',
      'Puja',
      'Gods',
      'Dev',
      'Post',
      'Devotees',
      'Festivals',
      'Festivel', // Handle typo in API
      'Event',
    ];
    return authRequiredPaths.contains(pathType);
  }

  /// Route to specific destination with ID
  void _routeToDestination(String pathType, String id) {
    debugPrint('✅ Routing to $pathType with ID: $id');

    switch (pathType) {
      case 'Devalay':
        AppRouter.go('/singleDevalay/$id');
        break;
        
      case 'Post':
        AppRouter.go('${RouterConstant.feedDetail}/$id');
        break;
        
      case 'Puja':
        AppRouter.go('/singlePuja/$id');
        break;
        
      case 'Festivals':
      case 'Festivel': // Handle API typo
        AppRouter.go('/singleFestival/$id');
        break;
        
      case 'Dev':
      case 'Gods':
        AppRouter.go('/singleGod/$id');
        break;
        
      case 'Devotees':
        AppRouter.go('/singleDevotee/$id');
        break;
        
      case 'Event':
        AppRouter.go('/singleEvent/$id');
        break;
        
      default:
        debugPrint('⚠️ Unhandled path type: $pathType, routing to home');
        AppRouter.go(RouterConstant.feedHome);
        break;
    }
  }

  /// Route to path without ID (listing pages)
  void _routeToPathWithoutId(String pathType) {
    debugPrint('✅ Routing to $pathType without ID');
    
    switch (pathType) {
      case 'Devalay':
        // Route to temples listing page if you have one
        AppRouter.go('/temples');
        break;
        
      case 'Post':
        AppRouter.go(RouterConstant.feedHome);
        break;
        
      case 'Puja':
        // Route to puja listing if available
        AppRouter.go(RouterConstant.feedHome);
        break;
        
      case 'Festivals':
      case 'Festivel':
        // Route to festivals listing if available
        AppRouter.go(RouterConstant.feedHome);
        break;
        
      case 'Dev':
      case 'Gods':
        // Route to gods listing if available
        AppRouter.go(RouterConstant.feedHome);
        break;
        
      case 'Event':
        // Route to events listing if available
        AppRouter.go(RouterConstant.feedHome);
        break;
        
      default:
        AppRouter.go(RouterConstant.feedHome);
        break;
    }
  }
}