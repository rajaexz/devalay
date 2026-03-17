
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_festival/contribution_festival_cubit.dart';
import '../../../../application/contribution/contribution_festival/contribution_festival_state.dart';
import '../../../../core/router/router.dart';
import '../../../core/constants/strings.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';
import '../../widget/view_edit_bottomsheet.dart';

class DraftFestivalWidget extends StatefulWidget {
  const DraftFestivalWidget({super.key});

  @override
  State<DraftFestivalWidget> createState() => _DraftFestivalWidgetState();
}

class _DraftFestivalWidgetState extends State<DraftFestivalWidget> {
  late ContributeFestivalCubit contributeFestivalCubit;

  @override
  void initState() {
    super.initState();
    contributeFestivalCubit = BlocProvider.of<ContributeFestivalCubit>(context);
    contributeFestivalCubit.fetchContributeFestivalData(draftVal: 'true');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeFestivalCubit, ContributeFestivalState>(
      builder: (context, state) {
        if (state is ContributeFestivalError && state.isPermissionDenied) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xffFF4C02),
                      size: 24.sp,
                    ),
                    Gap(8.w),
                    Text(
                      'Permission Denied',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                content: Text(
                  '${StringConstant.youdonot} ${StringConstant.festival}.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                        Navigator.of(context).pop();
                            Navigator.of(context).pop();
                      contributeFestivalCubit.fetchContributeFestivalData(draftVal: 'true');
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: AppColor.appbarBgColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        }

        if (state is ContributeFestivalLoaded) {
          if (state.loadingState) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColor.appbarBgColor,
              ),
            );
          }

          if (state.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red.shade300,
                  ),
                  Gap(12.h),
                  Text(
                    state.errorMessage,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(24.h),
                  TextButton.icon(
                    onPressed: () {
                      contributeFestivalCubit.fetchContributeFestivalData(draftVal: 'true');
                    },
                    icon: Icon(Icons.refresh, size: 20.sp),
                    label: Text(
                      'Try Again',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.festivalList == null || state.festivalList!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 48.sp,
                    color: Colors.grey.shade400,
                  ),
                  Gap(12.h),
                  Text(
                    StringConstant.noDataAvailable,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            );
          }

          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              itemCount: state.festivalList?.length ?? 0,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              separatorBuilder: (context, index) => Gap(12.h),
              itemBuilder: (context, index) {
                final festivalItem = state.festivalList?[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (festivalItem?.draft == true)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColor.lightTextColor
                                : const Color(0xffFFE8EB),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              topRight: Radius.circular(12.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: const Color(0xffFF4C02),
                                size: 20.sp,
                              ),
                              Gap(8.w),
                              Expanded(
                                child: Text(
                                  StringConstant.pleaseCompleteAll,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xffFF4C02),
                                        fontSize: 13.sp,
                                      ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20.r),
                                  onTap: () => _showOptionsBottomSheet(context, festivalItem),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.sp),
                                    child: Icon(
                                      Icons.more_vert,
                                      color: const Color(0xffFF4C02),
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            AppRouter.push('/viewFestival/${festivalItem?.id.toString()}/${'draft'}');
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.sp),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: CustomCacheImage(
                                    imageUrl: festivalItem?.images?.banner?.isNotEmpty == true
                                        ? festivalItem?.images?.banner.toString()
                                        : StringConstant.defaultImage,
                                    height: 80.sp,
                                    width: 80.sp,
                                  ),
                                ),
                                Gap(12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        festivalItem?.title ?? '',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.sp,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Gap(8.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14.sp,
                                            color: AppColor.appbarBgColor.withOpacity(0.7),
                                          ),
                                          Gap(4.w),
                                          Text(
                                            'Initiated ${HelperClass().formatDate(festivalItem?.createdAt ?? '')}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color
                                                      ?.withOpacity(0.7),
                                                  fontSize: 12.sp,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (festivalItem?.draft == false)
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20.r),
                                      onTap: () => _showOptionsBottomSheet(context, festivalItem),
                                      child: Padding(
                                        padding: EdgeInsets.all(4.sp),
                                        child: Icon(
                                          Icons.more_vert,
                                          size: 20.sp,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color
                                              ?.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(
            color: AppColor.appbarBgColor,
          ),
        );
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext context, dynamic festivalItem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return ViewEditBottomsheet(
          viewTap: () {
            Navigator.pop(context);
            AppRouter.push('/viewFestival/${festivalItem?.id.toString()}/${'draft'}');
          },
          editTap: () {
            Navigator.pop(context);
            AppRouter.push('/addFestival/${festivalItem?.id.toString()}/${'EditFestival'}/${0}');
          },
          deleteTap: () async {
            Navigator.pop(context);
            await context
                .read<ContributeFestivalCubit>()
                .deleteItem('Festival', '${festivalItem?.id.toString()}');
          },
        );
      },
    );
  }
}
