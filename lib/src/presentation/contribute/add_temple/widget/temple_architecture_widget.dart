import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/create/widget/common_ques_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../create/create_temple/widget/temple_complete_screen.dart';
import '../../../create/widget/common_guideline_text.dart';
import '../../widget/common_footer_text.dart';
import '../../widget/common_textfield.dart';

class TempleArchitectureWidget extends StatefulWidget {
  const TempleArchitectureWidget(
      {super.key,
      required this.onNext,
      this.calledFrom,
      this.onBack,
      this.templeId});

  final void Function() onNext;
  final VoidCallback? onBack;
  final String? templeId;
  final String? calledFrom;

  @override
  State<TempleArchitectureWidget> createState() =>
      _TempleArchitectureWidgetState();
}

class _TempleArchitectureWidgetState extends State<TempleArchitectureWidget> {
  bool showGeneratedField = false;

  late final TextEditingController firstController;

  void safeSetState(Function() fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        final templeCubit = context.read<ContributeTempleCubit>();
        return SingleChildScrollView(
          child: Form(
            key: templeCubit.templeArchitectureFromKey,
            child: Column(
              children: [
                const CommonQuesText(points: [
                  TempleString.templeArchitectureFirst,
                  TempleString.templeArchitectureSecond,
                  TempleString.templeArchitectureThird,
                ]),
                CommonTextfield(
                  maxLines: 5,
                  title:'',
                  controller: templeCubit.fourthArchitectureController,
                ),
             CommonFooterText(
                  onNextTap: () async {
                    await templeCubit.updateTempleArchitecture(
                        widget.templeId!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TempleCompleteScreen()),

                    );
                  },
                  onBackTap: widget.onBack,
                ),
                Gap(20.h),
                Guideline(title: StringConstant.guideline, points: [
                  StringConstant.templeQuestionArchitecture,
                  StringConstant.templeAnswerHistory,
                ]),
                Gap(10.h)
              ],
            ),
          ),
        );
      },
    );
  }
}
