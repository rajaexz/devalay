import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:devalay_app/src/core/api/api_provider.dart';
import 'package:devalay_app/src/core/api/app_constant.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/core/utils/logger.dart';
import 'package:devalay_app/src/data/model/version/version_model.dart';
import 'package:devalay_app/src/domain/repo_impl/authentication_repo.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/drawer/widget/service_profile/add_skill_screen.dart';
import 'package:devalay_app/src/presentation/intro_screen/first_intro_screen.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:devalay_app/src/core/utils/enums.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/api/api_calling.dart';
import '../../core/failure.dart';

@LazySingleton(as: AuthenticationRepo)
class AuthenticationRepositories extends AuthenticationRepo {
  final Dio _dio;

  AuthenticationRepositories() : _dio = ApiProvider.getDio();

  @override
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn(
        scopes: [
          'email',
        ],
      ).signIn();

      if (gUser == null) {
        Fluttertoast.showToast(msg: "Google sign-in canceled");
        return;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
      }

      Logger.log("this is access token----${gAuth.accessToken}");

      final accessToken = gAuth.accessToken;
      final fcmToken = await PrefManager.getUserFCMToken();

      await sendAccessTokenToServer(
          {"access_token": accessToken!, "device_token": fcmToken},
          "${AppConstant.baseUrl}${AppConstant.googleLogin}");

      PrefManager.setUserAccessToken(accessToken);
      PrefManager.setLoginMethod('google');

      PrefManager.setLoggedInStatusTrue();
      AppRouter.go('/landing');
    } catch (e) {
      debugPrint("Error during Google sign-in: ${e.toString()}");
      Fluttertoast.showToast(msg: "Error during Google sign-in");
    }
  }

  // @override
  // Future<void> signInWithApple(BuildContext context) async {
  //   try {
  //     final credential = await SignInWithApple.getAppleIDCredential(scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName,
  //     ]);

  //     String fcmToken = '';

  //     await sendAccessTokenToServer({
  //       "identity_token": credential.identityToken!,
  //       "device_token": fcmToken
  //     }, "${AppConstant.baseUrl}${AppConstant.appleLogin}");

  //     PrefManager.setLoginMethod('apple');
  //     PrefManager.setLoggedInStatusTrue();
  //     AppRouter.go('/landing');
  //   } catch (e) {
  //     debugPrint("Error during apple sign-in: ${e.toString()}");
  //     Fluttertoast.showToast(msg: "Error during apple sign-in");
  //   }
  // }

  @override
  Future<void> loginWithPhone(String number, {bool reSend = false}) async {
    try {
      final Map<String, dynamic> data = {"number": number};
      print("this is the data--->>>$data");
      final response = await _dio.post(
        "${AppConstant.baseUrl}${AppConstant.numberLogin}",
        data: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey("message")) {
          Fluttertoast.showToast(msg: responseData["message"]);

          if (reSend) {
            return;
          } else {
            AppRouter.push("${RouterConstant.otpPVerificationScreen}/$number");
          }
        } else {
          Fluttertoast.showToast(msg: "Some Thing Went worrong");
        }
      } else {
        Fluttertoast.showToast(msg: "Login failed");
      }
    } catch (e) {
      Logger.logError("Error during email login: ${e.toString()}");
      Fluttertoast.showToast(msg: "Error during email login $e");
    }
  }

  @override
  Future<void> loginWithOtp({String? otp, String? number}) async {
    try {
      final fcmToken = await PrefManager.getUserFCMToken();
      final Map<String, dynamic> data = {
        "number": number,
        "otp": otp,
        "device_token": fcmToken
      };

      // Use sendAccessTokenToServer which handles the request and response processing
      await sendAccessTokenToServer(
          data, "${AppConstant.baseUrl}${AppConstant.numberLoginOtp}");

      PrefManager.setLoginMethod('phone');
      PrefManager.setLoggedInStatusTrue();
      
      final getUserFirstName = await PrefManager.getUserFirstName();
      final getPhone = await PrefManager.getUserLoginMethod();
      final getUserDevalayId = await PrefManager.getUserDevalayId();

      if (getUserFirstName == null || getUserFirstName.isEmpty) {
        AppRouter.go(
            "${RouterConstant.createProfile}/$getUserDevalayId/$getPhone");
      } else {
        AppRouter.go(RouterConstant.landingScreen);
      }
    } catch (e, stackTrace) {
      Logger.logError("Error during OTP login: ${e.toString()}");
      Logger.logError("Stack trace: $stackTrace");
    
      rethrow; // Re-throw to let the cubit handle the error
    }
  }

  @override
  Future<void> loginWithEmail(
      String email, String password, BuildContext context) async {
    Fluttertoast.showToast(
        msg: 'Email login is temporarily disabled. Please use phone login.');
  }

  @override
  Future<VersionResponse> checkVersion(String platform, version) async {
    try {
      print(
          'Checking version - Platform: $platform, Current Version: $version');

      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: '/check-version/',
        referer: '${AppConstant.baseUrl}/check-version/',
        data: {
          "platform": platform,
          "version": version,
        },
      );

      if (customResponse.statusCode == 200 &&
          customResponse.response?.data != null) {
        final data = customResponse.response!.data;
        final versionResponse = VersionResponse.fromJson(data);

        print(
            'Parsed Response - Latest: ${versionResponse.latestVersion}, Force Update: ${versionResponse.forceUpdate}');

        return versionResponse;
      }

      // If status is not 200, throw exception
      throw Exception('Invalid response status: ${customResponse.statusCode}');
    } catch (e, stackTrace) {
      print('Version check error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> userSignOut(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      if (await googleSignIn.isSignedIn()) {
        try {
          await googleSignIn.disconnect();
        } catch (disconnectError) {
          Logger.logError('Google disconnect failed: $disconnectError');
        }
        await googleSignIn.signOut();
      }

      await FirebaseAuth.instance.signOut();

      await PrefManager.clearPreferences();

      Fluttertoast.showToast(msg: 'User Logged out successfully');
      if (context.mounted) {
        AppRouter.go('/intro');
      }
    } catch (e, stackTrace) {
      Logger.logError('Error during sign-out: $e ::: stackTrace :$stackTrace');
      Fluttertoast.showToast(msg: 'Error during sign-out');
    }
  }

  @override
  void navigate(BuildContext context ,bool isSkillNotEmpty, bool isPandit) async {
    final isLoggedIn = await PrefManager.getLoggedInStatus();
    final getUserFirstName = await PrefManager.getUserFirstName();

    if (isLoggedIn) {
      if (getUserFirstName != null && getUserFirstName.trim().isNotEmpty) {

        print("==============>$isSkillNotEmpty === $isPandit");
        print("-----------_$isPandit --------------$isSkillNotEmpty");

        if (!isSkillNotEmpty && isPandit == true) {
          // Capture context so we can navigate safely after dialog is dismissed
          final navigatorContext = context;
          bool continuePressed = false;

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext dialogContext) {
              return PopScope(
                canPop: true,
                onPopInvokedWithResult: (bool didPop, dynamic result) {
                  // If user closed the dialog via back/overlay (not via Continue),
                  // move them to landing so app doesn't appear stuck on splash.
                  if (didPop &&
                      navigatorContext.mounted &&
                      !continuePressed) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (navigatorContext.mounted) {
                        AppRouter.go('/landing');
                      }
                    });
                  }
                },
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  title: Text(
                    'Service Provider Required',
                    style: Theme.of(dialogContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  content: Text(
                    'You have selected the Service Provider toggle. Please fill out the Add Skills form to complete your Service Provider .',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        // Mark that user chose Continue so PopScope callback doesn't redirect
                        continuePressed = true;
                        Navigator.pop(dialogContext);
                        Navigator.push(
                          navigatorContext,
                          MaterialPageRoute(
                            builder: (context) => const AddSkillScreen(
                              isInside: true,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.appbarBgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(color: AppColor.whiteColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          AppRouter.go('/landing');
        }
       
      } else {
        await checkSessionValidity(context);
        Future.delayed(const Duration(seconds: 3), () {
          AppRouter.go('/intro');
        });
      }
    } else {
      Logger.log("the session is not valid");
      Future.delayed(const Duration(seconds: 3), () {
        AppRouter.go('/intro');
      });
    }
  }

  Future<void> sendAccessTokenToServer(
      Map<String, dynamic> accessToken, String? apiUrl) async {
    try {
      Logger.log("Sending access token to server: $accessToken");

      final response = await _dio.post(
        "$apiUrl",
        data: jsonEncode(accessToken),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to send access token: ${response.statusCode}");
      }

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw Exception("Response data is null.");
      }

      Logger.log("Response data: $responseData");

      final devalayId = responseData['id'] as int?;
      final devalayUserName = responseData['username'] as String?;
      final devalayFirstName = responseData['first_name'] as String?;
      final devalayUserEmail = responseData['email'] as String?;
      final isGuest = responseData["is_guest"] ?? false;

      // For guest users, some fields might be null, so make validation more flexible
      if (devalayId == null) {
        throw Exception("Missing user ID in response.");
      }
      
      // Use empty strings as defaults for guest users if fields are null
      final userName = devalayUserName ?? '';
      final firstName = devalayFirstName ?? '';
      final userEmail = devalayUserEmail ?? '';

      Logger.log("Devalay ID: $devalayId");
      Logger.log("Devalay User Email: $userEmail");
      Logger.log("Devalay User Fullname: $userName");
      Logger.log("Devalay User Firstname: $firstName");
      Logger.log("Is Guest: $isGuest");
      // Logger.log("Devalay User Profile URL: $devalayUserProfileUrl");

      final headers = response.headers;
      final setCookieHeaders = headers['set-cookie'];
      if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
        throw Exception("Set-Cookie headers are missing.");
      }

      String? sessionId;
      String? csrfToken;

      final cookies = setCookieHeaders.join(';').split(';');
      for (final cookie in cookies) {
        final parts = cookie.trim().split('=');
        if (parts.length == 2) {
          if (parts[0] == 'sessionid') {
            sessionId = parts[1];
          } else if (parts[0] == 'csrftoken') {
            csrfToken = parts[1];
          }
        }
      }

      if (sessionId == null || csrfToken == null) {
        throw Exception("Session ID or CSRF token is null.");
      }

      Logger.log("Session ID: $sessionId");
      Logger.log("CSRF Token: $csrfToken");
      PrefManager.setIsGuest(isGuest);
      PrefManager.setUserSessionId(sessionId);
      PrefManager.setUserCsrfToken(csrfToken);
      PrefManager.setUserDevalayId(devalayId.toString());
      PrefManager.setUserEmail(userEmail);
      PrefManager.setUserName(userName);
      PrefManager.setUserFristName(firstName);
      // PrefManager.setUserProfileImageUrl(devalayUserProfileUrl??'');

      Logger.log("Access token sent successfully!");
    } catch (e, stackTrace) {
      Logger.logError(
          "Error sending access token: $e ::: stackTrace: $stackTrace");
      rethrow; // Re-throw to let the caller handle the error
    }
  }

  @override
  Future<void> signUpWithEmail(String userName, String email, String password,
      String confirmPassword, BuildContext context) async {
    Fluttertoast.showToast(
        msg: 'Email signup is temporarily disabled. Please use phone login.');
  }

  Future<bool> checkSessionValidity(BuildContext context) async {
    try {
      final csrfToken = await PrefManager.getUserCsrfToken();
      final sessionId = await PrefManager.getUserSessionId();
      final loginMethod = await PrefManager.getUserLoginMethod();
      Logger.log("this is the session id --->>>$sessionId");
      Logger.log("this is the csrf token --->>>$csrfToken");
      Logger.log("this is the login method --->>> $loginMethod");

      String apiUrl;
      if (loginMethod == 'google') {
        apiUrl = "${AppConstant.baseUrl}${AppConstant.googleLogin}";
      } else if (loginMethod == 'apple') {
        apiUrl = "https://pmg.engineering/pmg/apple-login/";
      } else if (loginMethod == 'email') {
        apiUrl = "${AppConstant.baseUrl}${AppConstant.register}";
      } else if (loginMethod == 'phone') {
        apiUrl = "${AppConstant.baseUrl}${AppConstant.numberLoginOtp}";
      } else {
        throw Exception("Unknown login mjethod");
      }

      Logger.log("this is the login api url ----$apiUrl");

      final response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'Cookie': 'sessionid=$sessionId; csrftoken=$csrfToken',
          },
        ),
      );

      debugPrint("this si the login data--->>${response.data}");

      if (response.statusCode == 200) {
        Future.delayed(const Duration(seconds: 3), () {
          AppRouter.go('/landing');
        });
        return true;
      } else if (response.statusCode == 403) {
        await FirebaseAuth.instance.signOut();
        await PrefManager.clearPreferences();

        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const IntroScreen()));
        });

        return false;
      } else {
        debugPrint("Unexpected server response: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        Logger.log("Caught DioException: ${e.message}");
        debugPrint("navigating to login screen");
        await FirebaseAuth.instance.signOut();
        await PrefManager.clearPreferences();
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const IntroScreen()));
        });
        return false;
      } else {
        Logger.log("Error checking session validity: $e");
        return false;
      }
    }
  }

  @override
  Future<void> forgetPasswordApi(String email, BuildContext context) async {
    Fluttertoast.showToast(msg: 'Email reset is temporarily disabled.');
  }

  @override
  Future<void> otpVerifyApi(String email, String otp) async {
    Fluttertoast.showToast(msg: 'Email OTP verify is disabled.');
  }

  @override
  Future<void> resetPasswordApi(
      String email, String otp, String password1, String password2) async {
    Fluttertoast.showToast(msg: 'Email password reset is disabled.');
  }

  @override
  Future<Either<Failure, CustomResponse>> accountPrivacy(
    String id,
    String status,
  ) async {
    final bool likedStatus = status.toLowerCase() == 'true';
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.patch,
          url: '/User/$id/',
          data: {'is_private': likedStatus},
          referer: '${AppConstant.baseUrl}/User/$id/');

      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> fetchHelpSupportData(
      String name) async {
    try {
      final CustomResponse customResponse = await ApiCalling()
          .callApi(apiTypes: ApiTypes.get, url: "/Help-supports/?name=$name");
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updatePayment(
      {String? accountName,
      String? accountNumber,
      String? ifscCode,
      String? bankName,
      String? upiId}) async {
    final getUserId = await PrefManager.getUserDevalayId();
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
        apiTypes: ApiTypes.post,
        url: "/bank-accounts/",
        data: {
          "id": getUserId,
          "account_name": accountName,
          "account_number": accountNumber,
          "ifsc_code": ifscCode,
          "bank_name": bankName,
          "upi_id": upiId
        },
        referer: '${AppConstant.baseUrl}/bank-accounts/',
      );
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }

  @override
  Future<Either<Failure, CustomResponse>> updatePaymentPatch(
      {String? id}) async {
    try {
      final CustomResponse customResponse = await ApiCalling().callApi(
          apiTypes: ApiTypes.get,
          url: "/bank-accounts/",
          referer: '${AppConstant.baseUrl}/bank-accounts/');
      return right(customResponse);
    } on Exception catch (e) {
      Logger.logError(e);
      return left(Failure.getDioException(e));
    }
  }
}
