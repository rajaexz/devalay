import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_festival/contribution_festival_cubit.dart';
import '../../../../application/contribution/contribution_festival/contribution_festival_state.dart';
import '../../widget/common_footer_text.dart';
import '../../widget/common_textfield.dart';

class FestivalWhyWeCelebrateWidget extends StatefulWidget {
  const FestivalWhyWeCelebrateWidget(
      {super.key, required this.onNext, this.onBack, this.festivalId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? festivalId;

  @override
  State<FestivalWhyWeCelebrateWidget> createState() =>
      _FestivalWhyWeCelebrateWidgetState();
}

class _FestivalWhyWeCelebrateWidgetState
    extends State<FestivalWhyWeCelebrateWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeFestivalCubit, ContributeFestivalState>(
        builder: (context, state) {
      final festivalCubit = context.read<ContributeFestivalCubit>();
      return Form(
        key: festivalCubit.festivalCelebrateFormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CommonTextfield(
                  title: 'Why we celebrate',
                  controller: festivalCubit.festivalCelebrateController,maxLines: 3,),
              Gap(20.h),
              CommonTextfield(
                  title: StringConstant.dos, controller: festivalCubit.festivalDosController, maxLines: 5,),
              Gap(20.h),
              CommonTextfield(
                  title: StringConstant.donts,
                  controller: festivalCubit.festivalDontsController,maxLines: 5,),
              CommonFooterText(
                onNextTap: () async {
                  await festivalCubit
                      .updateCelebrate(widget.festivalId ?? '');
                  widget.onNext();
                },
                onBackTap: widget.onBack,
                nextText: StringConstant.submit,
              )
            ],
          ),
        ),
      );
    });
  }
}
