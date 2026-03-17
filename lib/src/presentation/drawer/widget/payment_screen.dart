import 'package:devalay_app/src/application/authentication/setting/setting_cubit.dart';
import 'package:devalay_app/src/application/authentication/setting/setting_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../contribute/widget/common_textfield.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/loader.dart';
import '../../core/utils/colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final SettingCubit settingCubit;

  @override
  void initState() {
    // context.read<SettingCubit>().initializeScreen();
    context.read<SettingCubit>().setScreenState(isLoading: false) ;
    context.read<SettingCubit>().updatePaymentPatch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30.sp,
        backgroundColor: AppColor.whiteColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColor.blackColor,
            )),
        elevation: 0,
        title: Text(
          StringConstant.payment,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: AppColor.blackColor),
        ),
      ),
      body: BlocBuilder<SettingCubit, SettingState>
        (builder: (context, state) {
        if (state is SettingLoaded) {
          // if (state.loadingState) {
          //   return Scaffold(
          //     backgroundColor: Theme.of(context).brightness == Brightness.dark
          //         ? AppColor.blackColor
          //         : AppColor.whiteColor,
          //     body: const Center(child: Column(
          //       children: [
          //         Text("data"),
          //         CustomLottieLoader(),
          //       ],
          //     )),
          //   );
          // }

          // if (state.errorMessage.isNotEmpty) {
          //   return Scaffold(
          //     backgroundColor: Theme.of(context).brightness == Brightness.dark
          //         ? AppColor.blackColor
          //         : AppColor.whiteColor,
          //     appBar: SimpleAppBar(
          //       centerTitle: false,
          //       brandName: StringConstant.profile,
          //       // onBackTap: _handleBackNavigation,
          //     ),
          //     body: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             'Error: ${state.errorMessage}',
          //             style: const TextStyle(color: Colors.red),
          //             textAlign: TextAlign.center,
          //           ),
          //           Gap(16.h),
          //           // ElevatedButton(
          //           //   onPressed: () => settingCubit.fetchProfileInfoData(),
          //           //   child: const Text('Retry'),
          //           // ),
          //         ],
          //       ),
          //     ),
          //   );
          // }

          final cubit = context.read<SettingCubit>();
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15.0.sp,
            ),
            child: Form(
              key: cubit.settingFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringConstant.bankAccountDetails,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.w400),
                  ),
                  Gap(15.h),
                  CommonTextfield(
                    title: StringConstant.accountName,
                    controller: cubit.accountNameController,
                  ),
                  Gap(8.h),
                  CommonTextfield(
                    title: StringConstant.accountNumber,
                    controller: cubit.accountNumberController,
                  ),
                  Gap(8.h),
                  CommonTextfield(
                    title: StringConstant.ifscCode,
                    controller: cubit.ifscCodeController,
                  ),
                  Gap(8.h),
                  CommonTextfield(
                    title: StringConstant.bankName,
                    controller: cubit.bankNameController,
                  ),
                  Gap(8.h),
                  CommonTextfield(
                    title: StringConstant.upiId,
                    controller: cubit.upiIdController,
                  ),
                  Gap(20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        final cubit = context.read<SettingCubit>();
                        await cubit.updatePayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColor.appbarBgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child:
                          Text(
                        StringConstant.save,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColor.blackColor
              : AppColor.whiteColor,
          body: const Center(child: Column(
            children: [
              CustomLottieLoader(),
              Text("data")
            ],
          )),
        );
      }),
    );
  }
}
