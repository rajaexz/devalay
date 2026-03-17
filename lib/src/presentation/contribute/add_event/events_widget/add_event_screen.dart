import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../application/contribution/contribution_event/contribution_event_cubit.dart';
import '../../../create/widget/common_header_text.dart';
import 'event_additional_details_widget.dart';
import 'event_address_widget.dart';
import 'event_dates_widget.dart';
import 'event_god_widget.dart';
import 'event_info_widget.dart';
import 'event_photo_widget.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen(
      {super.key, this.eventId, this.calledFrom, this.initialIndex});
  final String? calledFrom;
  final String? eventId;
  final int? initialIndex;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late int _currentIndex = 0;
  int totalStep = 6;
  String? _eventId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;

    final isReview = widget.calledFrom == 'review';
    if (widget.eventId != null) {
      context.read<ContributeEventCubit>().fetchSingleContributeEventData(
          widget.eventId ?? '',
          value: isReview ? 'true' : 'false');
    }

    if (widget.calledFrom == 'EditTemple') {
      context.read<ContributeEventCubit>().initializeForEditMode();
    } else {
      context.read<ContributeEventCubit>().initializeForAddMode();
    }
  }

  final List<String> _titles = [
    StringConstant.name,
    StringConstant.tabPhotos,
    StringConstant.location,
    "${StringConstant.gods} ${StringConstant.andGoddesses}",
    StringConstant.date,
    StringConstant.additionalDetails,
    ''
  ];

  List<Widget> _contents() {
    final isEdit = widget.calledFrom == 'EditEvent';
    final usableEventId = isEdit ? widget.eventId : _eventId;

    List<Widget> steps = [
      EventInfoWidget(
        onNext: (value) {
          setState(() {
            _eventId = value;
            _onNext();
          });
        },
        eventId: usableEventId,
      ),
    ];

    if (usableEventId != null) {
      steps.addAll([
        EventPhotoWidget(
          onNext: _onNext,
          onBack: _onBack,
          eventId: usableEventId,
        ),
        EventAddressWidget(
          onNext: _onNext,
          onBack: _onBack,
          eventId: usableEventId,
        ),
        EventGodWidget(
          onNext: _onNext,
          onBack: _onBack,
          eventId: usableEventId,
        ),
        EventDatesWidget(
          onNext: _onNext,
          onBack: _onBack,
          eventId: usableEventId,
        ),
        EventAdditionalDetailsWidget(
          onNext: _onNext,
          onBack: _onBack,
          eventId: usableEventId,
        ),
        // TempleCompleteScreen(
        //   templeId: usableEventId,
        // ),
      ]);
    }

    return steps;
  }

  void _onNext() {
    if (_currentIndex < _contents().length - 1) {
      setState(() {
        _currentIndex++;
        totalStep;
      });
    }
  }

  void _onBack() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        totalStep;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final usableEventId =
        widget.calledFrom == 'EditEvent' ? widget.eventId : _eventId;

    if (_currentIndex > 0 && usableEventId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.blackColor),
          onPressed: () {
            final isReview = widget.calledFrom == 'review';
            context.read<ContributeEventCubit>().fetchSingleContributeEventData(
                  widget.eventId ?? '',
                  value: isReview ? 'true' : 'false',
                );

            AppRouter.pop();
          },
        ),
        leadingWidth: 30,
        backgroundColor: AppColor.whiteColor,
        title: Text(
          widget.calledFrom != 'EditEvent'
              ? "${StringConstant.tabAdd.toUpperCase()} ${StringConstant.events.toUpperCase()}"
              : "${StringConstant.edit.toUpperCase()} ${StringConstant.events.toUpperCase()}",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: AppColor.blackColor),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentIndex < totalStep)
              CommonsHeaderText(
                  title: _titles[_currentIndex],
                  currentStep: _currentIndex + 1,
                  totalSteps: totalStep),
            Expanded(child: _contents()[_currentIndex])
          ],
        ),
      ),
    );
  }
}
