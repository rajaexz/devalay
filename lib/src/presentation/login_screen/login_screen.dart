import 'package:devalay_app/src/application/authentication/login/login_cubit.dart';
import 'package:devalay_app/src/application/authentication/login/login_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/utils/validators.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/login_screen/widget/logo_widget.dart';
import 'package:devalay_app/src/presentation/login_screen/widget/phone_input_widget.dart';
import 'package:devalay_app/src/presentation/login_screen/widget/terms_checkbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = 'LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginCubit _loginCubit;
  String? _phoneError;
  bool _isTermsAccepted = false;
  String _selectedCountryCode = "+91";

  @override
  void initState() {
    super.initState();
    _loginCubit = context.read<LoginCubit>();
    _loginCubit.phoneController.text = "";
  }

  void _handleSendOtp() {
    if (_loginCubit.isLoading) return;

    // Check terms acceptance
    if (!_isTermsAccepted) {
      _showSnackBar(
        StringConstant.pleaseAcceptTermsToContinue,
        isError: true,
      );
      return;
    }

    // Validate phone number
    final error = Validators.phone(_loginCubit.phoneController.text);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }

    setState(() => _phoneError = null);
    _loginCubit.loginWithPhone(_selectedCountryCode);
  }

  void _handleGuestLogin() {
    _loginCubit.loginAsGuest();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14.sp)),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.splashColor,
      resizeToAvoidBottomInset: false,
      body: BlocListener<LoginCubit, LoginState>(
        listener: _handleStateChanges,
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            final isLoading = state is LoginLoading;

            return SafeArea(
              child: Form(
                key: _loginCubit.formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0.sp),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Gap(50.h),
                            const LogoWidget(),
                            Gap(50.h),
                            _buildTitle(),
                            Gap(18.h),
                            _buildPhoneInput(),
                            Gap(18.h),
                            _buildTermsCheckbox(),
                            Gap(18.h),
                            _buildSendOtpButton(isLoading),
                            Gap(12.h),
                            _buildGuestButton(),
                            const Spacer(),
                            _buildBottomImage(),
                            Gap(20.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, LoginState state) {
    if (state is LoginError) {
      _showSnackBar(state.message, isError: true);
    }
  }

  Widget _buildTitle() {
    return Text(
      StringConstant.signIn,
      style: Theme.of(context)
          .textTheme
          .headlineMedium
          ?.copyWith(color: AppColor.blackColor),
    );
  }

  Widget _buildPhoneInput() {
    return PhoneInputWidget(
      controller: _loginCubit.phoneController,
      error: _phoneError,
      onCountryChanged: (code) => _selectedCountryCode = code,
      onPhoneChanged: (value) {
        if (_phoneError != null) {
          setState(() => _phoneError = null);
        }
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return TermsCheckboxWidget(
      isAccepted: _isTermsAccepted,
      onChanged: (value) => setState(() => _isTermsAccepted = value),
    );
  }

  Widget _buildSendOtpButton(bool isLoading) {
    return SizedBox(
      height: 55.h,
      width: double.infinity,
      child: Stack(
        children: [
          CustomButton(
            onTap: _handleSendOtp,
            buttonAssets: "",
            borderRadius: BorderRadius.circular(10.r),
            textColor: AppColor.whiteColor,
            textButton: StringConstant.sendOtp,
            btnColor: (_isTermsAccepted && !isLoading)
                ? AppColor.appbarBgColor
                : Colors.grey.shade400,
            mypadding: EdgeInsets.symmetric(vertical: 12.sp),
          ),
          if (isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColor.whiteColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestButton() {
    return SizedBox(
      height: 55.h,
      width: double.infinity,
      child: CustomButton(
        onTap: _handleGuestLogin,
        buttonAssets: "",
        borderRadius: BorderRadius.circular(10.r),
        textColor: AppColor.appbarBgColor,
        textButton: StringConstant.continueAsGuest,
        btnColor: AppColor.whiteColor,
        mypadding: EdgeInsets.symmetric(vertical: 12.sp),
      ),
    );
  }

  Widget _buildBottomImage() {
    return SizedBox(
      height: 200.h,
      width: 220.w,
      child: Image.asset(
        "assets/background/authentication.png",
        fit: BoxFit.contain,
      ),
    );
  }
}
