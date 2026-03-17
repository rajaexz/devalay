import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/contribute/add_dev/devs_widget/dev_info_widget.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/colors.dart';
import '../../../create/widget/common_header_text.dart';
import '../../../create/create_temple/widget/temple_complete_screen.dart';
import 'dev_aarti_widget.dart';
import 'dev_avatar_widget.dart';
import 'dev_photo_widget.dart';

class AddDevScreen extends StatefulWidget {
  const AddDevScreen(
      {super.key, this.devId, this.calledFrom, this.initialIndex});
  final String? calledFrom;
  final String? devId;
  final int? initialIndex;

  @override
  State<AddDevScreen> createState() => _AddDevScreenState();
}

class _AddDevScreenState extends State<AddDevScreen> {
  late int _currentIndex = 0;
  int totalStep = 4;
  String? _devId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    final isReview = widget.calledFrom == 'review';
    if (widget.devId != null) {
      context.read<ContributeDevCubit>().fetchSingleContributeDevData(
          widget.devId ?? '',
          value: isReview ? 'true' : 'false');
    }
    if (widget.calledFrom == 'EditTemple') {
      context.read<ContributeDevCubit>().initializeForEditMode();
    } else {
      context.read<ContributeDevCubit>().initializeForAddMode();
    }
  }

  final List<String> _titles = [
    (StringConstant.name),
    StringConstant.tabPhotos,
    StringConstant.avatar,
    StringConstant.arti,
    ''
  ];

  List<Widget> _contents() {
    final isEdit = widget.calledFrom == 'EditDev';
    final usableDevId = isEdit ? widget.devId : _devId;
    List<Widget> steps = [
      DevInfoWidget(
        onNext: (value) {
          setState(() {
            _devId = value;
            _onNext();
          });
        },
        devId: usableDevId,
      ),
    ];

    if (usableDevId != null) {
      steps.addAll([
        DevPhotoWidget(
          onNext: _onNext,
          onBack: _onBack,
          devId: widget.calledFrom != 'EditDev' ? _devId : widget.devId,
        ),
        DevAvatarWidget(
            onNext: _onNext,
            onBack: _onBack,
            devId: widget.calledFrom != 'EditDev' ? _devId : widget.devId),
        DevAartiWidget(
            onNext: _onNext,
            onBack: _onBack,
            devId: widget.calledFrom != 'EditDev' ? _devId : widget.devId),
        TempleCompleteScreen(
          templeId: widget.calledFrom != 'EditDev' ? _devId : widget.devId,
        ),
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
    final usableDevId = widget.calledFrom == 'EditDev' ? widget.devId : _devId;

    if (_currentIndex > 0 && usableDevId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          leadingWidth: 30,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColor.blackColor),
            onPressed: () {
              final isReview = widget.calledFrom == 'review';
              context.read<ContributeDevCubit>().fetchSingleContributeDevData(
                    widget.devId ?? '',
                    value: isReview ? 'true' : 'false',
                  );

              AppRouter.pop();
            },
          ),
          backgroundColor: AppColor.whiteColor,
          title: Text(
            widget.calledFrom != 'EditDev' ? "ADD DEV" : "EDIT DEV",
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
      ),
    );
  }
}
