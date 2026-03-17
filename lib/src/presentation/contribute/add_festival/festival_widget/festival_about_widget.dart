import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_festival/contribution_festival_cubit.dart';
import '../../../../application/contribution/contribution_festival/contribution_festival_state.dart';
import '../../widget/common_footer_text.dart';
import '../../widget/common_textfield.dart';

class FestivalAboutWidget extends StatefulWidget {
  const FestivalAboutWidget(
      {super.key, required this.onNext, this.onBack, this.festivalId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? festivalId;

  @override
  State<FestivalAboutWidget> createState() => _FestivalAboutWidgetState();
}

class _FestivalAboutWidgetState extends State<FestivalAboutWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeFestivalCubit, ContributeFestivalState>(
        builder: (context, state) {
      final festivalCubit = context.read<ContributeFestivalCubit>();
      return Form(
        key: festivalCubit.festivalAboutFormKey,
        child: Column(
          children: [
            CommonTextfield(
              title: 'About',
              controller: festivalCubit.festivalAboutController,
              maxLines: 5,
            ),
            Gap(20.h),
            CommonTextfield(
              title: StringConstant.tabHistory,
              controller: festivalCubit.festivalHistoryController,
              maxLines: 5,
            ),
            Gap(20.h),
            CommonFooterText(
              onNextTap: () async {
                await festivalCubit
                    .updateFestivalAbout(widget.festivalId ?? '');
                widget.onNext();
              },
              onBackTap: widget.onBack,
            )
          ],
        ),
      );
    });
  }
}
