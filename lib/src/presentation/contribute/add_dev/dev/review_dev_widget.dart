import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_dev/contribution_dev_cubit.dart';
import '../../../../application/contribution/contribution_dev/contribution_dev_state.dart';
import '../../../../core/router/router.dart';
import '../../../core/constants/strings.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';

class ReviewDevWidget extends StatefulWidget {
  const ReviewDevWidget({super.key});

  @override
  State<ReviewDevWidget> createState() => _ReviewDevWidgetState();
}

class _ReviewDevWidgetState extends State<ReviewDevWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ContributeDevCubit()..fetchContributeDevData(value: 'true'),
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
                return Center(child: Text(StringConstant.noDataAvailable),);
              }
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                child: ListView.separated(
                  itemCount: state.model?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final devItem = state.model?[index];
                    return InkWell(
                      onTap: () {
                        AppRouter.push(
                            '/viewDev/${devItem?.id.toString()}/${'review'}');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.whiteColor,
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
                            AspectRatio(
                              aspectRatio: 4 / 1,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 4.sp / 3.sp,
                                    child: CustomCacheImage(
                                      imageUrl: devItem
                                          ?.images?.banner?.isNotEmpty ==
                                          true
                                          ? devItem?.images!.banner![0].image ??
                                          ''
                                          : StringConstant.defaultImage,
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 5.sp, bottom: 5.sp, left: 5.sp),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            devItem?.title ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(color: Colors.black),
                                          ),
                                          Text(
                                            'initiated ${HelperClass().formatDate(devItem?.createdAt ?? '')}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
