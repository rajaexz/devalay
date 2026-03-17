import 'package:devalay_app/src/application/kirti/service/service_cubit.dart';
import 'package:devalay_app/src/application/kirti/service/service_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../core/shared_preference.dart';
import '../core/constants/strings.dart';
import '../core/widget/translatable_text_widget.dart';
import '../core/helper/sharing_service.dart';

class KritiScreen extends StatefulWidget {
  const KritiScreen({super.key});

  @override
  State<KritiScreen> createState() => _KritiScreenState();
}

class _KritiScreenState extends State<KritiScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<ServiceCubit>().fetchServiceData();
  }

  Future<void> loadUserImage() async {
    userId = await PrefManager.getUserDevalayId();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ServiceCubit>().searchService(searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.whiteColor,
        body: RefreshIndicator(child: 
            Column(
          children: [
            Gap(10.h),
            Expanded(
              child: BlocBuilder<ServiceCubit, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceLoadedState) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage.isNotEmpty) {
                      return Center(child: Text(state.errorMessage));
                    }

                    final serviceList = state.serviceList ?? [];

                    if (serviceList.isEmpty) {
                      return Center(child: Text(StringConstant.noResultsFound));
                    }

                    return Padding(
                      padding: EdgeInsets.only(left: 15.sp, right: 5.sp),
                      child: ListView.separated(
                        itemCount: serviceList.length,
                        itemBuilder: (context, index) {
                          final item = serviceList[index];
                          return InkWell(
                            onTap: () {
                              AppRouter.push(
                                '/pujaDetailScreen/${item.name}/${item.id.toString()}',
                              );
                            },
                            child: SizedBox(
                              height: 100.h,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomCacheImage(
                                    imageUrl: item.images ?? '',
                                    height: 102.h,
                                    width: 134.w,
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  Gap(10.sp),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TranslatableTextWidget(
                                                text: item.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                        color: AppColor.blackColor,
                                                        fontSize: 14.sp),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Gap(3.sp),
                                              TranslatableTextWidget(
                                                text:
                                                    '₹${item.plans[0].price.round()} to ₹${item.plans[2].price.round()}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColor.lightTextColor,
                                                      fontSize: 12.sp,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 18.h,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: 5,
                                            separatorBuilder: (_, __) =>
                                                Gap(2.w),
                                            itemBuilder: (context, starIndex) {
                                              return Icon(
                                                starIndex < (item.star)
                                                    ? Icons.star
                                                    : Icons.star_outline,
                                                size: 18,
                                                color: AppColor.orangeColor,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    offset: const Offset(-15, 40),
                                    position: PopupMenuPosition.over,
                                    icon: const Icon(
                                      Icons.more_vert,
                                    ),
                                    onSelected: (value) async {
                                      if (value == 'share') {
                                        SharingService.shareContent(
                                          contentType: 'Devalay',
                                          id: item.id.toString(),
                                      
                                        );
                                      }
                                    },
                                    itemBuilder: (context) {
                                      return <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'share',
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icon/share.svg",
                                                height: 18.h,
                                                width: 18.w,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? AppColor.whiteColor
                                                    : null,
                                              ),
                                              Gap(6.w),
                                              Text(
                                                StringConstant.shareAction,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? AppColor.whiteColor
                                                      : AppColor.blackColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ];
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => Gap(18.sp),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            Gap(10.h)
          ],
        )

        , onRefresh:() async {
        
           await context.read<ServiceCubit>().fetchServiceData();
        })),
    );
  }
}
