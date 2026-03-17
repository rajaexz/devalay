import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/contribute/add_festival/festival_widget/festival_about_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_festival/festival_widget/festival_god_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_festival/festival_widget/festival_info_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_festival/festival_widget/festival_photo_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_festival/festival_widget/festival_why_we_celebrate_widget.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../application/contribution/contribution_festival/contribution_festival_cubit.dart';
import '../../../core/utils/colors.dart';
import '../../widget/common_header_text.dart';
import 'festival_complete_screen.dart';
import 'festival_dates_widget.dart';

class AddFestivalScreen extends StatefulWidget {
  const AddFestivalScreen(
      {super.key, this.calledFrom, this.festivalId, this.initialIndex});
  final String? calledFrom;
  final String? festivalId;
  final int? initialIndex;

  @override
  State<AddFestivalScreen> createState() => _AddFestivalScreenState();
}

class _AddFestivalScreenState extends State<AddFestivalScreen> {
  late int _currentIndex = 0;
  double _progress = 16.6;
  String? _festivalId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    if (widget.festivalId != null) {
      (widget.calledFrom == 'review')
          ? context
              .read<ContributeFestivalCubit>()
              .fetchSingleContributeFestivalData(widget.festivalId ?? '',
                  value: 'true')
          : context
              .read<ContributeFestivalCubit>()
              .fetchSingleContributeFestivalData(widget.festivalId ?? '',
                  value: 'false');
    }
  }

  final List<String> _titles = [
    '${StringConstant.festival} ${ StringConstant.name}',
   StringConstant.tabAdd,
    '${StringConstant.gods} / ${StringConstant.goddesses}',
    
    StringConstant.date,
    StringConstant.aboutOrigin,
    StringConstant.weCelebrate,
    ''
  ];

  List<Widget> _contents() {
    return [
      FestivalInfoWidget(
        onNext: (value) {
          setState(() {
            _festivalId = value;
            _onNext();
          });
        },
        festivalId: widget.calledFrom != 'EditFestival'
            ? _festivalId
            : widget.festivalId,
      ),
      FestivalPhotoWidget(
        onNext: _onNext,
        onBack: _onBack,
        festivalId: widget.calledFrom != 'EditFestival'
            ? _festivalId
            : widget.festivalId,
      ),
      FestivalGodWidget(
        onNext: _onNext,
        onBack: _onBack,
        festivalId: widget.calledFrom != 'EditFestival'
            ? _festivalId
            : widget.festivalId,
      ),
      FestivalDatesWidget(
        onNext: _onNext,
        onBack: _onBack,
        festivalId: widget.calledFrom != 'EditFestival'
            ? _festivalId
            : widget.festivalId,
      ),
      FestivalAboutWidget(
          onNext: _onNext,
          onBack: _onBack,
          festivalId: widget.calledFrom != 'EditFestival'
              ? _festivalId
              : widget.festivalId),
      FestivalWhyWeCelebrateWidget(
          onNext: _onNext,
          onBack: _onBack,
          festivalId: widget.calledFrom != 'EditFestival'
              ? _festivalId
              : widget.festivalId),
      const FestivalCompleteScreen(),
    ];
  }

  void _onNext() {
    int totalSteps = _contents().length - 1;
    if (_currentIndex < _contents().length - 1) {
      setState(() {
        _currentIndex++;
        _progress = double.parse(((_currentIndex + 1) / totalSteps * 100).toStringAsFixed(2));

      });
    }
  }

  void _onBack() {
    int totalSteps = _contents().length - 1;
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _progress = double.parse(((_currentIndex + 1) / totalSteps * 100).toStringAsFixed(2));

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalSteps = _contents().length - 1;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.appbarBgColor,
            leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.whiteColor
                  : AppColor.blackColor),
          onPressed: () {
               final isReview = widget.calledFrom == 'review';
              context.read<ContributeFestivalCubit>().fetchSingleContributeFestivalData(
                    widget.festivalId ?? '',
                    value: isReview ? 'true' : 'false',
                  );

              AppRouter.pop();
          },
        ),
        title: Text(
          widget.calledFrom != 'EditFestival'
              ? "Add Festival"
              : "Edit Festival",
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(color: AppColor.whiteColor),
        ),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background/add_temple_bg.png"),
                fit: BoxFit.cover)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 30.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentIndex < totalSteps)
                CommonHeaderText(
                    title: _titles[_currentIndex], progress: _progress),
              Expanded(child: _contents()[_currentIndex])
            ],
          ),
        ),
      ),
    );
  }
}
