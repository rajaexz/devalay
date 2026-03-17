import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ApprovedTempleWidget extends StatefulWidget {
  const ApprovedTempleWidget({super.key});

  @override
  State<ApprovedTempleWidget> createState() => _ApprovedTempleWidgetState();
}

class _ApprovedTempleWidgetState extends State<ApprovedTempleWidget> {
  late ContributeTempleCubit contributeTempleCubit;

  @override
  void initState() {
    super.initState();
    contributeTempleCubit = context.read<ContributeTempleCubit>();
     context.read<ContributeTempleCubit>().applyFilter(
          newSectionIndex:2,
          value: 'false',
        );
   
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        if (state is ContributeTempleLoaded) {
          if (state.loadingState) {
            return const Center(child: CustomLottieLoader());
          }
          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text(state.errorMessage));
          }
          return state.templeList!.isNotEmpty
              ? MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.separated(
                    itemCount: state.templeList?.length ?? 0,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final templeItem = state.templeList?[index];
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
                        child: InkWell(
                          onTap: () {
                            AppRouter.push(
                                '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/${'approved'}');
                          },
                          child: AspectRatio(
                            aspectRatio: 4 / 1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 4.sp / 3.sp,
                                  child: CustomCacheImage(
                                    imageUrl: templeItem?.images?.banner?.isNotEmpty == true
                                        ? templeItem?.images!.banner![0].image ?? ''
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
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          templeItem?.title ?? '',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        Text(
                                          "${templeItem?.city ?? ''}, ${templeItem?.state ?? ''}",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          'Approved on ${HelperClass().formatDate(templeItem?.updatedAt ?? '')}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
        return const Center(child: CustomLottieLoader());
      },
    );
  }
}
