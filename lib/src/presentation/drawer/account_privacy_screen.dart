import 'package:devalay_app/src/application/authentication/setting/setting_cubit.dart';
import 'package:devalay_app/src/core/shared_preference.dart' show PrefManager;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../core/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountPrivacyScreen extends StatefulWidget {
  const AccountPrivacyScreen({super.key});

  @override
  State<AccountPrivacyScreen> createState() => _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends State<AccountPrivacyScreen> {
  bool privateAccount = false;
  String? userid;
  @override
  void initState() {
    super.initState();
    getUserID();
  }
  void getUserID() async {
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
          "account_privacy".tr(),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "private_account".tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                // Transform.scale(
                //   scale: 0.8,
                //   child: CupertinoSwitch(
                //     value: privateAccount,
                //     activeColor: Color(0xffE8E8E8),
                //     inactiveThumbColor: Color(0xffC5C5C5),
                //     thumbColor: Color(0xff555151),
                //     trackColor: Color(0xffE8E8E8),
                //     onChanged: (value) {
                //       setState(() => privateAccount = value);
                //       context
                //           .read<SettingCubit>()
                //           .accountPrivacy("1", privateAccount.toString());
                //     },
                //   ),
                // ),

                SizedBox(
                  height: 30.sp,
                  width: 50.sp,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: CupertinoSwitch(
                      value: privateAccount,
                      activeColor: const Color(0xffE8E8E8),
                      inactiveThumbColor: const Color(0xffC5C5C5),
                      thumbColor: const Color(0xff555151),
                      trackColor: const Color(0xffE8E8E8),
                      onChanged: (value) {
                        setState(() => privateAccount = value);
                        context
                            .read<SettingCubit>()
                            .accountPrivacy(userid ?? '', privateAccount.toString());
                      },
                    ),
                  ),
                )
              ],
            ),
            Gap(26.h),
            Text("private_account_description".tr(),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColor.blackColor)),
          ],
        ),
      ),
    );
  }
}
