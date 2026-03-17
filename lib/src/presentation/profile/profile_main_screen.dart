import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart'; // Add this import
import 'package:devalay_app/src/data/model/profile/profile_info_model.dart';
import 'package:devalay_app/src/presentation/core/widget/guestpop.dart';
import 'package:devalay_app/src/presentation/drawer/widget/service_profile/add_skill_screen.dart';
import 'package:devalay_app/src/presentation/drawer/widget/service_profile/view_skill_screen.dart';
import 'package:devalay_app/src/presentation/profile/connections/widget/request_screen.dart';
import 'package:devalay_app/src/presentation/profile/widget/profile_shimer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/helper/image_helper.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/profile/profile_screen/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/router/router_constant.dart';
import '../core/constants/strings.dart';
import 'connections/connections_screen.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'widget/profile_options_menu.dart';

bool isFollowing = false;

class ProfileMainScreen extends StatefulWidget {
  const ProfileMainScreen({super.key, this.id, this.profileType});
  final int? id;
  final String? profileType;

  @override
  State<ProfileMainScreen> createState() => _ProfileMainScreenState();
}

class _ProfileMainScreenState extends State<ProfileMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _showTitle = false;
  File? _profileImageFile;
  File? _backgroundImageFile;
  final _imagePicker = ImagePicker();
  String? userid;
  bool? isGuest;
  bool _isInitializing = true;
  
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;
  Color get themeAwareWhiteBlack =>
      isDarkMode ? AppColor.whiteColor : AppColor.blackColor;

  @override
  void initState() {
    super.initState();
   
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    
    // Initialize user data and profile
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    // First, get the user's own ID
    userid = await PrefManager.getUserDevalayId();
    isGuest = await PrefManager.getIsGuest();
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
    
    // Determine which profile ID to use
    String? profileId;
    
    if (widget.id != null) {
      // Use the passed ID (viewing someone else's profile or own profile via navigation)
      profileId = widget.id.toString();
    } else if (userid != null && userid!.isNotEmpty) {
      // Fallback to current user's ID if widget.id is null
      profileId = userid;
    }
    
    if (profileId != null && profileId.isNotEmpty && profileId != "null") {
      if (mounted) {
        context.read<ProfileInfoCubit>().init(profileId);
      }
    } else {
      debugPrint("ProfileMainScreen: No valid profile ID available");
    }
  }

  void _scrollListener() {
    final shouldShowTitle = _scrollController.offset > 100;
    if (shouldShowTitle != _showTitle) {
      setState(() {
        _showTitle = shouldShowTitle;
      });
    }
  }


  Future<void> _pickImage(ImageSource source, bool isProfileImage) async {
    try {
      // Check and request permission
      final hasPermission = await _checkAndRequestPermission(source);
      
      if (!hasPermission) {
        return;
      }

      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
        maxHeight: 1024,
        maxWidth: 1024,
      );

      if (pickedImage == null) return;

      final aspectRatio = isProfileImage
          ? const CropAspectRatio(ratioX: 1.0, ratioY: 1.0)
          : const CropAspectRatio(ratioX: 5.0, ratioY: 1.0);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: StringConstant.cropImage,
            toolbarColor: AppColor.appbarBgColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
          ),
          IOSUiSettings(
            title: StringConstant.cropImage,
            minimumAspectRatio: 1.0,
          ),
        ],
        aspectRatio: aspectRatio,
      );

      if (croppedFile == null) return;

      setState(() {
        if (isProfileImage) {
          _profileImageFile = File(croppedFile.path);
          context.read<ProfileInfoCubit>().updateProfileImage(_profileImageFile!);
        } else {
          _backgroundImageFile = File(croppedFile.path);
          context
              .read<ProfileInfoCubit>()
              .updateBackgroundImage(_backgroundImageFile!);
        }
      });
    } on PlatformException catch (e) {
      // Handle camera access denied or other platform exceptions
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        _showPermissionDeniedDialog(source);
      } else {
        // Show generic error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.message ?? "Unable to access image"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle any other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

    Future<bool> _checkAndRequestPermission(ImageSource source) async {
    Permission permission;
    
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // For gallery, check Android version
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          permission = Permission.storage;
        } else {
          permission = Permission.photos;
        }
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      
      if (result.isGranted) {
        return true;
      } else if (result.isPermanentlyDenied) {
        _showPermissionDeniedDialog(source);
        return false;
      } else if (result.isDenied) {
        _showPermissionDeniedDialog(source);
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(source);
      return false;
    }

    return false;
  }

  void _showPermissionDeniedDialog(ImageSource source) {
    final permissionName = source == ImageSource.camera ? 'Camera' : 'Gallery';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionName Permission Required'),
          content: Text(
            '$permissionName permission is required to select images. Please enable it from app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

 
  Future<void> _showImagePicker(bool isProfileImage) {
    // Store the value for later use
    
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            child: SizedBox(
              height: 170.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    Icons.camera_alt_outlined,
                    StringConstant.camera,
                    () => _pickImage(ImageSource.camera, isProfileImage),
                  ),
                  _buildImagePickerOption(
                    Icons.photo,
                    StringConstant.gallery,
                    () => _pickImage(ImageSource.gallery, isProfileImage),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption(
      IconData icon, String label, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        onTap();
        
        Navigator.of(context).pop();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30.sp, color: Colors.black),
          SizedBox(height: 5.h),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildCameraButton(VoidCallback onTap,
      {double? height, double? width, bool? isBorder = false}) {
    final double buttonHeight = height ?? 30.h;
    final double buttonWidth = width ?? 30.h;

    return Material(
      color: AppColor.transparentColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(5.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5.r),
        child: Container(
          height: buttonHeight,
          width: buttonWidth,
          decoration: BoxDecoration(
            border: isBorder == true
                ? Border.all(color: AppColor.greyColor, width: 0.8.w)
                : null,
            color: AppColor.lightGrayColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Icon(
            Icons.camera_alt,
            color: AppColor.blackColor.withOpacity(0.5),
            size: buttonHeight * 0.8,
          ),
        ),
      ),
    );
  }

  Future<void> _handleFollowAction(ProfileInfoModel profileItems) async {
    if (userid == null || profileItems.id == null) return;

    final feedHomeCubit = context.read<FeedHomeCubit>();
    final isFollowing = profileItems.followingStatus ?? false;
    final isFollowingRequest = profileItems.followingRequestsStatus ?? false;

    if (isFollowing) {
      await feedHomeCubit.feedPostFollowing(
        followingUserId: profileItems.id!,
        userId: int.parse(userid!),
        isFollowing: false,
        clickedPostIndex: 0,
      );
    } else {
      await feedHomeCubit.feedPostFollowingRequest(
        followingUserId: profileItems.id!,
        userId: int.parse(userid!),
        isFollowing: !isFollowingRequest,
        clickedPostIndex: 0,
      );
    }

    if (context.mounted) {
      context.read<ProfileInfoCubit>().fetchProfileInfoData();
    }
  }

  bool _shouldShowContent(ProfileInfoModel profileItems, bool isProfile) {
    if (isProfile) return true;

    if (!(profileItems.isPrivate ?? false)) return true;

    bool isFollowing = profileItems.followingStatus ?? false;
    return isFollowing;
  }

  bool _shouldShowPrivateMessage(
      ProfileInfoModel profileItems, bool isProfile) {
    if (isProfile) return false;
    bool isPrivateAccount = profileItems.isPrivate ?? false;
    // Check if current user is following this profile
    bool isFollowing = profileItems.followingStatus ?? false;

    return isPrivateAccount && !isFollowing;
  }

  bool _isValidImageUrl(String? url) {
    return url != null && url.trim().isNotEmpty && url.startsWith('http');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  // Show loading while initializing
  if (_isInitializing) {
    return buildProfileShimmer();
  }
  
  // Check if user is guest and show full page popup
  if (isGuest == true) {
    return const GuestPopScreen();
  }
  
  return PopScope(
    canPop: true,
    onPopInvoked: (didPop) {
      if (didPop) {
        context.read<ProfileInfoCubit>().init(userid.toString());
      }
    },
    child: Scaffold(
      body: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
        builder: (context, state) {
          if (state is ProfileInfoLoaded) {
            if (state.loadingState) {
              return buildProfileShimmer();
            }

            if (state.errorMessage.isNotEmpty) {
              return _buildErrorScreen(state.errorMessage);
            }

            final profileItems = state.profileInfoModel;
            final isProfile = widget.profileType == "profile";
    
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<ProfileInfoCubit>().fetchProfileInfoData();
              },
              child: _buildMainScreen(profileItems, isProfile),
            );
          }

          return buildProfileShimmer();
        },
      ),
    ),
  );
} 


 Widget _buildErrorScreen(String errorMessage) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: 
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 60.sp, color: Colors.red.shade300),
            Gap(16.h),
            Text(
              errorMessage,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            Gap(24.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<ProfileInfoCubit>().init(userid.toString()),
              style: ElevatedButton.styleFrom(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.sp, vertical: 12.sp),
                backgroundColor: AppColor.appbarBgColor,
              ),
              child: Text(StringConstant.tryAgain,
                  style:
                      TextStyle(color: AppColor.whiteColor, fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen(ProfileInfoModel? profileItems, bool isProfile) {
    final tabs = [
      Tab(
          text:
              "${HelperClass.getCount(profileItems!.postCount ?? 0)} ${StringConstant.post}"),
      Tab(
          text:
              "${HelperClass.getCount(profileItems.followers!.length)} ${StringConstant.follower} "),
      Tab(
          text:
              '${HelperClass.getCount(profileItems.following!.length)} ${ StringConstant.following}${"s"}'),
    ];

    final screenTabs = [
      ProfileScreen(id: widget.id, prolifeType: widget.profileType),
      RequestScreen(id: widget.id, prolifeType: widget.profileType),
      ConnectionsScreen(id: widget.id!, prolifeType: widget.profileType),
    ];

    // Own profile = profileType is "profile" OR loaded profile ID is current user's ID
    final bool isOwnProfile = isProfile ||
        (userid != null &&
            profileItems.id != null &&
            profileItems.id.toString() == userid);

    final shouldShowContent = _shouldShowContent(profileItems, isProfile);
    final shouldShowPrivateMessage = _shouldShowPrivateMessage(profileItems, isProfile);
    
    // Check if this user has sent a follow request TO the current user
    final hasReceivedFollowRequest = _hasReceivedFollowRequest(profileItems);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
      appBar: _buildAppBar(profileItems),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Follow Request Banner (Figma: at the top, before profile header)
          if (!isOwnProfile && hasReceivedFollowRequest)
            SliverToBoxAdapter(child: _buildFollowRequestBanner(profileItems)),
          _buildSliverAppBar(profileItems, isProfile),
        ],
        body: Column(
          children: [
            // Follow Button – only for other users' profiles, never for own profile
            if (!isOwnProfile) _buildFollowButtons(profileItems),
            
            // Private Account Message (Figma style)
            if (shouldShowPrivateMessage) _buildPrivateAccountMessage(),
            
            // Tabs and Content (only show if allowed)
            // Show tabs only if:
            // 1. Own profile (isProfile = true), OR
            // 2. Not a private account, OR
            // 3. Private account but user is following
            if (shouldShowContent || isProfile) ...[
              _buildTabBar(tabs),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: screenTabs,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Check if the viewed profile has sent a follow request TO the current user
  /// This checks if the current user (userid) is in the viewed profile's followingRequests list
  bool _hasReceivedFollowRequest(ProfileInfoModel? profileItems) {
    if (profileItems == null || userid == null) return false;
    
    final currentUserId = int.tryParse(userid!);
    if (currentUserId == null) return false;
    
    // Check if this profile has pending follow requests to the current user
    // followingRequests = users this profile has REQUESTED to follow
    if (profileItems.followingRequests != null) {
      return profileItems.followingRequests!.any((req) => req.id == currentUserId);
    }
    
    return false;
  }

  /// Follow Request Banner (Figma style) - "X wants to follow you"
  Widget _buildFollowRequestBanner(ProfileInfoModel? profileItems) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Text: "X wants to follow you"
          Text(
            '${profileItems?.name ?? "User"} wants to follow you',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF14191E),
            ),
          ),
          Gap(12.h),
          // Delete/Confirm Buttons Row
          Row(
            children: [
              // Delete Button (White with border)
              Expanded(
                child: SizedBox(
                  height: 35.h,
                  child: OutlinedButton(
                    onPressed: () => _handleRejectFollowRequest(profileItems),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF241601),
                      side: const BorderSide(color: Color(0xFFDADADA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Gap(12.w),
              // Confirm Button (Orange filled)
              Expanded(
                child: SizedBox(
                  height: 35.h,
                  child: ElevatedButton(
                    onPressed: () => _handleAcceptFollowRequest(profileItems),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9500).withOpacity(0.75),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Handle accepting a follow request
  void _handleAcceptFollowRequest(ProfileInfoModel? profileItems) async {
    if (profileItems?.id == null || userid == null) return;
    
    try {
      await context.read<FeedHomeCubit>().feedPostFollowingRequest(
        followingUserId: profileItems!.id!,
        userId: int.parse(userid!),
        isFollowing: true,
        clickedPostIndex: 0,
      );
      
      if (mounted) {
        context.read<ProfileInfoCubit>().fetchProfileInfoData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Follow request accepted'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error accepting follow request: $e');
    }
  }
  
  /// Handle rejecting a follow request
  void _handleRejectFollowRequest(ProfileInfoModel? profileItems) async {
    if (profileItems?.id == null || userid == null) return;
    
    try {
      await context.read<FeedHomeCubit>().feedPostFollowingRequest(
        followingUserId: profileItems!.id!,
        userId: int.parse(userid!),
        isFollowing: false,
        clickedPostIndex: 0,
      );
      
      if (mounted) {
        context.read<ProfileInfoCubit>().fetchProfileInfoData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Follow request deleted'),
            backgroundColor: Colors.grey.shade600,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error rejecting follow request: $e');
    }
  }

  /// Private Account Message (Figma style - simple layout with lock icon)
  Widget _buildPrivateAccountMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lock Icon (Figma: 15x20)
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.lock_outline,
              color: const Color(0xFF14191E),
              size: 20.sp,
            ),
          ),
          Gap(14.w),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title: "This account is private"
                Text(
                  "This account is private",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF14191E),
                    height: 1.4,
                  ),
                ),
                Gap(4.h),
                // Subtitle: "Follow this account to see their post and connections"
                Text(
                  "Follow this account to see their post and connections",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF14191E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileInfoModel? profileItems) {
    // Check if viewing own profile or another user's profile
    final bool isOwnProfile = widget.profileType == "profile" || 
        (userid != null && widget.id?.toString() == userid);
    
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: _showTitle ? 2 : 0,
      leading: InkWell(
        onTap: () {
          if (AppRouter.canPop()) {
            AppRouter.pop();
          } else {
            // Do not Navigator.pop when stack has only this page – go to landing instead
            AppRouter.go(RouterConstant.landingScreen);
          }
        },
        child: Icon(
          Icons.arrow_back,
          color: themeAwareWhiteBlack,
        ),
      ),
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showTitle ? 1.0 : 0.0,
        child: Text(
          profileItems?.name ?? 'User Profile',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18.sp,
                color: themeAwareWhiteBlack,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      actions: [
        if (isOwnProfile) ...[
          // Own profile actions
          InkWell(
            onTap: () async {
              isGuest == true
                  ? showGuestLoginDialog(context)
                  : AppRouter.push(RouterConstant.feedCreate);
            },
            child: SvgPicture.asset(
              "assets/icon/contribution_icon.svg",
              height: 20.h,
              width: 20.w,
              color: const Color(0xff3C3C43),
            ),
          ),
          Gap(12.w),
          InkWell(
            onTap: () {
              isGuest == true
                  ? showGuestLoginDialog(context)
                  : AppRouter.push(RouterConstant.drawer);
            },
            child: Icon(Icons.menu, color: themeAwareWhiteBlack),
          ),
        ] else ...[
          // Other user's profile - show Block/Report menu (Figma style)
          ProfileOptionsMenu(
            iconColor: themeAwareWhiteBlack,
            onBlock: () => _handleBlockUser(profileItems),
            onReport: () => _handleReportUser(profileItems),
          ),
        ],
        Gap(16.w),
      ],
    );
  }

  /// Handle blocking a user
  void _handleBlockUser(ProfileInfoModel? profileItems) async {
    final userName = profileItems?.name ?? 'this user';
    final confirmed = await showBlockConfirmationDialog(context, userName);
    
    if (confirmed == true && mounted) {
      // TODO: Implement block API call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$userName has been blocked'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      Navigator.pop(context);
    }
  }

  /// Handle reporting a user
  void _handleReportUser(ProfileInfoModel? profileItems) async {
    final reason = await showReportOptionsDialog(context);
    
    if (reason != null && mounted) {
      // TODO: Implement report API call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report submitted: $reason'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
    }
  }

  Widget _buildSliverAppBar(ProfileInfoModel? profileItems, bool isProfile) {
    return SliverToBoxAdapter(
      child: _buildProfileHeader(profileItems, isProfile),
    );
  }

  /// Profile Header matching Figma design exactly
  Widget _buildProfileHeader(ProfileInfoModel? profileItems, bool isProfile) {
    return Container(
      color: isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Column content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cover Image Section
              _buildCoverImage(profileItems, isProfile),
              
              // User Info Section (below cover)
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 8.h,
                  bottom: 8.h,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE8E8E8),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Row with Avatar space + Name/Skills
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Space for avatar (avatar is positioned in Stack above)
                        SizedBox(width: 90.w, height: 50.h),
                        
                        // User Info (name + skills) to the right of avatar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(8.h),
                              // User Name
                              Text(
                                profileItems?.name ?? StringConstant.noName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF14191E),
                                ),
                              ),
                              Gap(8.h),
                              
                              // Skills Row
                              _buildSkillsRow(profileItems, isProfile),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    Gap(14.h),
                                 ],
                ),
              ),
            ],
          ),
          
          // Avatar positioned overlapping cover and info section
          Positioned(
            left: 16.w,
            top: 60.h, // Position from top of cover
            child: _buildProfileAvatar(profileItems, isProfile),
          ),
        ],
      ),
    );
  }

  /// Skills row with Add Skill button and skill chips
  Widget _buildSkillsRow(ProfileInfoModel? profileItems, bool isProfile) {
    // Check if this is the current user's own profile by comparing IDs
    // Only allow editing if the current user's ID matches the profile ID
    final bool isOwnProfile = userid != null && 
        profileItems?.id != null && 
        userid.toString() == profileItems!.id.toString();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Add Skill button (only for own profile)
          if (isOwnProfile)
            GestureDetector(
              onTap: () async {
                final isUpdated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSkillScreen(isInside: false),
                  ),
                );

                if (isUpdated == true && mounted) {
                  context.read<ProfileInfoCubit>().fetchProfileInfoData();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 12.w),
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFB1B1B1),
                    width: 0.787,
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  StringConstant.addSkill,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF241601),
                  ),
                ),
              ),
            ),

          // Skill chips
          if (profileItems?.skills != null)
            ...profileItems!.skills!.map((skill) {
              final color = Colors.primaries[
                  profileItems.skills!.indexOf(skill) % Colors.primaries.length];
              
              Widget skillChip = Container(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: color, width: 1.5),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  "${skill.name}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.whiteColor,
                  ),
                ),
              );
              
              // Wrap with GestureDetector only if user can edit (own profile only)
              if (isOwnProfile) {
              return GestureDetector(
                onTap: () async {
                  if (skill.id != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewSkillScreen(
                          skillId: skill.id.toString(),
                        ),
                      ),
                    );

                    if (result == true && mounted) {
                      context.read<ProfileInfoCubit>().fetchProfileInfoData();
                    }
                  }
                },
                  child: skillChip,
                );
              } else {
                // For other users' profiles, just show the skill chip without tap functionality
                return skillChip;
              }
            }),
    
    
        ],
      ),
    );
  }


   Widget _buildCoverImage(ProfileInfoModel? profileItems, bool isProfile) {
    return Stack(
      children: [
        // Cover Image with opacity overlay
        Hero(
          tag: 'cover_image',
          child: GestureDetector(
            onTap: () {
              if (_isValidImageUrl(profileItems?.backgroundImage)) {
                ImageHelper.showImagePreview(
                    context, profileItems!.backgroundImage!);
              }
            },
            child: Container(
              height: 100.h,
              width: double.infinity,
              child: Stack(
                children: [
                  // Background color/gradient
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCD3D3).withOpacity(0.8),
                    ),
                  ),
                  // Cover image
                  Positioned.fill(
                    child: _isValidImageUrl(profileItems?.backgroundImage)
                        ? Image.network(
                            profileItems!.backgroundImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/background/temple_bg.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/background/temple_bg.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Dark mode overlay
                  if (isDarkMode)
                    Container(
                      color: Colors.black54,
                    ),
                ],
              ),
            ),
          ),
        ),
        // Camera button for cover (top right)
        if (isProfile)
          Positioned(
            right: 15.w,
            bottom: 8.h,
            child: _buildCameraButton(
              () => isGuest == true
                  ? showGuestLoginDialog(context)
                  : _showImagePicker(false),
              height: 20.h,
              width: 20.w,
            ),
          ),
      ],
    );
  }

  Widget _buildProfileAvatar(ProfileInfoModel? profileItems, bool isProfile) {
    return Stack(
      children: [
        // Avatar circle
        Hero(
          tag: 'avatar',
          child: GestureDetector(
            onTap: () {
              if (_isValidImageUrl(profileItems?.dp)) {
                ImageHelper.showImagePreview(context, profileItems!.dp!);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _isValidImageUrl(profileItems?.dp)
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(profileItems!.dp!),
                      radius: 38.r,
                      backgroundColor: Colors.white,
                      onBackgroundImageError: (exception, stackTrace) {},
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      radius: 38.r,
                      child: Icon(
                        Icons.person,
                        size: 45.r,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
          ),
        ),
        // Camera button on avatar (bottom right)
        if (isProfile)
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => isGuest == true
                  ? showGuestLoginDialog(context)
                  : _showImagePicker(true),
              child: Container(
                height: 18.h,
                width: 18.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(3.r),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 11.sp,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFollowButtons(ProfileInfoModel? profileItems) {
    if (profileItems == null) return const SizedBox.shrink();
    
    // Get follow status
    final isFollowing = profileItems.followingStatus ?? false;
    final isFollowingRequest = profileItems.followingRequestsStatus ?? false;
    
    // Determine button text and colors
    String buttonText;
    Color buttonColor;
    Color textColor;
    
    if (isFollowing) {
      buttonText = StringConstant.following;
      buttonColor = AppColor.orangeColor;
      textColor = AppColor.whiteColor;
    } else if (isFollowingRequest) {
      buttonText = StringConstant.requestSent;
      buttonColor = Colors.grey.shade300;
      textColor = AppColor.blackColor;
    } else {
      buttonText = "+${StringConstant.follow}";
      buttonColor = AppColor.whiteColor;
      textColor = AppColor.blackColor;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
              builder: (context, state) {
                if (state is ProfileInfoLoaded) {
                  // Re-calculate based on latest state
                  final latestProfile = state.profileInfoModel;
                  final latestIsFollowing = latestProfile?.followingStatus ?? false;
                  final latestIsRequest = latestProfile?.followingRequestsStatus ?? false;
                  
                  String latestButtonText;
                  Color latestButtonColor;
                  Color latestTextColor;
                  
                  if (latestIsFollowing) {
                    latestButtonText = StringConstant.following;
                    latestButtonColor = AppColor.orangeColor;
                    latestTextColor = AppColor.whiteColor;
                  } else if (latestIsRequest) {
                    latestButtonText = StringConstant.requestSent;
                    latestButtonColor = Colors.grey.shade300;
                    latestTextColor = AppColor.blackColor;
                  } else {
                    latestButtonText = "+${StringConstant.follow}";
                    latestButtonColor = AppColor.whiteColor;
                    latestTextColor = AppColor.blackColor;
                  }
                  
                  return CustomButton(
                    borderRadius: BorderRadius.all(Radius.circular(5.h)),
                    mypadding: EdgeInsets.symmetric(vertical: 12.h),
                    btnColor: latestButtonColor,
                    textColor: latestTextColor,
                    onTap: () => _handleFollowAction(latestProfile ?? profileItems),
                    buttonAssets: "",
                    textButton: latestButtonText,
                  );
                }
                return CustomButton(
                  borderRadius: BorderRadius.all(Radius.circular(5.h)),
                  mypadding: EdgeInsets.symmetric(vertical: 12.h),
                  btnColor: buttonColor,
                  textColor: textColor,
                  onTap: () => _handleFollowAction(profileItems),
                  buttonAssets: "",
                  textButton: buttonText,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(List<Tab> tabs) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeAwareWhiteBlack.withOpacity(0.1),
              width: 1.w,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TabBar(
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              labelStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: themeAwareWhiteBlack),
              unselectedLabelColor: AppColor.lightTextColor,
              indicatorColor: themeAwareWhiteBlack,
              dividerColor: AppColor.blackColor, // darker divider
              indicatorWeight: 3,
              indicator: UnderlineTabIndicator(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4.r),
                  topLeft: Radius.circular(4.r),
                ),
                borderSide: BorderSide(width: 3.w, color: AppColor.blackColor),
                insets: EdgeInsets.zero,
              ),
              labelPadding:
                  EdgeInsets.symmetric(vertical: 0.h, horizontal: 12.w),
              tabs: tabs,
              controller: _tabController,
            ),
          ],
        ));
  }
}
