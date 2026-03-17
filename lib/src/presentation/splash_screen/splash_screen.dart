import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/domain/repo_impl/authentication_repo.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final authenticationRepo = getIt<AuthenticationRepo>();

  // Timeout duration for profile fetch
  static const _fetchTimeout = Duration(seconds: 10);

@override
void initState() {
  super.initState();
    _setupAnimation();
    _initializeApp();
  }
  
  void _setupAnimation() {
  _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  _controller.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Get user data
      final String? userId = await PrefManager.getUserDevalayId();
      final bool isLoggedIn = await PrefManager.getLoggedInStatus();

      debugPrint("SplashScreen: userId=$userId, isLoggedIn=$isLoggedIn");

      // If not logged in or no userId, let navigate() handle it
      if (!isLoggedIn || userId == null || userId.isEmpty) {
        // Wait for animation to complete
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          // Use authenticationRepo.navigate with default values
          // This will check session and redirect appropriately
          authenticationRepo.navigate(context, false, false);
        }
        return;
}

      // User is logged in with valid userId - fetch profile
      await _fetchProfileAndNavigate(userId);
    } catch (e) {
      debugPrint("Splash screen error: $e");
      // On error, still try to navigate (let navigate() handle the logic)
      if (mounted) {
        authenticationRepo.navigate(context, false, false);
      }
    }
  }

  Future<void> _fetchProfileAndNavigate(String userId) async {
  final cubit = context.read<ProfileInfoCubit>();
  
    // Initialize profile fetch
    cubit.init(userId);
  
    // Wait for profile data with timeout
    bool dataLoaded = false;
    try {
      await cubit.stream
          .firstWhere((state) {
    if (state is ProfileInfoLoaded) {
              // Return true when loading is complete (regardless of data)
              return !state.loadingState;
            }
            return false;
          })
          .timeout(_fetchTimeout);
      dataLoaded = true;
    } catch (e) {
      debugPrint("Profile fetch timeout or error: $e");
      // Continue with navigation even if fetch fails
    }

    // Navigate based on profile data
    if (mounted) {
      final profileModel = cubit.profileInfoModel;

      // Get user preferences (use defaults if profile is null)
      final bool isSkillsNotEmpty = profileModel?.skills?.isNotEmpty ?? false;
      final bool isPandit = profileModel?.isPandit ?? false;
      final bool admin = profileModel?.admin ?? false;

      if (profileModel != null) {
       PrefManager.setAdmin(admin.toString());
      }
      
      debugPrint("SplashScreen: skills=${profileModel?.skills?.length}, isPandit=$isPandit, dataLoaded=$dataLoaded");

      // Let authenticationRepo.navigate handle all navigation logic
      authenticationRepo.navigate(context, isSkillsNotEmpty, isPandit);
  }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColor.blackColor
          : AppColor.splashBgColor,
      body: SafeArea(
        child: Center(
          child: Hero(
            tag: "logo",
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Image.asset(
                    "assets/logo/devalay_logo.png",
                    fit: BoxFit.contain,
                    width: screenWidth * 0.4,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
