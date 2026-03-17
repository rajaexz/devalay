import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class TempleGoverningWidget extends StatelessWidget {
  const TempleGoverningWidget(
      {super.key,
      required this.onNext,
      this.onBack,
      this.templeId,
      this.governingId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? templeId;
  final String? governingId;

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        final templecubit = context.read<ContributeTempleCubit>();
        return Column(children: [
          CommonTextfield(title: StringConstant.name, controller: templecubit.governingName),
          Gap(20.h),
          CommonTextfield(
              title:  StringConstant.subtitle, controller: templecubit.governingSubtitle),
          Gap(20.h),
          CommonTextfield(
              title: 'Description',
              controller: templecubit.governingDescription,
              maxLines: 3),
          const Spacer(),
          CommonFooterText(
              onNextTap: () async {
                await templecubit.updateTempleGoverningBody(governingId!);
                onNext();
              },
              onBackTap: onBack,
              nextText: StringConstant.submit)
        ]);
      },
    );
  }
}
