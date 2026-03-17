import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_state.dart';
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

class DraftDevWidget extends StatelessWidget {
  const DraftDevWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ContributeDevCubit()..fetchContributeDevData( draftVal: "true"),
    child: BlocBuilder<ContributeDevCubit,ContributeDevState>(
        builder: (context, state){
          if (state is ContributeDevLoaded) {
            if (state.loadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state.errorMessage.isNotEmpty) {
              return Center(
                child: Text(state.errorMessage),
              );
            }
            if(state.model!.isEmpty){
              return  Center(child: Text( StringConstant.noDataAvailable,),);
            }
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.separated(
                itemCount: state.model?.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final devItem = state.model?[index];
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
                        devItem?.draft == true
                            ? Container(
                          height: 30.h,
                          decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ?AppColor.lightTextColor : const Color(0xffFFE8EB),
                                       
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.r),
                                topRight: Radius.circular(10.r),
                              )),
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
                                              '/viewDev/${devItem?.id.toString()}/${'draft'}');
                                        },
                                        editTap: () {
                                          Navigator.pop(context);
                                          AppRouter.push(
                                              '/addDev/${devItem?.id.toString()}/${'EditDev'}/${0}');
                                        },
                                        deleteTap: () async {
                                          Navigator.pop(context);
                                          await context.read<ContributeDevCubit>().deleteItem('Dev','${devItem?.id.toString()}');
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
                                '/viewDev/${devItem?.id.toString()}/${'draft'}');

                          },
                          child: AspectRatio(
                            aspectRatio: 4 / 1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 4.sp / 3.sp,
                                  child: CustomCacheImage(
                                    imageUrl:
                                    devItem?.images?.banner?.isNotEmpty == true
                                        ? devItem?.images?.banner.toString()
                                        :
                                    StringConstant.defaultImage,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                ),
                                Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 5.sp, bottom: 5.sp, left: 5.sp),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            devItem?.title ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                              
                                          ),
                                          Text(
                                            'initiate ${HelperClass().formatDate(devItem?.createdAt ?? '')}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          )
                                        ],
                                      ),
                                    )),
                                devItem?.draft == false ? Padding(
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
                                                  '/viewDev/${devItem?.id.toString()}/${'draft'}');
                                            },
                                            editTap: () {
                                              Navigator.pop(context);
                                              AppRouter.push(
                                                  '/addDev/${devItem?.id.toString()}/${'EditDev'}/${0}');
                                            },
                                            deleteTap: () async {
                                              Navigator.pop(context);
                                              await context.read<ContributeDevCubit>().deleteItem('Dev','${devItem?.id.toString()}');
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
        }),);
  }
}
