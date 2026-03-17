import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../application/contribution/contribution_temple/contribution_temple_cubit.dart';
import '../../../core/constants/strings.dart';
import '../../../../application/contribution/contribution_temple/contribution_temple_state.dart';

class DonateWidget extends StatefulWidget {
  const DonateWidget({super.key});

  @override
  State<DonateWidget> createState() => _DonateWidgetState();
}

class _DonateWidgetState extends State<DonateWidget> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final messageController = TextEditingController();
  final amountController = TextEditingController();
  final panController = TextEditingController();
  String? phoneError;
  String selectedCountryCode = "+91";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
        builder: (context, state) {
      final templeCubit = context.read<ContributeTempleCubit>();
      return Form(
        key: templeCubit.donateFromKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   StringConstant.donateTitle,
            //   style: Theme.of(context).textTheme.labelSmall,
            // ),
            // Gap(10.h),
            // CommonTextfield(
            //   title: StringConstant.name,
            //   controller: nameController,
            //   validator: templeCubit.validateName,
            // ),
            // Gap(10.h),
            // CommonTextfield(
            //   title: StringConstant.email,
            //   controller: emailController,
            //   validator: templeCubit.validateEmail,
            // ),
            // Gap(10.h),
            // Text(
            //   StringConstant.phone,
            //   style: Theme.of(context).textTheme.bodyMedium,
            // ),
            // Gap(10.h),
            // Container(
            //   height: 50,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(8.r),
            //     border: Border.all(
            //         color:
            //             phoneError != null ? Colors.red : Colors.grey.shade300),
            //   ),
            //   child: Row(
            //     children: [
            //       CountryCodePicker(
            //         onChanged: (countryCode) {
            //           selectedCountryCode = countryCode.dialCode ?? '91';
            //         },
            //         initialSelection: 'IN',
            //         favorite: const ['+91', 'IN'],
            //         showCountryOnly: false,
            //         showOnlyCountryWhenClosed: false,
            //         alignLeft: false,
            //         padding: EdgeInsets.zero,
            //         textStyle:
            //             TextStyle(fontSize: 16.sp, color: AppColor.blackColor),
            //         flagWidth: 25.w,
            //       ),
            //       Container(
            //           height: 50.h, width: 1, color: Colors.grey.shade300),
            //       Expanded(
            //         child: CustomSignInField(
            //           height: 50,
            //           keyboardType: TextInputType.number,
            //           validator: templeCubit.validatePhone,
            //           controller: phoneController,
            //           hintText: '',
            //           onChanged: (value) {
            //             if (phoneError != null) {
            //               setState(() {
            //                 phoneError = null;
            //               });
            //             }
            //           },
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            // Gap(10.h),
            // CommonTextfield(
            //   title: StringConstant.message,
            //   controller: messageController,
            //   maxLines: 5,
            // ),
            // Gap(10.h),
            // CommonTextfield(
            //     title: StringConstant.amount, controller: amountController, validator: templeCubit.validateAmount,),
            // Gap(10.h),
            // CommonTextfield(
            //     title: StringConstant.pan,
            //     controller: panController,
            //     validator: templeCubit.validatePAN),
            // const SizedBox(height: 20),
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.orange,
            //       padding: const EdgeInsets.symmetric(vertical: 10),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(6),
            //       ),
            //     ),
            //     onPressed: () {
            //       if (templeCubit.donateFromKey.currentState!.validate()) {
            //         final phoneValidation =
            //             templeCubit.validatePhone(phoneController.text);
            //         if (phoneValidation != null) {
            //           setState(() {
            //             phoneError = phoneValidation;
            //           });
            //           return;
            //         }
            //         setState(() {
            //           phoneError = null;
            //         });
            //         context.read<ContributeTempleCubit>().updateDonate(
            //             nameController.text.trim(),
            //             emailController.text.trim(),
            //             "$selectedCountryCode${phoneController.text.trim()}",
            //             messageController.text.trim(),
            //             amountController.text.trim(),
            //             panController.text.trim().toUpperCase());
            //
            //       }
            //     },
            //     child: Text(
            //       StringConstant.submit,
            //       style: Theme.of(context)
            //           .textTheme
            //           .bodyMedium
            //           ?.copyWith(color: AppColor.whiteColor),
            //     ),
            //   ),
            // )
            
            Text(StringConstant.comingSoon)
            // Container(
            //   height: 500,
            //     child: Image.asset("assets/background/Coming soon.png"))
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    amountController.dispose();
    panController.dispose();
    super.dispose();
  }
}
