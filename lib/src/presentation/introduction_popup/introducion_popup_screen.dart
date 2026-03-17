import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/introduction_popup/widget/follow_event_screen.dart';
import 'package:devalay_app/src/presentation/introduction_popup/widget/follow_people_screen.dart';
import 'package:devalay_app/src/presentation/introduction_popup/widget/follow_temple_screen.dart';
import 'package:devalay_app/src/presentation/drawer/widget/service_profile/add_skill_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../core/utils/colors.dart';
import 'widget/create_profile_screen.dart';

class IntroductionPopupScreen extends StatefulWidget {
   const IntroductionPopupScreen({super.key, this.id, this.type});

  final int? id;
  final String? type;

  @override
  State<IntroductionPopupScreen> createState() => _IntroductionPopupScreenState();
}

class _IntroductionPopupScreenState extends State<IntroductionPopupScreen> {
  int _currentIndex = 0;
  bool _isProviderService = false;

  // ============ Computed Properties ============

  /// Get titles based on provider service status
  List<String> get _titles {
    final baseTitles = [
      StringConstant.createYourProfile,
      StringConstant.followPeople,
      StringConstant.saveTemples,
      StringConstant.saveEvents,
    ];
    
    if (_isProviderService) {
      return [...baseTitles, 'Add Your Skill'];
    }
    return baseTitles;
  }

  /// Get current title safely
  String get _currentTitle {
    if (_currentIndex < _titles.length) {
      return _titles[_currentIndex];
  }
    return _titles.last;
  }

  /// Total number of steps
  int get _totalSteps => _isProviderService ? 5 : 4;

  // ============ Event Handlers ============

  void _updateProviderServiceStatus(bool value) {
    setState(() {
      _isProviderService = value;
    });
  }

  void _onNext() {
    if (_currentIndex < _totalSteps - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _onBack() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  // ============ Build Methods ============

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          backgroundColor: AppColor.splashColor,
          resizeToAvoidBottomInset: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap(80.h),
            _buildLogo(),
            Gap(20.h),
            _buildTitle(context),
            Gap(18.h),
            Expanded(child: _buildCurrentStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    "assets/logo/DEVALAY 1.svg",
                    height: 72.h,
        // ignore: deprecated_member_use
                    color: const Color(0xfff58148),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Center(
                child: Text(
        _currentTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColor.blackColor,
          fontWeight: FontWeight.w400,
              ),
      ),
    );
  }

   Widget _buildCurrentStep() {
    switch (_currentIndex) {
      case 0:
        return CreateProfileScreen(
          onNext: _onNext,
          onProviderServiceChanged: _updateProviderServiceStatus,
          type: widget.type,
          id: widget.id ?? 0,
        );
      case 1:
        return FollowPeopleScreen(onNext: _onNext);
      case 2:
        return FollowTempleScreen(onNext: _onNext, onBack: _onBack);
      case 3:
        return FollowEventScreen(
          onNext: _onNext,
          onBack: _onBack,
          isProviderService: _isProviderService,
        );
      case 4:
        if (_isProviderService) {
          return const AddSkillScreen(
            isApbar: false,
            isInside: false,
            isColor: AppColor.lightScaffoldColor,
          );
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}
