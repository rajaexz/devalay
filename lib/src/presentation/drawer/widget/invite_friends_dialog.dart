import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteFriendsDialog extends StatelessWidget {
  const InviteFriendsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const InviteFriendsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const shareLink = 'https://devalay.org/';
    const shareMessage = 'Hey! Check out this amazing app: $shareLink';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 27.w),
      child: Container(
        padding: EdgeInsets.only(
          left: 27.w,
          right: 27.w,
          top: 26.h,
          bottom: 44.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xFFD9D9D9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 11.h,
              right: 11.w,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: const Color(0xFF14191E),
                  ),
                ),
              ),
            ),
            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Share with Friends',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF14191E),
                    letterSpacing: 1,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(20.h),
                // Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite friends to walk the path of devotion.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF14191E),
                        height: 1.4,
                      ),
                    ),
                    Gap(6.h),
                    Text(
                      'One share, many blessing.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF14191E),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                Gap(20.h),
                // Share link section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share you link',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF14191E),
                        height: 1.4,
                      ),
                    ),
                    Gap(12.h),
                    // Link container with copy button
                    Container(
                      height: 30.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 17.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDADADA).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFFDADADA),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              shareLink,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF241601),
                                height: 1.4,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Gap(16.w),
                          GestureDetector(
                            onTap: () => _copyToClipboard(context, shareLink),
                            child: Container(
                              width: 16.w,
                              height: 16.h,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.copy_outlined,
                                size: 16.sp,
                                color: const Color(0xFF241601),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(20.h),
                // Share to section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share to',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF14191E),
                        height: 1.4,
                      ),
                    ),
                    Gap(12.h),
                    // Social media icons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSocialIcon(
                          context,
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: const Color(0xFF1877F2),
                          onTap: () => _shareToFacebook(context, shareMessage),
                        ),
                        _buildSocialIcon(
                          context,
                          icon: Icons.send,
                          label: 'Telegram',
                          color: const Color(0xFF0088CC),
                          onTap: () => _shareToTelegram(context, shareMessage),
                        ),
                        _buildSocialIcon(
                          context,
                          icon: Icons.chat,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () => _shareToWhatsApp(context, shareMessage),
                        ),
                        _buildSocialIcon(
                          context,
                          icon: Icons.close,
                          label: 'X',
                          color: const Color(0xFF000000),
                          onTap: () => _shareToTwitter(context, shareMessage),
                        ),
                        _buildSocialIcon(
                          context,
                          icon: Icons.work,
                          label: 'LinkedIn',
                          color: const Color(0xFF0077B5),
                          onTap: () => _shareToLinkedIn(context, shareMessage),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 31.6.w,
            height: 31.6.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          Gap(8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.24.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              letterSpacing: 0.0924,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _shareToFacebook(BuildContext context, String message) async {
    try {
      final encodedMessage = Uri.encodeComponent(message);
      final url = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=$encodedMessage');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await Share.share(message);
      }
    } catch (e) {
      await Share.share(message);
    }
  }

  Future<void> _shareToTelegram(BuildContext context, String message) async {
    try {
      final encodedMessage = Uri.encodeComponent(message);
      final url = Uri.parse('https://t.me/share/url?url=$encodedMessage');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await Share.share(message);
      }
    } catch (e) {
      await Share.share(message);
    }
  }

  Future<void> _shareToWhatsApp(BuildContext context, String message) async {
    try {
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = Uri.parse('whatsapp://send?text=$encodedMessage');
      
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        // Fallback to web WhatsApp
        final webUrl = Uri.parse('https://wa.me/?text=$encodedMessage');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          await Share.share(message);
        }
      }
    } catch (e) {
      await Share.share(message);
    }
  }

  Future<void> _shareToTwitter(BuildContext context, String message) async {
    try {
      final encodedMessage = Uri.encodeComponent(message);
      final url = Uri.parse('https://twitter.com/intent/tweet?text=$encodedMessage');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await Share.share(message);
      }
    } catch (e) {
      await Share.share(message);
    }
  }

  Future<void> _shareToLinkedIn(BuildContext context, String message) async {
    try {
      final encodedMessage = Uri.encodeComponent(message);
      final url = Uri.parse('https://www.linkedin.com/sharing/share-offsite/?url=$encodedMessage');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await Share.share(message);
      }
    } catch (e) {
      await Share.share(message);
    }
  }
}

