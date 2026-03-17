import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:flutter/material.dart';

/// SignIn Screen - Redirects to Phone Login
/// 
/// Since authentication is now phone-based only,
/// this screen simply redirects to the login screen.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to login screen after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.go(RouterConstant.loginScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while redirecting
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
