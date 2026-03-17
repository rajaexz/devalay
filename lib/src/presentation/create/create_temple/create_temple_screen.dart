import 'package:devalay_app/src/presentation/create/widget/common_header_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../application/contribution/contribution_temple/contribution_temple_cubit.dart';
import '../../../core/router/router.dart';
import '../../contribute/add_temple/widget/temple_address_widget.dart';
import '../../contribute/add_temple/widget/temple_architecture_widget.dart';
import '../../contribute/add_temple/widget/temple_etymology_widget.dart';
import '../../contribute/add_temple/widget/temple_god_widget.dart';
import '../../contribute/add_temple/widget/temple_history_widget.dart';
import '../../contribute/add_temple/widget/temple_info_widget.dart';
import '../../contribute/add_temple/widget/temple_photo_widget.dart';
import '../../contribute/add_temple/widget/temple_stories_widget.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/colors.dart';

class CreateTemple extends StatefulWidget {
  const CreateTemple({
    super.key,
    this.templeId,
    this.calledFrom,
    this.initialIndex,
    this.governingId,
  });

  final String? calledFrom;
  final String? templeId;
  final int? initialIndex;
  final String? governingId;

  @override
  State<CreateTemple> createState() => _CreateTempleState();
}

class _CreateTempleState extends State<CreateTemple> {
  late int _currentIndex = 0;
  int totalStep = 8;
  String? _templeId;
  String? _governingId;

  final List<String> _titles = [
    (StringConstant.name),
    StringConstant.tabPhotos,
    StringConstant.location,
    "${StringConstant.gods} ${StringConstant.andGoddesses}",
    "${StringConstant.temples} ${StringConstant.tabHistory}",
    "${StringConstant.legend}/${StringConstant.tabStories}",
    "${StringConstant.tabEtymology}/${StringConstant.naming}",
    "${StringConstant.tabArchitecture}/${StringConstant.design}",
    ''
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;

    final isReview = widget.calledFrom == 'review';
    context.read<ContributeTempleCubit>().fetchSingleContributTempleData(
          widget.templeId ?? '',
          // value: isReview ? 'true' : 'false',
        );

    if (widget.calledFrom == 'EditTemple') {
      context.read<ContributeTempleCubit>().initializeForEditMode();
    } else {
      context.read<ContributeTempleCubit>().initializeForAddMode();
    }
  }

  List<Widget> _contents() {
    final isEdit = widget.calledFrom == 'EditTemple';
    final usableTempleId = isEdit ? widget.templeId : _templeId;
    final usableGoverningId = isEdit ? widget.governingId : _governingId;

    List<Widget> steps = [
      TempleInfoWidget(
        onNext: (value, governingId) {
          setState(() {
            _templeId = value;
            _governingId = governingId;
            _onNext();
          });
        },
        templeId: usableTempleId,
        governingId: usableGoverningId,
      ),
    ];

    if (usableTempleId != null) {
      steps.addAll([
        TemplePhotoWidget(
          calledFrom: widget.calledFrom,
          onNext: _onNext,
          onBack: _onBack,
          templeId: usableTempleId,
        ),
        TempleAddressWidget(
          onNext: _onNext,
          onBack: _onBack,
          templeId: usableTempleId,
        ),
        TempleGodWidget(
          onNext: _onNext,
          onBack: _onBack,
          templeId: usableTempleId,
        ),
        TempleHistoryWidget(
          calledFrom: widget.calledFrom,
          onNext: _onNext,
          onBack: _onBack,
          templeId: usableTempleId,
        ),
        TempleStoriesWidget(
          calledFrom: widget.calledFrom,
          onNext: _onNext,
          onBack: _onBack,
          templeId: usableTempleId,
        ),
        TempleEtymologyWidget(
          onNext: _onNext,
          calledFrom: widget.calledFrom,
          onBack: _onBack,
          templeId: usableTempleId,
        ),
        TempleArchitectureWidget(
          calledFrom: widget.calledFrom,
          onNext: _onNext,
          onBack: _onBack,
          templeId: usableTempleId,
        ),
      ]);
    }

    // steps.add(TempleCompleteScreen(
    //   templeId: usableTempleId,
    //   governingId: usableGoverningId,
    // ));
    return steps;
  }

  void _onNext() {
    final totalSteps = _contents().length - 1;
    if (_currentIndex < totalSteps) {
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
    final contentWidgets = _contents();

    final usableTempleId =
        widget.calledFrom == 'EditTemple' ? widget.templeId : _templeId;

    if (_currentIndex > 0 && usableTempleId == null) {
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
          backgroundColor: AppColor.whiteColor,
          leadingWidth: 30,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColor.blackColor),
            onPressed: () {
              final isReview = widget.calledFrom == 'review';
              context
                  .read<ContributeTempleCubit>()
                  .fetchSingleContributTempleData(
                    widget.templeId ?? '',
                    // value: isReview ? 'true' : 'false',
                  );
              AppRouter.pop();
            },
          ),
          title: Text(
            widget.calledFrom != 'EditTemple'
                ? '${StringConstant.tabAdd.toUpperCase()} ${StringConstant.temple.toUpperCase()}'
                : '${StringConstant.edit.toUpperCase()} ${StringConstant.temple.toUpperCase()}',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppColor.blackColor),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentIndex < totalStep)
                CommonsHeaderText(
                    title: _titles[_currentIndex],
                    currentStep: _currentIndex + 1,
                    totalSteps: totalStep),
              Expanded(
                child: contentWidgets[_currentIndex],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
