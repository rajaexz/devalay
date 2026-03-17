import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/create/widget/common_ques_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../create/widget/common_guideline_text.dart';
import '../../widget/common_footer_text.dart';
import '../../widget/common_textfield.dart';

class TempleEtymologyWidget extends StatefulWidget {
  const TempleEtymologyWidget(
      {super.key,
      required this.onNext,
      this.onBack,
      this.templeId,
      this.calledFrom});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? templeId;
  final String? calledFrom;

  @override
  State<TempleEtymologyWidget> createState() => _TempleEtymologyWidgetState();
}

class _TempleEtymologyWidgetState extends State<TempleEtymologyWidget> {
  bool showGeneratedField = false;
  bool isGeneratingWithAI = false;
  final firstController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        final templecubit = context.read<ContributeTempleCubit>();
        return SingleChildScrollView(
          child: Form(
            key: templecubit.templeEtymologyFromKey,
            child: Column(
              children: [
                const CommonQuesText(points: [
                  TempleString.templeEtymologyFirst,
                  TempleString.templeEtymologySecond,
                  TempleString.templeEtymologyThird,
                ]),
                CommonTextfield(
                  maxLines: 5,
                  title:'',
                  controller: templecubit.fourthEtymologyController,
                ),
                CommonFooterText(
                  onNextTap: () async {
                    await templecubit.updateTempleEtymology(widget.templeId!);
                    widget.onNext();
                  },
                  onBackTap: widget.onBack,
                ),
                Gap(20.h),
                Guideline(title: StringConstant.guideline, points: [
                  StringConstant.templeQuestionEtymology,
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
