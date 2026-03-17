import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../create/widget/common_guideline_text.dart';
import '../../../create/widget/common_ques_text.dart';
import '../../widget/common_textfield.dart';

class TempleHistoryWidget extends StatefulWidget {
  const TempleHistoryWidget(
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
  State<TempleHistoryWidget> createState() => _TempleHistoryWidgetState();
}

class _TempleHistoryWidgetState extends State<TempleHistoryWidget> {
  bool showGeneratedField = false;
  bool isGeneratingWithAI = false;
  final firstController = TextEditingController();
  final generatedController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeFirstHistory = FocusNode();
  final FocusNode _focusNodeSecondHistory = FocusNode();
  final FocusNode _focusNodeThirdHistory = FocusNode();
  final FocusNode _focusNodeFourthHistory = FocusNode();
  final FocusNode _focusNodeFifthHistory = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNodeFirstHistory
        .addListener(() => _scrollToFocusField(_focusNodeFirstHistory));
    _focusNodeSecondHistory
        .addListener(() => _scrollToFocusField(_focusNodeSecondHistory));
    _focusNodeThirdHistory
        .addListener(() => _scrollToFocusField(_focusNodeThirdHistory));
    _focusNodeFourthHistory
        .addListener(() => _scrollToFocusField(_focusNodeFourthHistory));
    _focusNodeFifthHistory
        .addListener(() => _scrollToFocusField(_focusNodeFifthHistory));
  }

  void _scrollToFocusField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(_scrollController.position.extentBefore,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _focusNodeFirstHistory.dispose();
    _focusNodeSecondHistory.dispose();
    _focusNodeThirdHistory.dispose();
    _focusNodeFourthHistory.dispose();
    _focusNodeFifthHistory.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templecubit = context.read<ContributeTempleCubit>();
    print("asdfdsfadsfasdfr ${templecubit.sixthHistoryController.text}");

    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: templecubit.templeHistoryFromKey,
            child: Column(
              children: [
                const CommonQuesText(points: [
                  TempleString.templeHistoryFirst,
                  TempleString.templeHistorySecond,
                  TempleString.templeHistoryThird,
                  TempleString.templeHistoryFourth,
                  TempleString.templeHistoryFifth,
                ]),
                // Gap(20.h),
                CommonTextfield(
                  maxLines: 5,
                    title:'',
                    controller: templecubit.sixthHistoryController,
                ),
                CommonFooterText(
                    onNextTap: () async {
                      await templecubit.updateTempleHistory(widget.templeId!);
                      widget.onNext();
                    },
                    onBackTap: widget.onBack),
                Gap(20.h),
                Guideline(title: StringConstant.guideline, points: [
                  StringConstant.templeQuestionHistory,
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
