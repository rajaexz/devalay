import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../application/contribution/contribution_event/contribution_event_cubit.dart';
import '../../../../application/contribution/contribution_event/contribution_event_state.dart';
import '../../../core/utils/colors.dart';
import '../../../create/widget/common_guideline_text.dart';
import '../../widget/common_footer_text.dart';

class EventDatesWidget extends StatefulWidget {
  const EventDatesWidget({
    super.key, 
    required this.onNext, 
    this.onBack, 
    this.eventId
  });
  
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? eventId;

  @override
  State<EventDatesWidget> createState() => _EventDatesWidgetState();
}

class _EventDatesWidgetState extends State<EventDatesWidget> {
  late ContributeEventCubit _eventCubit;

  @override
  void initState() {
    super.initState();
    _eventCubit = context.read<ContributeEventCubit>();
    
    // Ensure at least one date-time set exists
    if (_eventCubit.dateTimeControllers.isEmpty) {
      _addNewDateTimeFieldSet();
    }
  }

  void _addNewDateTimeFieldSet() {
    final newSet = {
      'startDate': TextEditingController(),
      'startTime': TextEditingController(),
      'endTime': TextEditingController(),
    };

    setState(() {
      _eventCubit.dateTimeControllers.add(newSet);
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }


  void _removeDateTimeFieldSet(int index) {
    if (_eventCubit.dateTimeControllers.length > 1) {
      setState(() {
        _eventCubit.dateTimeControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<ContributeEventCubit, ContributeEventState>(
        builder: (context, state) {
          return Column(
            children: [
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _eventCubit.dateTimeControllers.length,
                separatorBuilder: (context, index) => Gap(5.h),
                itemBuilder: (context, index) {
                  final controllers = _eventCubit.dateTimeControllers[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Day ${index + 1}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                              ),
                            ),
                            if (_eventCubit.dateTimeControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _removeDateTimeFieldSet(index),
                              ),
                          ],
                        ),
                        Gap(10.h),
                        const Text("Select Date"),
                        Gap(10.h),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 42.h,
                                child: TextField(
                                  controller: controllers['startDate'],
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    // hintText: 'yyyy-mm-dd',
                                    // labelText: StringConstant.startDate,
                                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 20.sp,color: AppColor
                                        .greyColor,),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(
                                          color: AppColor.greyColor.withOpacity(0.4)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColor
                                            .greyColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        controllers['startDate']!.text = DateFormat('yyyy-MM-dd').format(picked);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(10.h),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Start Time"),
                                  Gap(10.h),
                                  SizedBox(
                                    height: 50.h,
                                    child: TextField(
                                      controller: controllers['startTime'],
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        // hintText: '--:--',
                                        // labelText:  StringConstant.startTime,
                                        suffixIcon: Icon(Icons.access_time,size: 20.sp, color: AppColor
                                            .greyColor,),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(
                                              color: AppColor.greyColor.withOpacity(0.4)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: const BorderSide(
                                            color: AppColor
                                                .greyColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        TimeOfDay? time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            controllers['startTime']!.text = _formatTime(time);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Gap(10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("End Time"),
                                  Gap(10.h),
                                  SizedBox(
                                    height: 50.h,
                                    child: TextField(
                                      controller: controllers['endTime'],
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        // hintText: '--:--',
                                        // labelText: StringConstant.endTime,
                                        suffixIcon: Icon(Icons.access_time,size: 20.sp, color: AppColor
                                            .greyColor,),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(
                                              color: AppColor.greyColor.withOpacity(0.4)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: const BorderSide(
                                            color: AppColor
                                                .greyColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        TimeOfDay? time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            controllers['endTime']!.text = _formatTime(time);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Gap(16.h),
              // OutlinedButton.icon(
              //   onPressed: _addNewDateTimeFieldSet,
              //   icon: Icon(Icons.add),
              //   label: Text("Add More Dates"),
              //   style: OutlinedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              //   ),
              // ),
              InkWell(
                onTap: _addNewDateTimeFieldSet,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.add_circle_outline, size: 28.sp,),
                    Gap(10.w),
                    const Text("Add more dates")
                  ],
                ),
              ),
              Gap(20.h),
              CommonFooterText(
                onNextTap: () async {
                  // Process each date set individually
                  for (var controllers in _eventCubit.dateTimeControllers) {
                    // Only submit if at least some data is entered
                    if (controllers['startDate']!.text.isNotEmpty ) {

                      Map<String, String> dateTimeMap = {
                        "dates-model-ryhsvq0i-start_date": controllers['startDate']!.text.trim(),
                        "dates-model-ryhsvq0i-start_time": controllers['startTime']!.text.trim(),
                        "dates-model-ryhsvq0i-end_time": controllers['endTime']!.text.trim(),
                      };

                      // Replace empty strings with an empty value that your API accepts
                      dateTimeMap.updateAll((key, value) => value.isEmpty ? "" : value);

                      await _eventCubit.updateEventDate(widget.eventId ?? '', dateTimeMap);
                    }
                  }

                  widget.onNext();
                },
                onBackTap: widget.onBack,
              ),
              Gap(20.h),
              Guideline(title: StringConstant.guideline, points: [
                StringConstant.guidelineDate,
                StringConstant.guidelineAddMore,
                StringConstant.guidelineVisitorDate,
              ]),
              Gap(20.h)
            ],
          );
        }
      ),
    );
  }
}