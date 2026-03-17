import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/data/model/version/version_model.dart';
import 'package:flutter/material.dart';

import '../../core/api/api_calling.dart';
import '../../core/failure.dart';

abstract class AuthenticationRepo {
  void navigate(BuildContext context,bool isSkillsEmpty, bool isPandit,);
  Future<void> signInWithGoogle(BuildContext context);
  // Future<void> signInWithApple(BuildContext context);
  Future<void> loginWithEmail(
      String email, String password, BuildContext context);
 Future<VersionResponse> checkVersion(String platform, version);


      
  Future<void> loginWithPhone(String number, {bool reSend = false});
    Future<void> loginWithOtp({String otp,String number});
  Future<void> signUpWithEmail(String userName, String email, String password,
      String confirmPassword, BuildContext context);
  Future<void> userSignOut(BuildContext context);
  Future<void> forgetPasswordApi(String email, BuildContext context);
  Future<void> otpVerifyApi(String email, String otp);
  Future<void> resetPasswordApi(
      String email, String otp, String password1, String password2);
  Future<Either<Failure, CustomResponse>> accountPrivacy(
      String id, String status,);
  Future<Either<Failure, CustomResponse>> fetchHelpSupportData(String name);
  Future<Either<Failure, CustomResponse>> updatePayment({String? accountName, String? accountNumber, String? ifscCode, String? bankName, String? upiId});
  Future<Either<Failure, CustomResponse>> updatePaymentPatch();
}




