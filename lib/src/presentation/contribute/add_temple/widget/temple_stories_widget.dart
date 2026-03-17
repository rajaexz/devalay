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

class TempleStoriesWidget extends StatefulWidget {
  const TempleStoriesWidget(
      {super.key,
      required this.onNext,
      this.onBack,
      this.templeId,
      this.calledFrom});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? calledFrom;
  final String? templeId;

  @override
  State<TempleStoriesWidget> createState() => _TempleStoriesWidgetState();
}

class _TempleStoriesWidgetState extends State<TempleStoriesWidget> {
  bool showGeneratedField = false;
  bool isGeneratingWithAI = false;
  final firstController = TextEditingController();
  final generatedController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeFirstStory = FocusNode();
  final FocusNode _focusNodeSecondStory = FocusNode();
  final FocusNode _focusNodeThirdStory = FocusNode();
  final FocusNode _focusNodeFourthStory = FocusNode();

  @override
  void initState() {
    print("===================== this is the temple id ${widget.calledFrom}");
    super.initState();
    _focusNodeFirstStory
        .addListener(() => _scrollToFocusedField(_focusNodeFirstStory));
    _focusNodeSecondStory
        .addListener(() => _scrollToFocusedField(_focusNodeSecondStory));
    _focusNodeThirdStory
        .addListener(() => _scrollToFocusedField(_focusNodeThirdStory));
    _focusNodeFourthStory
        .addListener(() => _scrollToFocusedField(_focusNodeFourthStory));
  }

  void _scrollToFocusedField(FocusNode focusNode) {
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
    _scrollController.dispose();
    _focusNodeFirstStory.dispose();
    _focusNodeSecondStory.dispose();
    _focusNodeThirdStory.dispose();
    _focusNodeFourthStory.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        final templecubit = context.read<ContributeTempleCubit>();
        return SingleChildScrollView(
          controller: _scrollController,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: templecubit.templeStoryFromKey,
            child: Column(children: [
              const CommonQuesText(points: [
                TempleString.templeStoriesFirst,
                TempleString.templeStoriesSecond,
                TempleString.templeStoriesThird,
                TempleString.templeStoriesFourth,
              ]),
              CommonTextfield(
                maxLines: 5,
                title:'',
                controller: templecubit.fifthStoryController,
              ),
              CommonFooterText(
                onNextTap: () async {
                  await templecubit.updateTempleStories(widget.templeId!);
                  widget.onNext();
                },
                onBackTap: widget.onBack,
              ),
              Gap(20.h),
              Guideline(title: StringConstant.guideline, points: [
                StringConstant.templeQuestionStory,
                StringConstant.templeAnswerHistory,
              ]),
              Gap(10.h)
            ]),
          ),
        );
      },
    );
  }
}
