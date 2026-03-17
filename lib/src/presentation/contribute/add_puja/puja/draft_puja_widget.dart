import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/router/router.dart';
import '../../../core/constants/strings.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';
import '../../widget/view_edit_bottomsheet.dart';
class DraftPujaWidget extends StatefulWidget {
  const DraftPujaWidget({super.key});

  @override
  State<DraftPujaWidget> createState() => _DraftPujaWidgetState();
}

class _DraftPujaWidgetState extends State<DraftPujaWidget> {
  late ContributePujaCubit contributePujaCubit;

  @override
  void initState() {
    super.initState();
    contributePujaCubit = context.read<ContributePujaCubit>();
    contributePujaCubit.sectionIndex = 0;
    contributePujaCubit.applyFilter(
      newSectionIndex: 0,
      value: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributePujaCubit, ContributePujaState>(
      builder: (context, state) {
        if (state is ContributePujaLoaded) {
          // Permission Denied Dialog
          if (state.isPermissionDenied) {
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
                    '${StringConstant.youdonot} puja.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        context.read<ContributePujaCubit>().applyFilter(
                              newSectionIndex: 0,
                              value: null,
                            );
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

          // Loading State
          if (state.loadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error State
          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text(state.errorMessage));
          }

          // Empty Data
          final pujaList = state.pujaList ?? [];
          if (pujaList.isEmpty) {
            return Center(child: Text(StringConstant.noDataAvailable));
          }

          // List View
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
              itemCount: pujaList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final pujaItem = pujaList[index];
                final isDraft = pujaItem.draft ?? false;

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff132c4a).withOpacity(0.04),
                        offset: const Offset(0, 7),
                        blurRadius: 5,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDraft)
                        Container(
                          height: 30.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColor.lightTextColor
                                : const Color(0xffFFE8EB),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.r),
                              topRight: Radius.circular(10.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10.sp),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xffFF4C02),
                                ),
                              ),
                              Text(
                                StringConstant.pleaseCompleteAll,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: const Color(0xffFF4C02)),
                              ),
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.r),
                                        topRight: Radius.circular(20.r),
                                      ),
                                    ),
                                    context: context,
                                    builder: (context) {
                                      return ViewEditBottomsheet(
                                        viewTap: () {
                                          Navigator.pop(context);
                                          AppRouter.push(
                                              '/viewPuja/${pujaItem.id}/draft');
                                        },
                                        editTap: () {
                                          Navigator.pop(context);
                                          AppRouter.push(
                                              '/addPuja/${pujaItem.id}/EditPuja/0');
                                        },
                                        deleteTap: () async {
                                          Navigator.pop(context);
                                          await context
                                              .read<ContributePujaCubit>()
                                              .deleteItem('Puja', '${pujaItem.id}');
                                        },
                                      );
                                    },
                                  );
                                },
                                child: const Icon(
                                  Icons.more_vert,
                                  color: Color(0xffFF4C02),
                                ),
                              ),
                            ],
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          AppRouter.push('/viewPuja/${pujaItem.id}/draft');
                        },
                        child: AspectRatio(
                          aspectRatio: 4 / 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 4.sp / 3.sp,
                                child: CustomCacheImage(
                                  imageUrl: pujaItem.images!.banner != null && pujaItem.images!.banner!.toString().isNotEmpty
                                      ? pujaItem.images!.banner!.toString()
                                      : StringConstant.defaultImage,
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 5.sp,
                                    bottom: 5.sp,
                                    left: 5.sp,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        pujaItem.title ?? '',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        'initiate ${HelperClass().formatDate(pujaItem.createdAt?.toString() ?? '')}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isDraft)
                                Padding(
                                  padding: EdgeInsets.only(top: 5.sp),
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.r),
                                            topRight: Radius.circular(20.r),
                                          ),
                                        ),
                                        context: context,
                                        builder: (context) {
                                          return ViewEditBottomsheet(
                                            viewTap: () {
                                              Navigator.pop(context);
                                              AppRouter.push(
                                                  '/viewPuja/${pujaItem.id}/draft');
                                            },
                                            editTap: () {
                                              Navigator.pop(context);
                                              AppRouter.push(
                                                  '/addPuja/${pujaItem.id}/EditPuja/0');
                                            },
                                            deleteTap: () async {
                                              Navigator.pop(context);
                                              await context
                                                  .read<ContributePujaCubit>()
                                                  .deleteItem('Puja', '${pujaItem.id}');
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(Icons.more_vert),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => Gap(10.h),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
