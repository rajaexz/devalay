import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  // Animation constants
  static const _animationDuration = Duration(milliseconds: 500);
  static const _pageTransitionCurve = Curves.easeInOut;

  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  // Intro content data
  static final List<_IntroData> _introPages = [
    _IntroData(
      title: StringConstant.welcomeDevalay,
      subtitle: StringConstant.exploreDevine,
      backgroundImage: "assets/background/intro.png",
    ),
    _IntroData(
      title: StringConstant.supportTemple,
      subtitle: StringConstant.preserveTradition,
      backgroundImage: "assets/background/intro_1.png",
    ),
    _IntroData(
      title: StringConstant.joinCommunity,
      subtitle: StringConstant.engageDevotees,
      backgroundImage: "assets/background/intro_2.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============ Event Handlers ============

  void _onNext() {
    if (_currentPage < _introPages.length - 1) {
      _animationController.reset();
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: _animationDuration,
        curve: _pageTransitionCurve,
      );
      _animationController.forward();
    } else {
      _navigateToLogin();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _navigateToLogin() {
    PrefManager.getLoggedInStatus();
    AppRouter.go(RouterConstant.loginScreen);
  }

  // ============ Build Methods ============

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedSwitcher(
      duration: _animationDuration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Image.asset(
        _introPages[_currentPage].backgroundImage,
        key: ValueKey<int>(_currentPage),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _buildPageView()),
          _buildPageIndicator(),
          Gap(26.h),
          _buildNextButton(),
          Gap(20.h),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _introPages.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: _buildPageContent(_introPages[index]),
        );
      },
    );
  }

  Widget _buildPageContent(_IntroData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            data.title,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColor.whiteColor,
                ),
          ),
        ),
        Gap(10.h),
        Text(
          data.subtitle,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppColor.whiteColor,
              ),
        ),
        Gap(10.h),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        _introPages.length,
        (index) => _buildDot(index),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = _currentPage == index;
    return Container(
      margin: const EdgeInsets.only(right: 5.0, top: 10.0),
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColor.orangeColor : AppColor.greyColor,
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _onNext,
      child: Container(
        height: 50.h,
        width: 50.w,
        decoration: BoxDecoration(
          color: AppColor.appbarBgColor,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_forward_ios,
            color: AppColor.whiteColor,
          ),
        ),
      ),
    );
  }
}

/// Data class for intro page content
class _IntroData {
  final String title;
  final String subtitle;
  final String backgroundImage;

  const _IntroData({
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
  });
}
