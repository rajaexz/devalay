import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_cubit.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/drawer/notification_settings_screen.dart' show NotificationSettingsScreen;
import 'package:devalay_app/src/presentation/drawer/widget/block_list_screen.dart';
import 'package:devalay_app/src/presentation/drawer/widget/guidelines_screen.dart';
import 'package:devalay_app/src/presentation/drawer/widget/invite_friends_dialog.dart';
import 'package:devalay_app/src/presentation/drawer/widget/payment_screen.dart';
import 'package:devalay_app/src/presentation/drawer/widget/privacy_policy.dart';
import 'package:devalay_app/src/presentation/drawer/widget/saves_screen.dart';
import 'package:devalay_app/src/presentation/drawer/widget/terms_and_conditions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../injection.dart';
import '../../core/router/router.dart';
import '../../core/router/router_constant.dart';
import '../../core/shared_preference.dart';
import '../../domain/repo_impl/authentication_repo.dart';
import 'widget/settings_item.dart';
import 'display_settings_screen.dart';
import 'account_privacy_screen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final authenticationRepo = getIt<AuthenticationRepo>();

    late final ProfileInfoCubit profileInfoCubit;
  String? userid;

@override
  void initState() {
    super.initState();
    // Create instance directly or use GetIt if registered
    try {
      profileInfoCubit = getIt<ProfileInfoCubit>();
    } catch (e) {
      // If not registered in GetIt, create instance directly
      profileInfoCubit = ProfileInfoCubit();
    }
    loadUserImage();
  }
  

  Future<void> loadUserImage() async {
    userid = await PrefManager.getUserDevalayId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 30.sp,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          StringConstant.settings,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          SettingsItem(
            url: "assets/icon/myProfile.svg",
            title: StringConstant.myProfile,
            onTap: () {
              AppRouter.push('${RouterConstant.aboutScreen}/${userid}');
            },
          ),

          // SettingsItem(
          //   url: "assets/icon/serviceProfile.svg",
          //   title: StringConstant.serviceProfile,
          //   onTap: () => _navigateToNotifications(context),
          // ),
          // SettingsItem(
          //   url: "assets/icon/nitificatio2.svg",
          //   title: StringConstant.editSkill,
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => const EditSkillScreen(),
          //     ),
          //   ),
          // ),
          // SettingsItem(
          //   url: "assets/icon/nitificatio2.svg",
          //   title: "View Skill",
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => const ViewSkillScreen(),
          //     ),
          //   ),
          // ),

          SettingsItem(
            url: "assets/icon/payment.svg",
            title: StringConstant.payment,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentScreen(),
              ),
            ),
          ),

          // SettingsItem(
          //   url: "assets/icon/aadharVerification.svg",
          //   title: StringConstant.aadharVerification,
          //   onTap: () => _navigateToNotifications(context),
          // ),

          SettingsItem(
            url: "assets/icon/notification.svg",
            title: StringConstant.notification,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            ),
          ),

          SettingsItem(
            url: "assets/icon/saved_icon.svg",
            title: StringConstant.saveTab,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SavesScreen(),
              ),
            ),
          ),



          SettingsItem(
            url: "assets/icon/display_icon.svg",
            title: StringConstant.display,
            onTap: () => _navigateToDisplay(context),
          ),

          SettingsItem(
            url: "assets/icon/AccountPrivacy.svg",
            title: StringConstant.accountPrivacy,
            onTap: () => _navigateToAccountPrivacy(context),
          ),
          SettingsItem(
            url: "assets/icon/blocked.svg",
            title: StringConstant.blocked,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlockListScreen(),
                ),
              );
            },
          ),
          SettingsItem(
            url: "assets/icon/InviteYourFriends.svg",
            title: StringConstant.inviteFriends,
            onTap: () {
              InviteFriendsDialog.show(context);
            },
          ),
          SettingsItem(
            url: "assets/icon/termCondition.svg",
            title: StringConstant.termsConditions,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  const TermsAndConditions(),
                ),
              );
            },
          ),
         
             SettingsItem(
            url: "assets/icon/PrivacyPolicy.svg",
            title: StringConstant.privacyPolicy,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  const DevalayApiExample(),
                ),
              );
            },
          ),
          SettingsItem(
            url: "assets/icon/PrivacyPolicy.svg",
            title: StringConstant.guideliness,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  const GuidelinesScreen(),
                ),
              );
            },
          ),
     SettingsItem(
            url: "assets/icon/delete.svg",
            title: StringConstant.deleteAccount,
            onTap: () => deleteAccountConfirmation(context, profileInfoCubit),
            isDestructive: true,
          ),
          
        
          SettingsItem(
            url: "assets/icon/Logout 2.svg",
            title: StringConstant.logOut,
            onTap: () => logoutAccount(context),
            isDestructive: false,
            showArrow: false,
          ),
        ],
      ),
    );
  }


  void _navigateToDisplay(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DisplaySettingsScreen(),
      ),
    );
  }

  void _navigateToAccountPrivacy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountPrivacyScreen(),
      ),
    );
  }


  void logoutAccount(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.symmetric(vertical: 30.h),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColor.blackColor)
                ),
                SizedBox(height: 16.h),
                Text(
                  'Return soon to reconnect with the divine.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColor.blackColor),
                ),
                // SizedBox(height: 8.h),
                // Text(
                //   'Your spiritual journey awaits.',
                //   textAlign: TextAlign.center,
                //   style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColor.blackColor),
                // ),
                SizedBox(height: 40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        authenticationRepo.userSignOut(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColor.subTitleTextColor,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 25.w),
                      ),
                      child: Text(
                        'Yes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColor.blackColor),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 14.w),
                      ),
                      child: Text(
                        'Cancel',
                        style:Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColor.whiteColor)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
void deleteAccountConfirmation(BuildContext context, ProfileInfoCubit profileInfoCubit) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 48.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  StringConstant.deleteAccount,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColor.blackColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Are you sure you want to delete your account?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColor.blackColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColor.subTitleTextColor,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 20.w,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColor.blackColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        // Call delete account function
                        final success = await profileInfoCubit.deleteAccount(context);
                        if (success) {
                          // Account deleted successfully
                          // Navigation will be handled in cubit
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 20.w,
                        ),
                      ),
                      child: Text(
                        StringConstant.delete, 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColor.whiteColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
