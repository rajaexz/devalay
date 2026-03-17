import 'package:devalay_app/src/application/profile/profile_connections/profile_connections_state.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/profile/profile_connections/profile_connections_cubit.dart';
import '../../../core/constants/strings.dart';

class RequestSendScreen extends StatefulWidget {
  const RequestSendScreen({super.key});

  @override
  State<RequestSendScreen> createState() => _RequestState();
}

class _RequestState extends State<RequestSendScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileConnectionsCubit, ProfileConnectionsState>(
      builder: (context, state) {
        if (state is ProfileConnectionsLoaded) {
          if (state.loadingState) {
            return const Center(child: CustomLottieLoader());
          }

          final requestItem = state.profileInfoModel?.followingRequests;

          if (requestItem == null || requestItem.isEmpty) {
            return Center(child: Text(StringConstant.noDataAvailableSubtitle));
          }

          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text(state.errorMessage));
          }

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.sp),
            child: ListView.builder(
              itemCount: requestItem.length,
              itemBuilder: (context, index) {
                final item = requestItem[index];
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar

                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          item.dp ?? StringConstant.defaultImage,
                        ),
                        radius: 22,
                      ),
                      Gap(10.w),

                      // Name & Username
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const Spacer(),
                                buildButton(
                                    text: StringConstant.remove,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColor.blackColor
                                        : AppColor.whiteColor,
                                    onTap: () {
                                      context
                                          .read<ProfileConnectionsCubit>()
                                          .updateSendRequestDeleteStatus(
                                           "remove",
                                            item.id.toString(),
                                          );
                                    },
                                    context: context),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  item.following?.length.toString() ?? '0',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(),
                                ),
                                Gap(5.w),
                                Text(
                                  StringConstant.following,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Gap(10.w),

                      // Remove Button
                    ],
                  ),
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
