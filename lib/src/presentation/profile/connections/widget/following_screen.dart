import 'package:devalay_app/src/application/profile/profile_connections/profile_connections_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_connections/profile_connections_state.dart';
import 'package:devalay_app/src/data/model/profile/profile_info_model.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/widget/No_data_found.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/strings.dart';
import '../../../core/utils/colors.dart';

class FollowingScreen extends StatefulWidget {
  final int? id;
  final String? prolifeType;
  final ProfileInfoModel? profileInfoModel; // ⭐ ADD THIS PARAMETER

  const FollowingScreen({
    super.key,
    this.id,
    this.prolifeType,
    this.profileInfoModel, // ⭐ ADD THIS
  });

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  void initState() {
    super.initState();
    // Only initialize if no data is passed
    if (widget.profileInfoModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ProfileConnectionsCubit>().init(widget.id.toString());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If data is passed directly, use it; otherwise use BLoC state
    if (widget.profileInfoModel != null) {
      return _buildFollowingList(widget.profileInfoModel!);
    }

    return BlocBuilder<ProfileConnectionsCubit, ProfileConnectionsState>(
      builder: (context, state) {
        if (state is ProfileConnectionsLoaded) {
          if (state.loadingState) {
            return const Center(
              child: CustomLottieLoader(),
            );
          }
          if (state.profileInfoModel != null) {
            return _buildFollowingList(state.profileInfoModel!);
          }
          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text(state.errorMessage));
          }
        }
        return const Center(
          child: CustomLottieLoader(),
        );
      },
    );
  }

  Widget _buildFollowingList(ProfileInfoModel profileInfoModel) {
    final followingItem = profileInfoModel.following;

    if (followingItem?.isEmpty ?? true) {
      return NoMediaView(
        onRefresh: () {
          context.read<ProfileConnectionsCubit>().fetchConnectionData();
        },
        title: StringConstant.noFollowingAvailable,
        subtitle: StringConstant.noFollowingAvailableSubtitle,
        icon: Icons.connect_without_contact,
      );
    }

    return Padding(
      padding: EdgeInsets.all(8.0.sp),
      child: ListView.builder(
        itemCount: followingItem?.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 8.0.sp,
                  horizontal: 4.sp,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          followingItem?[index].dp ??
                              StringConstant.defaultImage,
                        ),
                        radius: 22,
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                followingItem?[index].name ?? '',
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                                softWrap: false,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              widget.prolifeType != "profile"
                                  ? const SizedBox()
                                  : Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () {
                                          _showUnfollowDialog(
                                            context,
                                            followingItem?[index].name ?? '',
                                            followingItem?[index].id.toString() ?? '',
                                          );
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 26,
                                          width: 78,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.sp,
                                            vertical: 2.sp,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? AppColor.whiteColor
                                                  : AppColor.lightGrayColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          child: Text(
                                            StringConstant.unfollow,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                followingItem?[index]
                                        .followers
                                        ?.length
                                        .toString() ??
                                    '',
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: AppColor.greyColor,
                                    ),
                              ),
                              Gap(5.w),
                              Text(
                                StringConstant.followers,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
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
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUnfollowDialog(BuildContext context, String userName, String userId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.r),
          topLeft: Radius.circular(10.r),
        ),
        side: BorderSide(
          color: AppColor.appbarBgColor,
          width: 1.w,
        ),
      ),
      backgroundColor: AppColor.whiteColor,
      builder: (modalContext) {
        return Container(
          height: 250.h,
          width: 150.w,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 10.h,
          ),
          child: Column(
            children: [
              Container(
                height: 5.h,
                width: 70.w,
                decoration: BoxDecoration(
                  color: AppColor.blackColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              Gap(50.h),
              Column(
                children: [
                  Text(
                    StringConstant.areYouSureYouWantToUnfollow,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!,
                  ),
                  Text(
                    userName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!,
                  ),
                ],
              ),
              Gap(30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomButton(
                      btnColor: AppColor.transparentColor,
                      onTap: () {
                        context.read<ProfileConnectionsCubit>().updateFollowingStatus(
                          "remove",
                          userId,
                          modalContext,
                        );
                      },
                      mypadding: EdgeInsets.symmetric(vertical: 10.h),
                      buttonAssets: "",
                      textButton: StringConstant.unfollow,
                      textColor: AppColor.blackColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      btnColor: AppColor.appbarBgColor,
                      onTap: () {
                        Navigator.pop(modalContext);
                      },
                      mypadding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 0,
                      ),
                      buttonAssets: "",
                      textButton: StringConstant.cancel,
                      textColor: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }}