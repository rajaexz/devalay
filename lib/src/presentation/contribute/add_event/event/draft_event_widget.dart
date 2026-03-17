import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/router/router.dart';
import '../../widget/view_edit_bottomsheet.dart';

class DraftEventWidget extends StatefulWidget {
  const DraftEventWidget({super.key});

  @override
  State<DraftEventWidget> createState() => _DraftEventWidgetState();
}

class _DraftEventWidgetState extends State<DraftEventWidget> {
  @override
  void initState() {
    super.initState();
      context.read<ContributeEventCubit>().sectionIndex = 0;
    context.read<ContributeEventCubit>().applyFilter(
      newSectionIndex: 0,
      value: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeEventCubit, ContributeEventState>(
      builder: (context, state) {
          debugPrint('BlocBuilder triggered with ${state.runtimeType}');
        if (state is ContributeEventLoaded) {
          if (state.loadingState) {
            return const Center(child: CustomLottieLoader());
          }
    
          if (state.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                state.errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
            );
          }
          final events = state.eventList ?? [];
    
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              itemCount: events.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final templeItem = events[index];
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
                      templeItem.draft == true
                          ? Container(
                              height: 30.h,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColor.lightTextColor
                                      : const Color(0xffFFE8EB),
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
                                    onTap: () => _showActionBottomSheet(
                                        context, templeItem),
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: Color(0xffFF4C02),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      InkWell(
                        onTap: () {
                          AppRouter.push(
                              '/viewEvent/${templeItem.id.toString()}/${'draft'}');
                        },
                        child: AspectRatio(
                          aspectRatio: 4 / 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 4.sp / 3.sp,
                                child: CustomCacheImage(
                                  imageUrl: templeItem
                                              .images?.banner?.isNotEmpty ==
                                          true
                                      ? templeItem.images!.banner![0].image ??
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
                                        templeItem.title ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(),
                                      ),
                                      Text(
                                        "${templeItem.city ?? ''},${templeItem.state ?? ''}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        'initiated ${HelperClass().formatDate(templeItem.createdAt ?? '')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              templeItem.draft == false
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 5.sp),
                                      child: InkWell(
                                        onTap: () => _showActionBottomSheet(
                                            context, templeItem),
                                        child: const Icon(Icons.more_vert),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
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
    );
  }

  void _showActionBottomSheet(BuildContext context, dynamic eventItem) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r))),
      context: context,
      builder: (context) {
        return ViewEditBottomsheet(
          viewTap: () {
            Navigator.pop(context);
            AppRouter.push('/viewEvent/${eventItem?.id.toString()}/${'draft'}');
          },
          editTap: () {
            Navigator.pop(context);
            AppRouter.push(
                '/addEvent/${eventItem?.id.toString()}/${'EditEvent'}/${0}');
          },
          deleteTap: () async {
            Navigator.pop(context);
            _showDeleteConfirmationDialog(context, eventItem);
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic eventItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StringConstant.delete),
          content: Text(StringConstant.areYouSureDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(StringConstant.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await context
                    .read<ContributeEventCubit>()
                    .deleteItem('Event', '${eventItem?.id.toString()}');

                await context
                    .read<ContributeEventCubit>()
                    .applyFilter(
                      newSectionIndex: 0,
                      value: null,
                    );
              },
              child: Text(StringConstant.ok),
            ),
          ],
        );
      },
    );
  }
}
