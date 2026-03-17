import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_state.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../create/widget/common_guideline_text.dart';
class EventInfoWidget extends StatefulWidget {
  const EventInfoWidget({
    super.key,
    required this.onNext,
    required this.eventId,
  });

  final void Function(String eventId) onNext;
  final String? eventId;

  @override
  State<EventInfoWidget> createState() => _EventInfoWidgetState();
}

class _EventInfoWidgetState extends State<EventInfoWidget> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeTitle = FocusNode();
  final FocusNode _focusNodeSubtitle = FocusNode();
  final FocusNode _focusNodeAbout = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNodeTitle.addListener(() => _scrollToFocusedField(_focusNodeTitle));
    _focusNodeSubtitle.addListener(() => _scrollToFocusedField(_focusNodeSubtitle));
    _focusNodeAbout.addListener(() => _scrollToFocusedField(_focusNodeAbout));
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(_scrollController.position.extentBefore,
            duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNodeTitle.dispose();
    _focusNodeSubtitle.dispose();
    _focusNodeAbout.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributeEventCubit, ContributeEventState>(
      listener: (context, state) {
        if (state is ContributeEventLoaded && state.eventId != null && state.eventId!.isNotEmpty) {
          widget.onNext(state.eventId!);
        }
      },
      builder: (context, state) {
        final eventCubit = context.read<ContributeEventCubit>();

        return Form(
          key: eventCubit.eventInfoFormKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                CommonTextfield(
                    isRequired:true,
                  title: StringConstant.title,
                  controller: eventCubit.eventTitleController,
                  focusNode: _focusNodeTitle,
                  validator: eventCubit.eventTitleValidator,
                ),
                Gap(20.h),
                CommonTextfield(
                  title: StringConstant.subtitle,
                  controller: eventCubit.eventSubTitleController,
                  validator: eventCubit.eventSubTitleValidator,
                  focusNode: _focusNodeSubtitle,
                ),
                Gap(20.h),
                CommonTextfield(
                  title:StringConstant.about,
                  controller: eventCubit.eventAboutController,
                  validator: eventCubit.eventAboutValidator,
                  maxLines: 5,
                  focusNode: _focusNodeAbout,
                ),
                CommonFooterText(
                  calledFrom:'first',
                  onNextTap: () async {
                    final formState = eventCubit.eventInfoFormKey.currentState;
                    if (formState != null && formState.validate()) {
                      if (widget.eventId != null) {
                        await eventCubit.updateEvent(widget.eventId!);
                      } else {
                        await eventCubit.createEvent();
                      }
                    }
                  },
                ),
                Gap(20.h),
                Guideline(title: StringConstant.guideline, points: [
                  StringConstant.bannerImageGuideline,
                  StringConstant.galleryImageGuideline,
                  StringConstant.imageHighQuality,
                  StringConstant.avoidInappropriateImage,
                ]),
                Gap(20.h)
              ],
            ),
          ),
        );
      },
    );
  }
}
