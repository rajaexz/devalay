import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_state.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../create/widget/common_guideline_text.dart';
import '../../widget/common_footer_text.dart';

class DevInfoWidget extends StatefulWidget {
  const DevInfoWidget({super.key, required this.onNext, required this.devId});
  final void Function(String eventId) onNext;
  final String? devId;

  @override
  State<DevInfoWidget> createState() => _DevInfoWidgetState();
}

class _DevInfoWidgetState extends State<DevInfoWidget> {
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
    return BlocConsumer<ContributeDevCubit, ContributeDevState>(
      listener: (context, state) {
        if (state is ContributeDevLoaded &&
            (state.devId?.isNotEmpty ?? false)) {
          widget.onNext(state.devId!);
        }
      },
      builder: (context, state) {
        final devCubit = context.read<ContributeDevCubit>();
        return Form(
          key: devCubit.devInfoFormKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                CommonTextfield(
                  isRequired: true,
                  title: StringConstant.title,
                  controller: devCubit.devTitleController,
                  focusNode: _focusNodeTitle,
                  validator: devCubit.devTitleValidator,
                ),
                Gap(20.h),
                CommonTextfield(
                  title: StringConstant.subtitle,
                  controller: devCubit.devSubTitleController,
                  focusNode: _focusNodeSubtitle,
                ),
                Gap(20.h),
                CommonTextfield(
                  title: StringConstant.about,
                  controller: devCubit.devAboutController,
                  maxLines: 5,
                  focusNode: _focusNodeAbout,
                ),
                CommonFooterText(
                  calledFrom: 'first',
                  onNextTap: widget.devId != null
                      ? () async {
                          if(devCubit.devInfoFormKey.currentState!.validate()){
                            await devCubit.updateDev(widget.devId!);
                          }
                        }
                      : () async {
                          await devCubit.createDev();
                        },
                ),
                Gap(20.h),
                Guideline(title: StringConstant.guideline, points: [
                  StringConstant.guidelineGod,
                  StringConstant.guidelineGodAbout,
                  StringConstant.guidelineGodInformation,
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
