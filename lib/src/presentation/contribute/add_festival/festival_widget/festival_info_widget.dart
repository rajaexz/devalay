import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_festival/contribution_festival_cubit.dart';
import '../../../../application/contribution/contribution_festival/contribution_festival_state.dart';
import '../../widget/common_footer_text.dart';
import '../../widget/common_textfield.dart';

class FestivalInfoWidget extends StatelessWidget {
  const FestivalInfoWidget(
      {super.key, required this.onNext, this.festivalId});
  final void Function(String festivalId) onNext;
  final String? festivalId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributeFestivalCubit, ContributeFestivalState>(
      listener: (context, state) {
        if (state is ContributeFestivalLoaded && state.festivalId!.isNotEmpty) {
          onNext(state.festivalId!);
        }
      },
      builder: (context, state) {
        return BlocBuilder<ContributeFestivalCubit, ContributeFestivalState>(
          builder: (context, state) {
            final festivalCubit = context.read<ContributeFestivalCubit>();
            return Form(
              key: festivalCubit.festivalInfoFormKey,
              child: Column(children: [
                CommonTextfield(
                    isRequired:true,
                    title:  StringConstant.title,
                    controller: festivalCubit.festivalTitleController,
                    validator: festivalCubit.festivalTitleValidator),
                Gap(20.h),
                CommonTextfield(
                    title: StringConstant.subtitle,
                    controller: festivalCubit.festivalSubTitleController,
                    validator: festivalCubit.festivalSubTitleValidator),
                const Spacer(),
                CommonFooterText(
                  calledFrom: 'first',
                  onNextTap: festivalId != null
                      ? () async {
                   if (festivalCubit.festivalInfoFormKey.currentState!
                        .validate()) {
                     await festivalCubit.updateFestival(
                         festivalId ?? '');
                    }
                  }
                      : () async {
                    await festivalCubit.createFestival();
                  }
                  // onNextTap: onNext,
                )
              ]),
            );
          },
        );
      },
    );
  }
}
