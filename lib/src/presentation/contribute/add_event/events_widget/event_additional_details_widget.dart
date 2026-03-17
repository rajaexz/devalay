import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_state.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../create/create_temple/widget/temple_complete_screen.dart';
import '../../../create/widget/common_guideline_text.dart';
import '../../widget/common_footer_text.dart';

class EventAdditionalDetailsWidget extends StatefulWidget {
  const EventAdditionalDetailsWidget(
      {super.key, required this.onNext, this.onBack, this.eventId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? eventId;

  @override
  State<EventAdditionalDetailsWidget> createState() =>
      _EventAdditionalDetailsWidgetState();
}

class _EventAdditionalDetailsWidgetState
    extends State<EventAdditionalDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeEventCubit, ContributeEventState>(
        builder: (context, state) {
      final eventcubit = context.read<ContributeEventCubit>();
      return Form(
        key: eventcubit.eventDetailsFormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CommonTextfield(
                title: StringConstant.howToCelebrate,
                controller: eventcubit.celebrateController,
                maxLines: 3,
              ),
              Gap(20.h),
              CommonTextfield(
                title: StringConstant.dos,
                controller: eventcubit.dosController,
                maxLines: 5,
              ),
              Gap(20.h),
              CommonTextfield(
                title: StringConstant.donts,
                controller: eventcubit.dontsController,
                maxLines: 5,
              ),
              CommonFooterText(
                onNextTap: () async {
                  await eventcubit
                      .updateEventAdditionalDetail(widget.eventId ?? '');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TempleCompleteScreen()),

                  );
                },
                onBackTap: widget.onBack,
                nextText: StringConstant.submit,
              ),
              Gap(20.h),
              Guideline(title: StringConstant.guideline, points: [
                StringConstant.guidelineEventCelebrate,
                StringConstant.guidelineEventDo,
                StringConstant.guidelineEventDont,
                StringConstant.spiritualLanguage
              ]),
              Gap(20.h)
            ],
          ),
        ),
      );
    });
  }
}
