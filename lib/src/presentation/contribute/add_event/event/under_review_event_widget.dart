import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_event/contribution_event_cubit.dart';
import '../../../../application/contribution/contribution_event/contribution_event_state.dart';
import '../../../../core/router/router.dart';
import '../../../core/constants/strings.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';
import '../../widget/view_edit_bottomsheet.dart';

class UnderReviewEventWidget extends StatefulWidget {
  const UnderReviewEventWidget({super.key});

  @override
  State<UnderReviewEventWidget> createState() => _UnderReviewEventWidgetState();
}

class _UnderReviewEventWidgetState extends State<UnderReviewEventWidget> {
  @override
  void initState() {
    super.initState();
  context.read<ContributeEventCubit>().sectionIndex = 1;
    context.read<ContributeEventCubit>().applyFilter(
      newSectionIndex: 1,
      value: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeEventCubit, ContributeEventState>(
      builder: (context, state) {
        if (state is ContributeEventLoaded) {
          if (state.loadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text(state.errorMessage));
          }
          if(state.eventList!.isEmpty){
            return const Center(child: Text("No Event Found"),);
          }
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              itemCount: state.eventList?.length ?? 0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final eventItem = state.eventList?[index];
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
                      eventItem?.draft == true
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
                                            '/viewEvent/${eventItem?.id.toString()}/${'draft'}');
                                      },
                                      editTap: () {
                                        Navigator.pop(context);
                                        AppRouter.push(
                                            '/addEvent/${eventItem?.id.toString()}/${'EditEvent'}/${0}');
                                      },
                                      deleteTap: () async {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder:
                                                (BuildContext
                                            context) {
                                              return AlertDialog(
                                                title:  Text(
                                                      StringConstant.delete),
                                                content:
                                                 Text(
                                                    StringConstant.areYouSureDelete),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () =>
                                                        Navigator.pop(context),
                                                    child:  Text(
                                                        StringConstant.cancel),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        ()  {
                                                      Navigator.pop(context);
                                                      context.read<ContributeEventCubit>().deleteItem(
                                                          'Event',
                                                          '${eventItem?.id.toString()}');
                                                      context
                                                          .read<ContributeEventCubit>()
                                                          .fetchContributeEventData(  approvedVal: 'false', rejectVal: 'false', draftVal: 'false',);
                                                    },
                                                    child:  Text(
                                                       StringConstant.ok),
                                                  ),
                                                ],
                                              );
                                            });
                                        // await context.read<ContributeEventCubit>().deleteItem('Event','${eventItem?.id.toString()}');
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
                              '/viewEvent/${eventItem?.id.toString()}/${'draft'}');
                        },
                        child: AspectRatio(
                          aspectRatio: 4 / 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 4.sp / 3.sp,
                                child: CustomCacheImage(
                                  imageUrl: eventItem
                                      ?.images?.banner?.isNotEmpty ==
                                      true
                                      ? eventItem?.images!.banner![0].image ?? ''
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
                                        eventItem?.title ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                         
                                      ),
                                      Text(
                                        "${eventItem?.city ?? ''},${eventItem?.state ?? ''}",
                                        style:
                                        Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        'initiated ${HelperClass().formatDate(eventItem?.createdAt ?? '')}',
                                        style:
                                        Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              eventItem?.draft == false
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
                                                '/viewEvent/${eventItem?.id.toString()}/${'draft'}');
                                          },
                                          editTap: () {
                                            Navigator.pop(context);
                                            AppRouter.push(
                                                '/addEvent/${eventItem?.id.toString()}/${'EditEvent'}/${0}');
                                          },
                                          deleteTap: () async {
                                            Navigator.pop(context);
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext
                                                context) {
                                                  return AlertDialog(
                                                    title:  Text(
                                                        StringConstant.delete),
                                                    content:
                                                     Text(
                                                        StringConstant.areYouSureDelete),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () =>
                                                            Navigator.pop(context),
                                                        child:  Text(
                                                            StringConstant.cancel),
                                                      ),
                                                      TextButton(
                                                        onPressed:
                                                            ()  {
                                                          Navigator.pop(context);
                                                          context.read<ContributeEventCubit>().deleteItem(
                                                              'Event',
                                                              '${eventItem?.id.toString()}');
                                                          context
                                                              .read<ContributeEventCubit>()
                                                              .fetchContributeEventData( approvedVal: 'false', rejectVal: 'false', draftVal: 'false', );
                                                        },
                                                        child:  Text(
                                                           StringConstant.ok),
                                                      ),
                                                    ],
                                                  );
                                                });
                                            // await context.read<ContributeEventCubit>().deleteItem('Event','${eventItem?.id.toString()}');
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
    );
  }
}
