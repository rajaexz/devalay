import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class TempleEssenceWidget extends StatelessWidget {
  const TempleEssenceWidget(
      {super.key, required this.onNext, this.onBack, this.templeId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? templeId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        final templecubit = context.read<ContributeTempleCubit>();
        return Column(children: [
          CommonTextfield(
              title: StringConstant.tagline,
              controller: templecubit.taglineController,
              maxLines: 3),
          Gap(20.h),
          CommonTextfield(
              title: StringConstant.about,
              controller: templecubit.aboutController,
              maxLines: 3),
          const Spacer(),
          CommonFooterText(
              onNextTap: () async {
                await templecubit.updateTempleEssence(templeId!);
                onNext();
              },
              onBackTap: onBack)
        ]);
      },
    );
  }
}
