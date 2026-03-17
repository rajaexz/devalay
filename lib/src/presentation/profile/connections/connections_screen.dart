import 'package:devalay_app/src/application/profile/profile_connections/profile_connections_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_connections/profile_connections_state.dart';
import 'package:devalay_app/src/data/model/profile/profile_info_model.dart' show FollowersRequestElement;
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart' show CustomLottieLoader;
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/profile/connections/widget/following_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import '../../contribute/add_temple/temple/draft_temple_widget.dart';

class ConnectionsScreen extends StatefulWidget {
  int? id;
  String? prolifeType;
  ConnectionsScreen({super.key, this.id, this.prolifeType});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  int selectedIndex = 0;
  late List<String> tabTitle;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeTabs();
    // Initialize API call here instead of didChangeDependencies
    if (widget.id != null && !_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasInitialized) {
          context.read<ProfileConnectionsCubit>().init(widget.id.toString());
          _hasInitialized = true;
        }
      });
    }
  }

  void initializeTabs() {
    // Own profile (profileType == "profile"): show Following + Request Sent
    // Other's profile: show only Following (no Request/Request Sent tab)
    final isOwnProfile = widget.prolifeType == 'profile';
    tabTitle = isOwnProfile
        ? [StringConstant.following, StringConstant.requestSent]
        : [StringConstant.following];
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = widget.prolifeType == 'profile';

    return BlocBuilder<ProfileConnectionsCubit, ProfileConnectionsState>(
      builder: (context, state) {
        if (state is ProfileConnectionsLoaded) {
          if (state.loadingState) {
            return const Center(child: CustomLottieLoader());
          }

          // Other's profile: show only Following (no chip tabs), same as request_screen
          if (!isOwnProfile) {
            return FollowingScreen(
              id: widget.id,
              prolifeType: widget.prolifeType,
              profileInfoModel: state.profileInfoModel,
            );
          }

          final followerItem = state.profileInfoModel?.followersRequests ?? [];

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(10.h),
                SizedBox(
                  height: 40.h,
                  child: Row(
                    children: [
                      if (tabTitle.isNotEmpty)
                        buildChipTab(
                          label: tabTitle[0],
                          index: 0,
                          selectedTab: selectedIndex,
                          context: context,
                          onTabSelected: (value) {
                            setState(() {
                              selectedIndex = value;
                            });
                          },
                        ),
                      SizedBox(width: 12.w),
                      if (tabTitle.length > 1)
                        buildChipTab(
                          label: tabTitle[1],
                          index: 1,
                          selectedTab: selectedIndex,
                          context: context,
                          onTabSelected: (value) {
                            setState(() {
                              selectedIndex = value;
                            });
                          },
                        ),
                      SizedBox(width: 12.w),
                    ],
                  ),
                ),
                Gap(10.h),
                Expanded(
                  child: getSelectedWidget(selectedIndex, followerItem, state.profileInfoModel),
                )
              ],
            ),
          );
        }
        return const Center(child: CustomLottieLoader());
      },
    );
  }

  Widget getSelectedWidget(
    int index, 
    List<FollowersRequestElement> followersRequest,
    dynamic profileInfoModel,
  ) {
    switch (index) {
      case 0:
        // Pass the profileInfoModel to prevent re-initialization
        return FollowingScreen(
          id: widget.id,
          prolifeType: widget.prolifeType,
          profileInfoModel: profileInfoModel, // Pass the data
        );
      case 1:
        return _buildRequestList(followersRequest);
      default:
        return const DraftTempleWidget();
    }
  }

  Widget _buildRequestList(List<FollowersRequestElement> items) {
    if (items.isEmpty) {
      return const Center(child: Text("No incoming requests"));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    item.dp ?? StringConstant.defaultImage,
                  ),
                  radius: 22,
                ),
                Gap(10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          buildButton(
                            text: StringConstant.confirm,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColor.blackColor
                                : AppColor.whiteColor,
                            onTap: () {
                              context
                                  .read<ProfileConnectionsCubit>()
                                  .updateRequestSendStatus("add", item.id.toString());
                            },
                            context: context,
                          ),
                          Gap(10.w),
                          buildButton(
                            text: StringConstant.delete,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColor.blackColor
                                : AppColor.whiteColor,
                            onTap: () {
                              context
                                  .read<ProfileConnectionsCubit>()
                                  .updateRequestSendStatus("remove", item.id.toString());
                            },
                            context: context,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "${item.followers?.length ?? 0} ${StringConstant.followers}",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: AppColor.greyColor,
                                ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void didUpdateWidget(ConnectionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prolifeType != widget.prolifeType) {
      initializeTabs();
    }
  }
}