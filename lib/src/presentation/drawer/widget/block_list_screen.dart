import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../application/profile/profile_connections/profile_connections_cubit.dart';
import '../../../application/profile/profile_connections/profile_connections_state.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/loader.dart';
import '../../core/utils/colors.dart';
import '../../core/widget/No_data_found.dart';
import '../../core/widget/custom_button.dart';

class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  late String userId;
  
  @override
  void initState() {
    super.initState();
    getGuest();
  }
  
  void getGuest() async {
    userId = await PrefManager.getUserDevalayId() ?? '';
    context.read<ProfileConnectionsCubit>().init(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "${StringConstant.blocked} ${StringConstant.account}",
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<ProfileConnectionsCubit, ProfileConnectionsState>(
        builder: (context, state) {
          if (state is ProfileConnectionsLoaded) {
            if (state.loadingState) {
              return const Center(child: CustomLottieLoader());
            }

            // Check if blockList is empty
            if (state.profileInfoModel?.blockList?.isEmpty ?? true) {
              return NoMediaView(
                onRefresh: () {
                  context
                      .read<ProfileConnectionsCubit>()
                      .init(userId);
                },
                title: "No Blocked Accounts",
                subtitle:
                    "You haven't blocked anyone yet.\nTap the button below to refresh.",
                icon: Icons.block,
              );
            }

            if (state.errorMessage.isNotEmpty) {
              return Center(child: Text(state.errorMessage));
            }

            // Get blockList data
            final blockListItems = state.profileInfoModel?.blockList;

            return Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: ListView.builder(
                itemCount: blockListItems?.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final blockedUser = blockListItems?[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 8.0.sp, horizontal: 7.sp),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            blockedUser?.dp ?? StringConstant.defaultImage,
                          ),
                          radius: 22,
                        ),
                        Gap(12.w),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  blockedUser?.name ?? '',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    color: AppColor.blackColor,
                                  ),
                                ),
                                Gap(4.h),
                                Row(
                                  children: [
                                    Text(
                                      "${blockedUser?.followers?.length ?? 0} ${StringConstant.followers}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.7),
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    Gap(5.w),
                                    Text(
                                      "${blockedUser?.postCount ?? 0} posts",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.7),
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        buildButton(
                            text: StringConstant.unblock,
                            color: Theme.of(context).brightness ==
                                Brightness.dark
                                ? AppColor.blackColor
                                : AppColor.whiteColor,
                            onTap: () {
                              context
                                  .read<ProfileConnectionsCubit>()
                                  .updateRequestStatus(
                                "remove",
                                blockedUser?.id.toString() ?? '',
                              );
                            },
                            context: context),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: CustomLottieLoader());
        },
      ),
    );
  }
}