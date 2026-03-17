import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  UpdateService({
    required this.androidId,
    required this.iOSId,
    this.useImmediateUpdateOnAndroid = true,
  });

  final String androidId;
  final String iOSId;
  final bool useImmediateUpdateOnAndroid;

  Future<void> checkForUpdates(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        final info = await InAppUpdate.checkForUpdate();

        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          if (useImmediateUpdateOnAndroid &&
              info.immediateUpdateAllowed == true) {
            // Use Play Store's native immediate update flow
            await InAppUpdate.performImmediateUpdate();
            return;
          } else if (info.flexibleUpdateAllowed == true) {
            await InAppUpdate.startFlexibleUpdate();
            await InAppUpdate.completeFlexibleUpdate();
            return;
          } else {
            // Fallback: open Play Store page manually
            await _openStore(androidId: androidId);
            return;
          }
        }
      }

      final newVersion = NewVersionPlus(
        iOSId: iOSId,
        androidId: androidId,
      );

      final status = await newVersion.getVersionStatus();
      if (status != null && status.canUpdate) {
        await _openStore(androidId: androidId, iosId: iOSId);
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  Future<void> _openStore({String? androidId, String? iosId}) async {
    String url = '';

    if (Platform.isAndroid && androidId != null) {
      url = 'https://play.google.com/store/apps/details?id=$androidId';
    } else if (Platform.isIOS && iosId != null) {
      // Use the App Store lookup pattern (replace with your real App Store ID)
      url = 'https://apps.apple.com/app/id$iosId';
    }

    if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else if (url.isNotEmpty) {
      debugPrint('Could not launch store URL: $url');
    }
  }
  // test commit 
}
