import 'package:devalay_app/src/application/contribution/contribution_festival/contribution_festival_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_festival/contribution_festival_state.dart';
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

class UnderReviewFestivalWidget extends StatelessWidget {
  const UnderReviewFestivalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContributeFestivalCubit()
        ..fetchContributeFestivalData(
            approvedVal: 'false', rejectVal: 'false', draftVal: 'false'),
      child: BlocBuilder<ContributeFestivalCubit, ContributeFestivalState>(
        builder: (context, state) {
          if (state is ContributeFestivalLoaded) {
            if (state.loadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage.isNotEmpty) {
              return Center(child: Text(state.errorMessage));
            }
            if (state.festivalList!.isEmpty){
              return Center(child: Text( StringConstant.noDataAvailable),);
            }
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.separated(
                itemCount: state.festivalList?.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final festivalItem = state.festivalList?[index];
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
                        festivalItem?.draft == true
                            ? Container(
                          height: 30.h,
                          decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ?AppColor.lightTextColor : const Color(0xffFFE8EB),
                                       
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.r),
                                topRight: Radius.circular(10.r),
                              )),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
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
                                    ?.copyWith(
                                  color: const Color(0xffFF4C02),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.r),
                                            topRight:
                                            Radius.circular(20.r))),
                                    context: context,
                                    builder: (context) {
                                      return ViewEditBottomsheet(
                                        viewTap: () {
                                          Navigator.pop(context);
                                          AppRouter.push(
                                              '/viewFestival/${festivalItem?.id.toString()}/${'draft'}');
                                        },
                                        editTap: () {
                                          Navigator.pop(context);
                                          AppRouter.push(
                                              '/addFestival/${festivalItem?.id.toString()}/${'EditFestival'}/${0}');
                                        },
                                        deleteTap: () async {
                                          Navigator.pop(context);
                                          await context.read<ContributeFestivalCubit>().deleteItem('Festival','${festivalItem?.id.toString()}');
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
                        )
                            : const SizedBox(),
                        InkWell(
                          onTap: (){
                            AppRouter.push(
                                '/viewFestival/${festivalItem?.id.toString()}/${'draft'}');
                          },
                          child: AspectRatio(
                            aspectRatio: 4 / 1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 4.sp / 3.sp,
                                  child: CustomCacheImage(
                                    imageUrl: festivalItem
                                        ?.images?.banner?.isNotEmpty ==
                                        true
                                        ? festivalItem?.images!.banner![0].image ?? ''
                                        : StringConstant.defaultImage,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 5.sp, bottom: 5.sp, left: 5.sp),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          festivalItem?.title ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                            
                                        ),
                                        // Text(
                                        //   "${festivalItem?.city ?? ''},${eventItem?.state ?? ''}",
                                        //   style:
                                        //   Theme.of(context).textTheme.bodySmall,
                                        // ),
                                        Text(
                                          'initiated ${HelperClass().formatDate(festivalItem?.createdAt ?? '')}',
                                          style:
                                          Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                festivalItem?.draft == false
                                    ? Padding(
                                  padding: EdgeInsets.only(top: 5.sp),
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft:
                                                Radius.circular(20.r),
                                                topRight:
                                                Radius.circular(20.r))),
                                        context: context,
                                        builder: (context) {
                                          return ViewEditBottomsheet(
                                            viewTap: () {
                                              Navigator.pop(context);
                                              AppRouter.push(
                                                  '/viewFestival/${festivalItem?.id.toString()}/${'draft'}');
                                            },
                                            editTap: () {
                                              Navigator.pop(context);
                                              AppRouter.push(
                                                  '/addFestival/${festivalItem?.id.toString()}/${'EditFestival'}/${0}');
                                            },
                                            deleteTap: () async {
                                              Navigator.pop(context);
                                              await context.read<ContributeFestivalCubit>().deleteItem('Festival','${festivalItem?.id.toString()}');
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(Icons.more_vert),
                                  ),
                                )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Gap(10.h);
                },
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
