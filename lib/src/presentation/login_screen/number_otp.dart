import 'package:devalay_app/src/application/authentication/login/login_cubit.dart';
import 'package:devalay_app/src/application/authentication/login/login_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/login_screen/widget/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pinput/pinput.dart';
import 'dart:math' as math;

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  late LoginCubit _loginCubit;
  late AnimationController _timerController;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  // Timer duration in seconds
  static const int _timerDuration = 60;

  @override
  void initState() {
    super.initState();
    _loginCubit = context.read<LoginCubit>();
    _initializeTimer();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  void _initializeTimer() {
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _timerDuration),
    )..addListener(() => setState(() {}));
    _timerController.forward();
  }

  @override
  void dispose() {
    _loginCubit.otpController.clear();
    _shakeController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  // ============ Event Handlers ============

  Future<void> _handleVerifyOtp() async {
    if (_loginCubit.otpCode.length != 6) {
      _showSnackBar(StringConstant.pleaseEnterValidOtp, isError: true);
      _triggerShake();
      return;
    }

      if (!mounted) return;

      try {
      await _loginCubit.verifyOTP(widget.phoneNumber);
      } catch (e) {
      if (!mounted) return;
      _showSnackBar(StringConstant.errorVerifyingOtp, isError: true);
    }
  }

  Future<void> _handleResendOtp() async {
    if (_timerController.isAnimating) return;

    try {
      // Reset and start the timer
      _timerController.reset();
      _timerController.forward();

      // Extract country code from phone number (first 3 characters)
      final countryCode = widget.phoneNumber.substring(0, 3);
      await _loginCubit.loginWithPhone(countryCode, reSend: true);
    } catch (e) {
      _showSnackBar(StringConstant.errorResendingOtp(e.toString()), isError: true);
    }
  }

  void _handleBack() {
    AppRouter.pop();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
      );
  }

  // ============ Computed Properties ============

  int get _remainingSeconds => (_timerDuration - (_timerController.value * _timerDuration)).toInt();

  bool get _canResend => !_timerController.isAnimating;

  // ============ Build Methods ============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.splashColor,
      resizeToAvoidBottomInset: false,
      body: BlocListener<LoginCubit, LoginState>(
        listener: _handleStateChanges,
        child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.sp),
          child: Column(
            children: [
              Gap(10.h),
                _buildBackButton(),
                Gap(60.h),
                const LogoWidget(),
                Gap(67.h),
                _buildTitle(),
                Gap(24.h),
                _buildOtpInput(),
                SizedBox(height: 24.h),
                _buildVerifyButton(),
                SizedBox(height: 16.h),
                _buildResendButton(),
                const Spacer(),
                _buildBottomImage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, LoginState state) {
    if (state is LoginError) {
      _showSnackBar(state.message, isError: true);
      _triggerShake();
    }
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  Widget _buildBackButton() {
    return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
          onTap: _handleBack,
          child: const Icon(Icons.arrow_back_ios),
                  ),
                ],
    );
  }

  Widget _buildTitle() {
    return Text(
                StringConstant.verifyCode,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColor.blackColor,
                    ),
    );
  }

  Widget _buildOtpInput() {
    final defaultPinTheme = PinTheme(
                    width: 50,
                    height: 60,
                    textStyle: TextStyle(
                      fontSize: 20.sp,
                      color: AppColor.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xff2A2B2F)
                          : AppColor.lightScaffoldColor,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
    );

    return Center(
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          // Simple horizontal shake using sine wave
          final offset =
              math.sin(_shakeAnimation.value * math.pi * 8) * 10; // px shift
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
      child: Pinput(
        length: 6,
        controller: _loginCubit.otpController,
        onChanged: (code) => setState(() => _loginCubit.otpCode = code),
        onCompleted: (_) => _handleVerifyOtp(),
        defaultPinTheme: defaultPinTheme,
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return CustomButton(
      onTap: _handleVerifyOtp,
                buttonAssets: "",
                borderRadius: BorderRadius.circular(10.r),
                textColor: AppColor.whiteColor,
                textButton: StringConstant.verifyBtn,
                btnColor: AppColor.appbarBgColor,
                mypadding: EdgeInsets.symmetric(vertical: 12.h),
    );
  }

  Widget _buildResendButton() {
    return Center(
                child: TextButton(
        onPressed: _canResend ? _handleResendOtp : null,
                  child: RichText(
                    text: TextSpan(
                      text: StringConstant.didntReceiveCode,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                      children: [
                        TextSpan(
                text: _canResend ? StringConstant.resend : StringConstant.resendInSeconds(StringConstant.resend, '$_remainingSeconds'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _canResend ? AppColor.orangeColor : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomImage() {
    return SizedBox(
      height: 234.h,
      width: 253.w,
      child: Image.asset("assets/background/authentication.png"),
    );
  }
}
