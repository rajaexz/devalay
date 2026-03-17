import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../application/contribution/contribution_festival/contribution_festival_cubit.dart';
import '../../../../application/contribution/contribution_festival/contribution_festival_state.dart';
import '../../widget/common_footer_text.dart';

class FestivalDatesWidget extends StatefulWidget {
  const FestivalDatesWidget(
      {super.key, required this.onNext, this.onBack, this.festivalId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? festivalId;

  @override
  State<FestivalDatesWidget> createState() => _FestivalDatesWidgetState();
}

class _FestivalDatesWidgetState extends State<FestivalDatesWidget> {
  List<Map<String, TextEditingController>> dateTimeControllers = [];


  @override
  void initState() {
    super.initState();
    _addNewDateTimeFieldSet();
  }

  void _addNewDateTimeFieldSet() {
    final newSet = {
      'startDate': TextEditingController(),
      'startTime': TextEditingController(),
      'endDate': TextEditingController(),
      'endTime': TextEditingController(),
    };

    setState(() {
      dateTimeControllers.add(newSet);
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String generateRandomKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final now = DateTime.now().millisecondsSinceEpoch;
    return List.generate(8, (index) => chars[(now + index) % chars.length]).join();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeFestivalCubit, ContributeFestivalState>(
        builder: (context, state) {
      final festivalCubit = context.read<ContributeFestivalCubit>();
      return Column(
        children: [
          Column(
            children: dateTimeControllers.asMap().entries.map((entry) {
         
              final controllers = entry.value;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: controllers['startDate'],
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'yyyy-mm-dd',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                controllers['startDate']!.text = DateFormat('yyyy-MM-dd').format(picked);
                              }
                            },
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: controllers['startTime'],
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: '--:--',
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            onTap: () async {
                              TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                controllers['startTime']!.text = _formatTime(time);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: controllers['endDate'],
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'yyyy-mm-dd',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                controllers['endDate']!.text = DateFormat('yyyy-MM-dd').format(picked);
                              }
                            },
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: controllers['endTime'],
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: '--:--',
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            onTap: () async {
                              TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                controllers['endTime']!.text = _formatTime(time);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                ],
              );
            }).toList(),
          ),

          TextButton.icon(
            onPressed: _addNewDateTimeFieldSet,
            icon: const Icon(Icons.add),
            label: const Text("Add More"),
          ),
          CommonFooterText(
            onNextTap: () async {
          
              for (var set in dateTimeControllers) {
                String key = "dates-model-${generateRandomKey()}";
                Map<String, String> dateTimeMap = {
                  "$key-start_date": set['startDate']!.text.trim(),
                  "$key-start_time": set['startTime']!.text.trim(),
                  "$key-end_date": set['endDate']!.text.trim(),
                  "$key-end_time": set['endTime']!.text.trim(),
                };

                print("Set: $dateTimeMap");

                festivalCubit.updateFestivalDate(widget.festivalId ?? '',
                    dateTimeMap);              }
              widget.onNext();
            },
            onBackTap: widget.onBack,
          ),
        ],
      );
    });
  }
}








