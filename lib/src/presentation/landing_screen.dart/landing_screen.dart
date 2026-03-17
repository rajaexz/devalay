import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/guestpop.dart';
import 'package:devalay_app/src/presentation/dashboard/dashboard_screen.dart';
import 'package:devalay_app/src/presentation/devalay/devalay_screen.dart';
import 'package:devalay_app/src/presentation/explore_search/explore_search_screen.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/feed_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';

import '../kriti/service_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int currentPageIndex = 0;
  String? userName;
  String? userId;
  bool isLoading = true;
  late bool isGuest;
  final GlobalKey<State<InstagramGalleryPicker>> _galleryKey = GlobalKey<State<InstagramGalleryPicker>>();
  @override
  void initState() {
    super.initState();
    getGuest();
    loadUserImage();
  }

  void getGuest() async {
    isGuest = await PrefManager.getIsGuest();
  }

  Future<void> loadUserImage() async {
    userId = await PrefManager.getUserDevalayId();
    userName = await PrefManager.getUserName();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> checkPermissionAndLoadMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (ps.isAuth) {
    
    
    } else if (ps.hasAccess) {
      // Limited access
      print('Limited access');
    } else {
      // Permission denied, show dialog
      _showPermissionDialog(context);
    }
  }

  void _showPermissionDialog(
    BuildContext context, {
    Future<void> Function()? onRetry,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'To view your photos and videos you can choose:\n\n'
            '• Select photos (Limited) – allow access to selected photos only\n'
            '• Allow all photos (Full) – allow access to entire library\n\n'
            'When the system dialog appears, pick the option you prefer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                PhotoManager.openSetting().then((_) {
                  checkPermissionAndLoadMedia();
                });
              },
              child: const Text('Open Settings'),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'When prompted, choose "Select Photos" for limited access or "Allow" for full access.',
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  onRetry();
                },
                child: const Text('Select photos (Limited)'),
              ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(StringConstant.cancel),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CustomLottieLoader()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          const DevalayScreen(),
          const ExploreSearchScreen(),
          isGuest == true
              ? const GuestPopScreen()
              : InstagramGalleryPicker(
                  key: _galleryKey,
                  autoCheckPermission:
                      false, // Disable auto permission check on landing page
                ),
          const ServiceScreen(),
          isGuest == true ? const GuestPopScreen() : const DashboardScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : AppColor.whiteColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0.0,
        currentIndex: currentPageIndex,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey
            : Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) async {
          // Gallery tab (index 2): check permission first; show dialog only if not granted
          if (index == 2 && !isGuest) {
            final PermissionState ps =
                await PhotoManager.requestPermissionExtend();
            if (ps.isAuth || ps.hasAccess) {
              // Permission already granted – switch to gallery and load media without showing permission UI
              setState(() => currentPageIndex = 2);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final state = _galleryKey.currentState;
                if (state != null) {
                  try {
                    (state as dynamic).loadMediaWithPermissionAlreadyGranted(ps);
                  } catch (_) {}
                }
              });
            } else {
              // Permission not granted – show dialog with retry/settings
              Future<void> requestAndSwitch() async {
                final PermissionState ps2 =
                    await PhotoManager.requestPermissionExtend();
                if (!mounted) return;
                if (ps2.isAuth || ps2.hasAccess) {
                  setState(() => currentPageIndex = 2);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final state = _galleryKey.currentState;
                    if (state != null) {
                      try {
                        (state as dynamic).triggerPermissionCheck();
                      } catch (_) {}
                    }
                  });
                }
              }
              _showPermissionDialog(context, onRetry: requestAndSwitch);
            }
          } else {
            setState(() {
              currentPageIndex = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/Frame 1171277248.svg',
              height: 24.h,
              width: 24.w,
            ),
            activeIcon: SvgPicture.asset(
              'assets/icon/Icon (1).svg',
              height: 24.h,
              width: 24.w,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/Frame.svg',
              height: 24.h,
              width: 24.w,
            ),
            activeIcon: SvgPicture.asset(
              'assets/icon/Frame (1).svg',
              height: 24.h,
              width: 24.w,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/Group 7050.svg',
              height: 24.h,
              width: 24.w,
            ),
            activeIcon: SvgPicture.asset(
              'assets/icon/Contribute fill.svg',
              height: 24.h,
              width: 24.w,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/service.svg',
              height: 24.h,
              width: 24.w,
            ),
            activeIcon: SvgPicture.asset(
              'assets/icon/service_fill.svg',
              height: 24.h,
              width: 24.w,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icon/dashboard.svg',
              height: 24.h,
              width: 24.w,
            ),
            activeIcon: SvgPicture.asset(
              'assets/icon/Untitled-2 [Recovered] 3.svg',
              height: 24.h,
              width: 24.w,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
  