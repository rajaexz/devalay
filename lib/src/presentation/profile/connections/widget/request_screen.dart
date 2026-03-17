import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/profile/connections/widget/follower_screen.dart';
import 'package:devalay_app/src/presentation/profile/connections/widget/request_send_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/profile/profile_connections/profile_connections_cubit.dart';

class RequestScreen extends StatefulWidget {
  final int? id;
  final String? prolifeType;

  const RequestScreen({super.key, this.id, this.prolifeType});

  @override
  State<RequestScreen> createState() => _RequestSentScreenState();
}

class _RequestSentScreenState extends State<RequestScreen> {
  int selectedTab = 0;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized && widget.id != null) {
      context.read<ProfileConnectionsCubit>().init(widget.id.toString());
      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Own profile: show Sent + Follower tabs. Other's profile: only Follower (no Sent tab)
    final isOwnProfile = widget.prolifeType == 'profile';

    if (!isOwnProfile) {
      return FollowerScreen(id: widget.id, prolifeType: widget.prolifeType);
    }

    return Column(
      children: [
        Gap(20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildChipTab(
                label: StringConstant.sent,
                index: 0,
                selectedTab: selectedTab,
                context: context,
                onTabSelected: (value) {
                  setState(() {
                    selectedTab = value;
                  });
                },
              ),
              SizedBox(width: 12.w),
              buildChipTab(
                label: StringConstant.follower,
                index: 1,
                selectedTab: selectedTab,
                context: context,
                onTabSelected: (value) {
                  setState(() {
                    selectedTab = value;
                  });
                },
              ),
            ],
          ),
        ),
        Gap(10.h),
        Expanded(
          child: selectedTab == 0
              ? const RequestSendScreen()
              : FollowerScreen(id: widget.id, prolifeType: widget.prolifeType),
        ),
      ],
    );
  }
}