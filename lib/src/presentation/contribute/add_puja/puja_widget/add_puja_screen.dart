import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_cubit.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/puja_widget/puja_complete_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/puja_widget/puja_god_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/puja_widget/puja_info_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/puja_widget/puja_photo_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/puja_widget/puja_purpose_widget.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/colors.dart';
import '../../widget/common_header_text.dart';

class AddPujaScreen extends StatefulWidget {
  const AddPujaScreen(
      {super.key, this.pujaId, this.calledFrom, this.initialIndex});
  final String? calledFrom;
  final String? pujaId;
  final int? initialIndex;

  @override
  State<AddPujaScreen> createState() => _AddPujaScreenState();
}

class _AddPujaScreenState extends State<AddPujaScreen> {
  late int _currentIndex = 0;
  double _progress = 25;
  String? _pujaId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;


    final isReview = widget.calledFrom == 'review';
    context.read<ContributePujaCubit>().fetchSingleContributePujaData(
          widget.pujaId ?? '',
          value: isReview ? 'true' : 'false',
        );
  }

  final List<String> _titles = [
    "${StringConstant.pujas} ${StringConstant.name}",
    StringConstant.tabPhotos,
    StringConstant.gods,
    'Purpose & Procedure',
    ''
  ];

  List<Widget> _contents() {
     final isEdit = widget.calledFrom == 'EditTemple';
    final usableTempleId = isEdit ? widget.pujaId : _pujaId;
 
     List<Widget> steps = [
      PujaInfoWidget(
        onNext: (value) {
          setState(() {
            _pujaId = value;
            _onNext();
          });
        },
        pujaId: widget.calledFrom != 'EditPuja' ? _pujaId : widget.pujaId,
      ),
     ];
      if (usableTempleId != null) {


      }
     
          steps.addAll([  PujaPhotoWidget(
        onNext: _onNext,
        onBack: _onBack,
        pujaId: widget.calledFrom != 'EditPuja' ? _pujaId : widget.pujaId,
      ),
      PujaGodWidget(
        onNext: _onNext,
        onBack: _onBack,
        pujaId: widget.calledFrom != 'EditPuja' ? _pujaId : widget.pujaId,
      ),
      PujaPurposeWidget(
        onNext: _onNext,
        onBack: _onBack,
        pujaId: widget.calledFrom != 'EditPuja' ? _pujaId : widget.pujaId,
      ),


      ]);
    
 steps.add(  PujaCompleteScreen(
  pujaId: widget.pujaId ?? '',
  calledFrom: widget.calledFrom,
 ));
     return steps;
  }

  void _onNext() {
    int totalSteps = _contents().length - 1;
    if (_currentIndex < _contents().length - 1) {
      setState(() {
        _currentIndex++;
        _progress = ((_currentIndex + 1) / totalSteps) * 100;
      });
    }
  }

  void _onBack() {
    int totalSteps = _contents().length - 1;
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _progress = ((_currentIndex + 1) / totalSteps) * 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalSteps = _contents().length - 1;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.whiteColor
                  : AppColor.blackColor),
          onPressed: () {
               final isReview = widget.calledFrom == 'review';
              context.read<ContributePujaCubit>().fetchSingleContributePujaData(
                    widget.pujaId ?? '',
                    value: isReview ? 'true' : 'false',
                  );

              AppRouter.pop();
          },
        ),
        elevation: 0,
        backgroundColor: AppColor.appbarBgColor,
        title: Text(
          widget.calledFrom != 'EditPuja' ? "Add Puja" : "Edit Puja",
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
