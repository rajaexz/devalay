import 'package:country_code_picker/country_code_picker.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_state.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart' show PrefManager;
import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/feed_appBar.dart';
import 'package:devalay_app/src/presentation/feed/feed_home_sceen/location/location_search_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router.dart';
import '../../signup/widget/custom_sigin_field.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, required this.id, this.type});

  final int id;
  final String? type;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final ProfileInfoCubit profileInfoCubit;
  final _formKey = GlobalKey<FormState>();
  String selectedCountryCode = '+91';
  bool _isUpdating = false;
  bool _hasFetchedBankData = false;

  bool _isValidImageUrl(String? url) {
    return url != null && url.trim().isNotEmpty && url.startsWith('http');
  }

  @override
  void initState() {
    profileInfoCubit = context.read<ProfileInfoCubit>();
    profileInfoCubit.init(widget.id.toString());
    super.initState();
  }

  void _safeNavigateBack() {
    // When coming from drawer, always navigate to landing to avoid navigation stack issues
    // This ensures we don't accidentally navigate to create screen or other unexpected routes
    try {
      final router = GoRouter.of(context);
      
      // If type is null or empty, we likely came from drawer, so go to landing
      // Otherwise, try to pop if possible
      if (widget.type == null || widget.type!.isEmpty) {
        // Came from drawer - navigate to landing
        AppRouter.go('/landing');
      } else if (router.canPop()) {
        // Came from another route - try to pop
        AppRouter.pop();
      } else {
        // Can't pop - go to landing
        AppRouter.go('/landing');
      }
    } catch (e) {
      // Fallback: always go to landing to avoid navigation issues
      AppRouter.go('/landing');
    }
  }

  void _handleBackNavigation() {
    if (widget.type == 'phone') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your profile before going back.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else {
      // Simply pop back - don't navigate anywhere specific
      _safeNavigateBack();
    }
  }

  Future<void> _showLocationSearch(ProfileInfoCubit profileCubit) async {
    final currentAddress = profileCubit.bioController.text;
    
    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColor.blackColor
                : AppColor.whiteColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              Flexible(
                child: LocationSearchSheet(
                  selectedLocation: currentAddress,
                  onLoactionSelected: (location) {
                    // Update the field immediately
                    profileCubit.bioController.text = location;
                    // Trigger rebuild to show updated value
                    if (mounted) {
                      setState(() {});
                    }
                    // LocationSearchSheet will handle Navigator.pop internally
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  StringConstant.success,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.whiteColor
                        : AppColor.blackColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Your personal information has been saved successfully!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.whiteColor
                        : AppColor.blackColor,
                  ),
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (widget.type == 'phone') {
                        _safeNavigateBack();
                      } else {
                        // Wait for dialog to close, then navigate to ProfileMainScreen
                        // Using AppRouter.push to maintain navigation stack
                        Future.microtask(() {
                          if (mounted) {
                            AppRouter.push('${RouterConstant.profileMainScreen}/${widget.id}/profile');
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.appbarBgColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 20.w,
                      ),
                    ),
                    child: Text(
                      StringConstant.ok,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isUpdating = true;
    });
    final success = await profileInfoCubit.updateAllProfileData(
        selectedCountryCode, context,);

    setState(() {
      _isUpdating = false;
    });

    if (success && mounted) {
      _showSuccessPopup();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleCheckPhoneSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {

     bool? isServiceProvider =  await PrefManager.getIsPandit();
     
     
      final success = await profileInfoCubit.updateAllLoginTimeData(
          selectedCountryCode, context,isServiceProvider ?? false);

      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        if (success) {
          _showSuccessPopup();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
      builder: (context, state) {
        if (state is ProfileInfoLoaded) {
          if (state.loadingState || _isUpdating) {
            return Scaffold(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.blackColor
                  : AppColor.whiteColor,
              body: const Center(child: CustomLottieLoader()),
            );
          }

          if (state.errorMessage.isNotEmpty) {
            return Scaffold(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.blackColor
                  : AppColor.whiteColor,
              appBar: SimpleAppBar(
                centerTitle: false,
                brandName: StringConstant.profile,
                onBackTap: _handleBackNavigation,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    Gap(16.h),
                    ElevatedButton(
                      onPressed: () => profileInfoCubit.fetchProfileInfoData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profileCubit = context.read<ProfileInfoCubit>();
          return DefaultTabController(
            length: 3,
            child: Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);
                // Listen to tab changes and fetch bank data when bank tab is selected (only once)
                tabController.addListener(() {
                  if (!tabController.indexIsChanging && 
                      tabController.index == 2 && 
                      !_hasFetchedBankData) {
                    // Bank details tab (index 2) - fetch only once
                    _hasFetchedBankData = true;
                    profileCubit.fetchBankAccountData();
                  }
                });
                return Scaffold(
              appBar: SimpleAppBar(
                centerTitle: false,
                brandName: StringConstant.myProfile,
                onBackTap: _handleBackNavigation,
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.blackColor
                  : AppColor.whiteColor,
              body: Column(
                children: [
                  // Header image with avatar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 140.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: (() {
                              final bg =
                                  (state.profileInfoModel?.backgroundImage ?? '')
                                      .toString();
                              if (_isValidImageUrl(bg)) {
                                return NetworkImage(bg) as ImageProvider;
                              }
                              return const AssetImage(
                                  'assets/background/temple_bg.png');
                            })(),
                            fit: BoxFit.cover,
                            colorFilter: Theme.of(context).brightness == Brightness.dark
                                ? const ColorFilter.mode(Colors.black54, BlendMode.darken)
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -36.h,
                        child: Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 36.r,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: _isValidImageUrl(
                                        state.profileInfoModel?.dp)
                                    ? NetworkImage(
                                        state.profileInfoModel!.dp!,
                                      )
                                    : null,
                                child: !_isValidImageUrl(
                                        state.profileInfoModel?.dp)
                                    ? Icon(Icons.person,
                                        size: 36.r,
                                        color: Colors.grey.shade400)
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 22.w,
                                  height: 22.w,
                                  decoration: BoxDecoration(
                                    color: AppColor.whiteColor,
                                    borderRadius: BorderRadius.circular(6.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14.sp,
                                    color: AppColor.blackColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 44.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child:  Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        labelColor: AppColor.blackColor,
                        unselectedLabelColor: AppColor.greyColor,
                        indicatorColor: AppColor.blackColor,
                        isScrollable: true,
                        tabs: [
                          Tab(text: StringConstant.userProfile),
                          Tab(text: StringConstant.serviceProfile),
                          Tab(text: StringConstant.bankDetails),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // User profile tab (existing form)
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                        Gap(20.h),
                                  CommonTextfield(
                                    title: StringConstant.fullName, 
                                    isRequired: true,
                                    controller: profileCubit.firstNameController,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return StringConstant.pleaseEnterYourFirstName;
                                      }
                                      final trimmedValue = value.trim();
                                      if (trimmedValue.length < 2) {
                                        return 'Name must be at least 2 characters';
                                      }
                                      // Check if name contains only letters and spaces (proper name format)
                                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmedValue)) {
                                        return 'Name can only contain letters and spaces';
                                      }
                                      return null;
                                    },
                                  ),
                                  Gap(10.h),
                                  Text(
                                    StringConstant.phoneNumber,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Gap(10.h),
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.r),
                                      border: Border.all(
                                          color: AppColor.greyColor.withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CountryCodePicker(
                                          onChanged: (countryCode) {
                                            selectedCountryCode =
                                                countryCode.dialCode ?? '91';
                                          },
                                          initialSelection: 'IN',
                                          favorite: const ['+91', 'IN'],
                                          showCountryOnly: false,
                                          showOnlyCountryWhenClosed: false,
                                          alignLeft: false,
                                          padding: EdgeInsets.zero,
                                          textStyle: TextStyle(
                                              fontSize: 16.sp,
                                              color: AppColor.blackColor),
                                          flagWidth: 25.w,
                                        ),
                                        Container(
                                            height: 50.h,
                                            width: 1,
                                            color: Colors.grey.shade300),
                                        Expanded(
                                          child: CustomSignInField(
                                            height: 50,
                                            keyboardType: TextInputType.number,
                                            validator: null,
                                            controller: profileInfoCubit.phoneController,
                                            hintText: '',
                                            vertical: 14.sp,
                                            horizontal: 10.sp,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Gap(10.h),
                                  Text(
                                    StringConstant.address,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Gap(10.h),
                                  GestureDetector(
                                    onTap: () => _showLocationSearch(profileCubit),
                                    child: AbsorbPointer(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColor.greyColor.withOpacity(0.4),
                                          ),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: TextFormField(
                                          controller: profileCubit.bioController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: 'Tap to search location',
                                            hintStyle: const TextStyle(
                                              color: AppColor.lightTextColor,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: 8.h,
                                              horizontal: 10.w,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4.r),
                                              borderSide: BorderSide(
                                                color: AppColor.greyColor.withOpacity(0.4),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4.r),
                                              borderSide: BorderSide(
                                                color: AppColor.greyColor.withOpacity(0.4),
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(4.r),
                                              borderSide: BorderSide(
                                                color: AppColor.greyColor.withOpacity(0.4),
                                              ),
                                            ),
                                            suffixIcon: Icon(
                                              Icons.search,
                                              color: AppColor.greyColor,
                                              size: 20.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Gap(10.h),
                                  CommonTextfield(
                                    title: StringConstant.email,
                                    controller: profileCubit.emailController,
                                    validator: (value) => null,
                                  ),
                                  Gap(10.h),
                                  Text(StringConstant.dateOfBirth,
                                      style: Theme.of(context).textTheme.bodyMedium),
                                  Gap(10.h),
                                  TextFormField(
                                    controller: profileCubit.dobController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      suffixIcon: Icon(
                                        Icons.calendar_today_outlined,
                                        color: AppColor.greyColor.withOpacity(0.4),
                                      ),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.greyColor.withOpacity(0.4))),
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                    ),
                                    onTap: () async {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (pickedDate != null) {
                                        profileCubit.dobController.text =
                                            "${pickedDate.toLocal()}".split(' ')[0];
                                        setState(() {});
                                      }
                                    },
                                    validator: (value) => null,
                                  ),
                                  Gap(20.h),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50.h,
                                    child: ElevatedButton(
                                      onPressed: _isUpdating
                                          ? null
                                          : widget.type == "phone"
                                              ? _handleCheckPhoneSave
                                              : _handleSave,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _isUpdating ? Colors.grey : AppColor.appbarBgColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isUpdating
                                          ? SizedBox(
                                              width: 20.w,
                                              height: 20.h,
                                              child: const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              StringConstant.save,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Gap(32.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Service profile tab (structure only)
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Gap(10.h),
                                CommonTextfield(
                                  title: StringConstant.searchToAutofillAddressInformation,
                                  controller: TextEditingController(),
                                  validator: (v) => null,
                                ),
                                Gap(10.h),
                                Container(
                                  height: 160.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColor.greyColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: AppColor.greyColor.withOpacity(0.3),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    StringConstant.tapMapToSelectLocationAndAutofillAddress,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColor.greyColor),
                                  ),
                                ),
                                Gap(12.h),
                                CommonTextfield(
                                  title: '${StringConstant.address}*',
                                  controller: TextEditingController(),
                                  validator: (v) => null,
                                ),
                                Gap(10.h),
                                CommonTextfield(
                                  title: '${StringConstant.city}*',
                                  controller: TextEditingController(),
                                  validator: (v) => null,
                                ),
                                Gap(10.h),
                                CommonTextfield(
                                  title: StringConstant.state,
                                  controller: TextEditingController(),
                                  validator: (v) => null,
                                ),
                                Gap(10.h),
                                CommonTextfield(
                                  title: '${StringConstant.country}*',
                                  controller: TextEditingController(),
                                  validator: (v) => null,
                                ),
                                Gap(10.h),
                                CommonTextfield(
                                  title: '${StringConstant.pincode}*',
                                  controller: TextEditingController(),
                                  validator: (v) => null,
                                ),
                                Gap(20.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50.h,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.appbarBgColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      StringConstant.save,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                Gap(32.h),
                              ],
                            ),
                          ),
                        ),
                        // Bank details tab
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bank Account Details',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Gap(12.h),
                                  CommonTextfield(
                                    title: '${StringConstant.accountName}*',
                                    controller: profileCubit.accountNameController,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter ${StringConstant.accountName.toLowerCase()}';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Account name must be at least 2 characters';
                                      }
                                      // Allow letters, spaces, and common special characters
                                      final namePattern = RegExp(r'^[a-zA-Z\s\.\-]+$');
                                      if (!namePattern.hasMatch(value.trim())) {
                                        return 'Account name can only contain letters, spaces, dots, and hyphens';
                                      }
                                      return null;
                                    },
                                  ),
                                  Gap(10.h),
                                  CommonTextfield(
                                    title: '${StringConstant.accountNumber}*',
                                    keyboardType: TextInputType.number,
                                    controller: profileCubit.accountNumberController,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter ${StringConstant.accountNumber.toLowerCase()}';
                                      }
                                      // Account number should be numeric and at least 9 digits
                                      final accountNumberPattern = RegExp(r'^[0-9]+$');
                                      if (!accountNumberPattern.hasMatch(value.trim())) {
                                        return 'Account number can only contain digits';
                                      }
                                      if (value.trim().length < 9) {
                                        return 'Account number must be at least 9 digits';
                                      }
                                      if (value.trim().length > 18) {
                                        return 'Account number cannot exceed 18 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                  Gap(10.h),
                                  CommonTextfield(
                                    title: '${StringConstant.ifscCode}*',
                                    controller: profileCubit.ifscCodeController,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter ${StringConstant.ifscCode.toLowerCase()}';
                                      }
                                      // IFSC code format: 4 letters + 0 + 6 alphanumeric
                                      final ifscPattern = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$', caseSensitive: false);
                                      if (!ifscPattern.hasMatch(value.trim())) {
                                        return 'Please enter a valid IFSC code (e.g., HDFC0001234)';
                                      }
                                      return null;
                                    },
                                  ),
                                  Gap(10.h),
                                  CommonTextfield(
                                    title: '${StringConstant.bankName}*',
                                    controller: profileCubit.bankNameController,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter ${StringConstant.bankName.toLowerCase()}';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Bank name must be at least 2 characters';
                                      }
                                      // Allow letters, spaces, and common special characters
                                      final bankNamePattern = RegExp(r'^[a-zA-Z\s\.\-&]+$');
                                      if (!bankNamePattern.hasMatch(value.trim())) {
                                        return 'Bank name can only contain letters, spaces, dots, hyphens, and &';
                                      }
                                      return null;
                                    },
                                  ),
                                  Gap(10.h),
                                  CommonTextfield(
                                    title: StringConstant.upiId,
                                    controller: profileCubit.upiIdController,
                                    validator: (value) {
                                      // UPI ID is optional, but if provided, validate format
                                      if (value == null || value.trim().isEmpty) {
                                        return null; // Optional field
                                      }
                                      // UPI ID format: username@provider (e.g., user@paytm, user@upi)
                                      final upiPattern = RegExp(r'^[a-zA-Z0-9\.\-_]+@[a-zA-Z0-9]+$');
                                      if (!upiPattern.hasMatch(value.trim())) {
                                        return 'Please enter a valid UPI ID (e.g., username@paytm)';
                                      }
                                      return null;
                                    },
                                  ),
                                  Gap(20.h),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50.h,
                                    child: ElevatedButton(
                                      onPressed: _isUpdating
                                          ? null
                                          : () async {
                                              if (!_formKey.currentState!.validate()) {
                                                return;
                                              }
                                              
                                              // Check if data has changed
                                              if (!profileCubit.hasBankDataChanged()) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('No changes to save'),
                                                    backgroundColor: Colors.orange,
                                                  ),
                                                );
                                                return;
                                              }

                                              setState(() {
                                                _isUpdating = true;
                                              });

                                              final success = await profileCubit.saveBankAccountData();

                                              setState(() {
                                                _isUpdating = false;
                                              });

                                              if (success && mounted) {
                                                _showSuccessPopup();
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isUpdating
                                            ? Colors.grey
                                            : AppColor.appbarBgColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isUpdating
                                          ? SizedBox(
                                              width: 20.w,
                                              height: 20.h,
                                              child: const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              StringConstant.save,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Gap(32.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                );
              },
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColor.blackColor
              : AppColor.whiteColor,
          body: const Center(child: CustomLottieLoader()),
        );
      },
    );
  }
}
