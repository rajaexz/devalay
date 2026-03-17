import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_puja/contribution_puja_cubit.dart';
import '../../../../application/contribution/contribution_puja/contribution_puja_state.dart';
import '../../widget/common_footer_text.dart';
import '../../widget/common_textfield.dart';

class PujaInfoWidget extends StatelessWidget {
  const PujaInfoWidget({super.key, required this.onNext, this.pujaId});
  final void Function(String pujaId) onNext;
  final String? pujaId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributePujaCubit, ContributePujaState>(
      listener: (context, state) {
        if (state is ContributePujaLoaded && state.pujaId != null && state.pujaId!.isNotEmpty) {
          onNext(state.pujaId!);
        }
      }, 
      builder: (context, state) {
        return BlocBuilder<ContributePujaCubit, ContributePujaState>(
          builder: (context, state) {
            final pujaCubit = context.read<ContributePujaCubit>();
            return Form(
              key: pujaCubit.pujaInfoFormKey,
              child: Column(
                children: [
                  CommonTextfield(
                      isRequired:true,
                    title: "Title",
                    controller: pujaCubit.pujaTitleController,
                    validator: pujaCubit.pujaTitleValidator,
                  ),
                  Gap(20.h),
                  CommonTextfield(
                    title: "Subtitle",
                    controller: pujaCubit.pujaSubTitleController,
                    validator: pujaCubit.pujaSubTitleValidator,
                  ),
                  Gap(20.h),
                  CommonTextfield(
                    title: "About",
                    controller: pujaCubit.pujaAboutController,
                    validator: pujaCubit.pujaAboutValidator,
                    maxLines: 5,
                  ),
                  const Spacer(),
                  CommonFooterText(
                    calledFrom: 'first',
                    onNextTap: pujaId != null ? () async {
                      if (pujaCubit.pujaInfoFormKey.currentState!.validate()){
                        await pujaCubit.updatePuja(pujaId!);
                      }
                    } : () async {
                      await pujaCubit.createPuja();
                    }
                  )
                ],
              )
            );
          }
        );
      }
    );
  }
}