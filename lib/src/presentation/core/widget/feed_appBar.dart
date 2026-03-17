import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/notification/web_socket/web_socket.dart';
import 'package:devalay_app/src/presentation/profile/profile_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../application/feed/notification/notification_cubit.dart';

class CustomAppBar extends StatefulWidget {
  final String brandName;

  const CustomAppBar({
    super.key,
    required this.brandName,
  }
);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final NotificationSocketService _socketService = NotificationSocketService();
  late NotificationCubit _notificationCubit;
  String? userName;
  String? userId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Load user data first
    userId = await PrefManager.getUserDevalayId();
    userName = await PrefManager.getUserName();
    
    if (mounted) {
      setState(() {});
    }
    
    // Initialize notification system
    _notificationCubit = context.read<NotificationCubit>();
    await _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    // Load saved count first for immediate display
    await _socketService.loadNotificationCount();
    
    // Connect to WebSocket
    _socketService.connectWithCookie();
    _notificationCubit.connectToSocketWithSession();
    
    // Fetch fresh notification count from API
    _fetchUnreadCount();
  }
  
  /// Fetch actual unread count from API to sync badge
  Future<void> _fetchUnreadCount() async {
    try {
      // Trigger a notification fetch which will update the count
      await _notificationCubit.fetchNotification(
        isRead: false,
        isRefresh: true,
        type: 'all',
      );
    } catch (e) {
      debugPrint("❌ Failed to fetch unread count: $e");
    }
  }

  @override
  void dispose() {
    // Clean up socket connection if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Prevent back button space
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColor.blackColor
          : AppColor.lightGrayColor,
      elevation: 0,
      title: Hero(
        tag: "logo",
        child: Image.asset(
          'assets/logo/devalay_logo.png',
          width: 90.w,
          height: 50.h,
        ),
      ),

      actions: [
        ValueListenableBuilder<int>(
          valueListenable: _socketService.notificationCount,
          builder: (context, count, child) {
            final bool hasNotification = count > 0;
            return SizedBox(
              width: 50.w,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      hasNotification
                          ? 'assets/icon/noti_1.svg'
                          : "assets/icon/noti.svg",
                      width: 25.w,
                      height: 25.h,
                      color: hasNotification
                          ? AppColor.appbarBgColor
                          : (Theme.of(context).brightness == Brightness.dark
                              ? AppColor.whiteColor
                              : AppColor.blackColor),
                    ),
                    onPressed: () {
                      // Navigate to notification screen
                      AppRouter.push(RouterConstant.notificationScreen);
                      // Don't mark as read here - let the notification screen handle it
                    },
                  ),
                  // Badge for notification count
                  if (hasNotification)
                    Positioned(
                      right: 8.w,
                      top: 8.h,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.h,
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        // Profile Icon
        IconButton(
          icon: ClipOval(
            child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
              builder: (context, state) {
                final imageUrl = (state is ProfileInfoLoaded &&
                        state.profileInfoModel?.dp != null)
                    ? state.profileInfoModel!.dp
                    : StringConstant.defaultImage;
                    // if i get skill get null set skill status to false
      bool? admin =(state is ProfileInfoLoaded &&
                        state.profileInfoModel?.admin != null)   ? state.profileInfoModel!.admin
                    : false;


       PrefManager.setAdmin(admin.toString());
                   
               
                return CustomCacheImage(
                  imageUrl: imageUrl ?? StringConstant.defaultImage,
                  height: 30.h,
                  isPerson: true,
                  width: 30.h,
                );
              },
            ),
          ),
          onPressed: () {
            if (userId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileMainScreen(
                    id: int.tryParse(userId!) ?? 0,
                    profileType: "profile",
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class SimpleAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String brandName;
  final Color? brandColor;
  final String? calledFrom;
  final bool? centerTitle;
  final VoidCallback? onTap;
  Color? backgroundColor;
  final VoidCallback? onBackTap;
  List<Widget>? actions;

  SimpleAppBar({
    super.key,
    required this.brandName,
    this.calledFrom,
    this.brandColor,
    this.onTap,
    this.actions,
    this.centerTitle,
    this.backgroundColor,
    this.onBackTap,
  });

  @override
  State<SimpleAppBar> createState() => _SimpleAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SimpleAppBarState extends State<SimpleAppBar> {
  late FeedHomeCubit feedHomeCubit;

  @override
  void initState() {
    super.initState();
    feedHomeCubit = context.read<FeedHomeCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor ??
          (Theme.of(context).brightness == Brightness.dark
              ? AppColor.blackColor
              : AppColor.whiteColor),
      elevation: 0,
      leadingWidth: 30.sp,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: widget.brandColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? AppColor.whiteColor
                  : AppColor.blackColor),
        ),
        onPressed: () async {
          widget.onBackTap?.call();

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            AppRouter.go('/landing');
          }
        },
      ),
      centerTitle: widget.centerTitle ?? true,
      title: Text(
        widget.brandName,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
          color: widget.brandColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? AppColor.whiteColor
                  : AppColor.blackColor),
        ),
      ),
      actions: widget.actions ??
          [
            if (widget.calledFrom == 'createPost')
              BlocBuilder<FeedHomeCubit, FeedHomeState>(
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: widget.onTap,
                    isLoading: feedHomeCubit.isPostLoad,
                    text: StringConstant.postNow,
                    toPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    borderRadius: 25.0,
                    elevation: 0.2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5),
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            if (widget.calledFrom == 'commentPost')
              Padding(
                padding: EdgeInsets.only(right: 15.sp),
                child: InkWell(
                  onTap: widget.onTap,
                  child: SvgPicture.asset(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.whiteColor
                        : AppColor.blackColor,
                    'assets/icon/search.svg',
                  ),
                ),
              ),
            if (widget.calledFrom == 'galleryCreatePost')
              Padding(
                padding: EdgeInsets.only(right: 15.sp),
                child: InkWell(
                  onTap: widget.onTap,
                  child: SvgPicture.asset(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.whiteColor
                        : AppColor.blackColor,
                    'assets/icon/camera.svg',
                  ),
                ),
              ),
          ],
    );
  }
}