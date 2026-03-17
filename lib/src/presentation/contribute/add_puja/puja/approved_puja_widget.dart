import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_puja/contribution_puja_cubit.dart';
import '../../../../application/contribution/contribution_puja/contribution_puja_state.dart';
import '../../../../core/router/router.dart';
import '../../../core/constants/strings.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';
import '../../widget/view_edit_bottomsheet.dart';

class ApprovedPujaWidget extends StatelessWidget {
  const ApprovedPujaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ContributePujaCubit()..fetchContributePujaData(approvedVal: 'true'),
      child: BlocBuilder<ContributePujaCubit, ContributePujaState>(
        builder: (context, state) {
          if (state is ContributePujaLoaded) {
            if (state.loadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage.isNotEmpty) {
              return Center(child: Text(state.errorMessage));
            }

            return state.pujaList!.isNotEmpty
                ? MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.separated(
                           padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
                      itemCount: state.pujaList?.length ?? 0,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final pujaItem = state.pujaList?[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xff132c4a).withOpacity(0.04),
                                offset: const Offset(0, 7),
                                blurRadius: 5,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              pujaItem?.draft == true
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
                                            padding:
                                                EdgeInsets.only(left: 10.sp),
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
                                                  color:
                                                      const Color(0xffFF4C02),
                                                ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    20.r),
                                                            topRight:
                                                                Radius.circular(
                                                                    20.r))),
                                                context: context,
                                                builder: (context) {
                                                  return ViewEditBottomsheet(
                                                    viewTap: () {
                                                      Navigator.pop(context);
                                                      AppRouter.push(
                                                          '/viewPuja/${pujaItem?.id.toString()}/${'draft'}');
                                                      // AppRouter.push(
                                                      //     '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/${'draft'}');
                                                    },
                                                    editTap: () {
                                                      Navigator.pop(context);
                                                      AppRouter.push(
                                                          '/addPuja/${pujaItem?.id.toString()}/${'EditPuja'}/${0}');
                                                    },
                                                    deleteTap: () async {
                                                      Navigator.pop(context);
                                                      await context.read<ContributePujaCubit>().deleteItem('Puja','${pujaItem?.id.toString()}');
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
                                      '/viewPuja/${pujaItem?.id.toString()}/${'draft'}');
                                },
                                child: AspectRatio(
                                  aspectRatio: 4 / 1,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 4.sp / 3.sp,
                                        child: CustomCacheImage(
                                          imageUrl: pujaItem?.images?.banner
                                                      ?.isNotEmpty ==
                                                  true
                                              ? pujaItem?.images!.banner![0]
                                                      .image ??
                                                  ''
                                              : StringConstant.defaultImage,
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 5.sp,
                                              bottom: 5.sp,
                                              left: 5.sp),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                pujaItem?.title ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                   
                                              ),
                                              // Text(
                                              //   "${pujaItem?.city ?? ''},${pujaItem?.state ?? ''}",
                                              //   style: Theme.of(context)
                                              //       .textTheme
                                              //       .bodySmall,
                                              // ),
                                              Text(
                                                'initiated ${HelperClass().formatDate(pujaItem?.createdAt ?? '')}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      pujaItem?.draft == false
                                          ? Padding(
                                              padding: EdgeInsets.only(top: 5.sp),
                                              child: InkWell(
                                                onTap: () {
                                                  showModalBottomSheet(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20.r),
                                                                topRight: Radius
                                                                    .circular(
                                                                        20.r))),
                                                    context: context,
                                                    builder: (context) {
                                                      return ViewEditBottomsheet(
                                                        viewTap: () {
                                                          Navigator.pop(context);
                                                          AppRouter.push(
                                                              '/viewPuja/${pujaItem?.id.toString()}/${'draft'}');
                                                          // AppRouter.push(
                                                          //     '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/${'draft'}');
                                                        },
                                                        editTap: () {
                                                          Navigator.pop(context);
                                                          AppRouter.push(
                                                              '/addPuja/${pujaItem?.id.toString()}/${'EditPuja'}/${0}');
                                                        },
                                                        deleteTap: () async {
                                                          Navigator.pop(context);
                                                          await context.read<ContributePujaCubit>().deleteItem('Puja','${pujaItem?.id.toString()}');
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                child:
                                                    const Icon(Icons.more_vert),
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
                  )
                : Center(
                    child: Text(
                      StringConstant.noDataAvailable,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
