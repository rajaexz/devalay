import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/widget/No_data_found.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/profile/profile_connections/profile_connections_cubit.dart';
import '../../../../application/profile/profile_connections/profile_connections_state.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/colors.dart';

// ignore: must_be_immutable
class FollowerScreen extends StatefulWidget {
  FollowerScreen({super.key, this.id, this.prolifeType});
  int? id;
  String? prolifeType;

  @override
  State<FollowerScreen> createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<FollowerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileConnectionsCubit>().init(widget.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileConnectionsCubit, ProfileConnectionsState>(
      builder: (context, state) {
        if (state is ProfileConnectionsLoaded) {
          if (state.loadingState) {
            return const Center(child: CustomLottieLoader());
          }

          if (state.profileInfoModel?.followers?.isEmpty ?? false) {
            return NoMediaView(
              onRefresh: () {
                context
                    .read<ProfileConnectionsCubit>()
                    .init(widget.id.toString());
              },
              title: "No Follower Available",
              subtitle:
                  "You haven’t shared anything yet.\nTap the button below to refresh.",
              icon: Icons.connect_without_contact,
            );
          }

          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text(state.errorMessage));
          }

          final followerItem = state.profileInfoModel?.followers;

          return Padding(
            padding: EdgeInsets.all(8.0.sp),
            child: ListView.builder(
              itemCount: followerItem?.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final follower = followerItem?[index];
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 8.0.sp, horizontal: 4.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              follower?["dp"] ?? StringConstant.defaultImage,
                            ),
                            radius: 22,
                          ),
                          Gap(12.w),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(
                                  follower?["name"] ?? '',
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const Spacer(),
                                if (widget.prolifeType != "porfile")
                                  buildButton(
                                      text: StringConstant.remove,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColor.blackColor
                                          : AppColor.whiteColor,
                                      onTap: () {
                                        context
                                            .read<ProfileConnectionsCubit>()
                                            .updateRequestStatus(
                                              "remove",
                                              follower?['id']?.toString() ?? '',
                                            );
                                      },
                                      context: context),
                              ]),
                              Gap(4.h),
                              Text(
                                "${follower?["followers"]?.length.toString()} ${StringConstant.followers}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColor.greyColor,
                                    ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }

        return const Center(child: CustomLottieLoader());
      },
    );
  }
}
