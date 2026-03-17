import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_border_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_event/contribution_event_cubit.dart';
import '../../../../application/contribution/contribution_event/contribution_event_state.dart';
import '../../../../application/contribution/god_form/god_form_cubit.dart';
import '../../../../application/contribution/god_form/god_form_state.dart';
import '../../../core/utils/colors.dart';
import '../../../create/widget/common_guideline_text.dart';
import '../../widget/common_footer_text.dart';

class EventGodWidget extends StatefulWidget {
  const EventGodWidget(
      {super.key, required this.onNext, this.onBack, this.eventId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? eventId;

  @override
  State<EventGodWidget> createState() => _EventGodWidgetState();
}

class _EventGodWidgetState extends State<EventGodWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeEventCubit, ContributeEventState>(
        builder: (context, state) {
      final eventcubit = context.read<ContributeEventCubit>();
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(StringConstant.select),
            Gap(10.h),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColor.boxColor),
                  borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.sp),
                    child: Text(
                      "${StringConstant.tabAdd} ${StringConstant.gods}",
                      style: const TextStyle(color: AppColor.lightTextColor),
                    ),
                  )),
                  InkWell(
                    child: !eventcubit.showItems
                        ? const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColor.lightTextColor,
                          )
                        : const Icon(
                            Icons.close,
                            color: AppColor.lightTextColor,
                          ),
                    onTap: () {
                      setState(() {
                        eventcubit.showItems = !eventcubit.showItems;
                      });
                    },
                  )
                ],
              ),
            ),
            Gap(10.h),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: eventcubit.showItems
                  ? BlocProvider(
                      create: (context) => GodFormCubit()..fetchGodForm(),
                      child: BlocBuilder<GodFormCubit, GodFormState>(
                        builder: (context, state) {
                          if (state is GodFormLoaded) {
                            if (state.loadingState) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (state.errorMessage.isNotEmpty) {
                              return Center(child: Text(state.errorMessage));
                            }

                            return SizedBox(
                              height: 200.h,
                              child: Container(
                                  margin: EdgeInsets.only(top: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                    border:
                                        Border.all(color: AppColor.boxColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(
                                    maxHeight: 300.h,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: state.godList?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      final items = state.godList?[index];
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.0.sp,
                                            vertical: 6.sp),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child:
                                                    Text(items?.title ?? "")),
                                            BorderedCheckbox(
                                              value: eventcubit.selectedItems
                                                  .containsKey(items?.title),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    eventcubit.selectedItems[
                                                        items?.title ??
                                                            ''] = items!.id!;
                                                    eventcubit.selectedGod.add(
                                                        items.id.toString());
                                                  } else {
                                                    eventcubit.selectedItems
                                                        .remove(items!.title);
                                                  }
                                                });
                                                debugPrint(
                                                    "this is the selected item----${eventcubit.selectedItems}");
                                              },
                                              activeColor: AppColor
                                                  .appbarBgColor,
                                              inactiveBorderColor:
                                              AppColor
                                                  .greyColor,
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  )),
                            );
                          }

                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // Gap(10.h),
            Wrap(
              spacing: 8.0.sp,
              children: eventcubit.selectedItems.entries.map((item) {
                return Chip(
                  backgroundColor: const Color(0xffFDF2EE),
                  label: Text(
                    item.key,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      eventcubit.selectedItems.remove(item.key);
                    });
                    debugPrint(
                        "after deleteubg form ${eventcubit.selectedItems}");
                  },
                );
              }).toList(),
            ),
            // Gap(10.h),
            CommonFooterText(
                onNextTap: () async {
                  await eventcubit.updateEventGod(
                      widget.eventId ?? '', eventcubit.selectedGod);
                  widget.onNext();
                },
                onBackTap: widget.onBack),
            Gap(20.h),
            Guideline(title: StringConstant.guideline, points: [
              StringConstant.eventSelectGod,
              StringConstant.eventExample,
              StringConstant.imageHighQuality,
              StringConstant.spiritualPeople
            ]),
            Gap(20.h)
          ],
        ),
      );
    });
  }
}
