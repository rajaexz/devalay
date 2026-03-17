import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:devalay_app/src/application/profile/profile_info_about/profile_info_state.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../application/authentication/login/login_cubit.dart';
import '../../../application/authentication/login/login_state.dart';
import '../../../application/profile/profile_info_about/profile_info_cubit.dart';
import '../../../application/kirti/service/service_cubit.dart';
import '../../../application/kirti/service/service_state.dart';
import '../../../data/model/kirti/language_model.dart';
import '../../contribute/widget/common_textfield.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/image_Helper.dart';
import '../../core/helper/loader.dart';
import '../../core/utils/colors.dart';
import '../custom_widget/custom_intro_button.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen(
      {super.key, required this.onNext,  this.id, this.type, this.onProviderServiceChanged});
  final Function() onNext;
  final int? id;
  final String? type;
  final Function(bool)? onProviderServiceChanged;

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  late LoginCubit loginCubit;
  late final ProfileInfoCubit profileInfoCubit;
  String selectedCountryCode = "+91";
  bool _isUpdating = false;
  bool _showGenderDropdown = false;
  final FocusNode _genderFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final GlobalKey _genderKey = GlobalKey();
  final _imagePicker = ImagePicker();
  File? _profileImageFile;
  File? _backgroundImageFile;
  final GlobalKey<FormFieldState<String>> _phoneFieldKey = GlobalKey<FormFieldState<String>>();
  bool _isProviderService = false;
  LanguageModel? _selectedRole;

  @override
  void initState() {
    loginCubit = context.read<LoginCubit>();
    profileInfoCubit = context.read<ProfileInfoCubit>();
    profileInfoCubit.init(widget.id.toString());
    _genderFocusNode.addListener(() {
      if (_genderFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = _genderKey.currentContext;
          if (context != null) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              alignment: 0.3,
            );
          }
        });
      }
    });
    super.initState();
  }

  Future<bool> _checkAndRequestPermission(ImageSource source) async {
    Permission permission;
    
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // For gallery, check Android version
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          permission = Permission.storage;
        } else {
          permission = Permission.photos;
        }
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      
      if (result.isGranted) {
        return true;
      } else if (result.isPermanentlyDenied) {
        _showPermissionDeniedDialog(source);
        return false;
      } else if (result.isDenied) {
        _showPermissionDeniedDialog(source);
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(source);
      return false;
    }

    return false;
  }


  void _showPermissionDeniedDialog(ImageSource source) {
    final permissionName = source == ImageSource.camera ? 'Camera' : 'Gallery';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionName Permission Required'),
          content: Text(
            '$permissionName permission is required to select images. Please enable it from app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImagePicker(bool isProfileImage) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            child: SizedBox(
              height: 170.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    Icons.camera_alt_outlined,
                    StringConstant.camera,
                    () => _pickImage(ImageSource.camera, isProfileImage),
                  ),
                  _buildImagePickerOption(
                    Icons.photo,
                    StringConstant.gallery,
                    () => _pickImage(ImageSource.gallery, isProfileImage),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, bool isProfileImage) async {
    try {
      // Check and request permission
      final hasPermission = await _checkAndRequestPermission(source);
      
      if (!hasPermission) {
        return;
      }

      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
        maxHeight: 1024,
        maxWidth: 1024,
      );

      if (pickedImage == null) return;

      final aspectRatio = isProfileImage
          ? const CropAspectRatio(ratioX: 1.0, ratioY: 1.0)
          : const CropAspectRatio(ratioX: 5.0, ratioY: 1.0);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: StringConstant.cropImage,
            toolbarColor: AppColor.appbarBgColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
          ),
          IOSUiSettings(
            title: StringConstant.cropImage,
            minimumAspectRatio: 1.0,
          ),
        ],
        aspectRatio: aspectRatio,
      );

      if (croppedFile == null) return;

      setState(() {
        if (isProfileImage) {
          _profileImageFile = File(croppedFile.path);
          context.read<ProfileInfoCubit>().updateProfileImage(_profileImageFile!);
        } else {
          _backgroundImageFile = File(croppedFile.path);
          context
              .read<ProfileInfoCubit>()
              .updateBackgroundImage(_backgroundImageFile!);
        }
      });
    } on PlatformException catch (e) {
  
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        _showPermissionDeniedDialog(source);
      } else {
        // Show generic error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.message ?? "Unable to access image"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
   
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImagePickerOption(
      IconData icon, String label, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.of(context).pop();
        onTap(); 
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30.sp, color: Colors.black),
          SizedBox(height: 5.h),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildCameraButton(VoidCallback onTap,
      {double? height, double? width, bool? isBorder = false}) {
    final double buttonHeight = height ?? 30.h;
    final double buttonWidth = width ?? 30.h;
    return Material(
      color: AppColor.transparentColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(5.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5.r),
        child: Container(
          height: buttonHeight,
          width: buttonWidth,
          decoration: BoxDecoration(
            border: isBorder == true
                ? Border.all(color: AppColor.greyColor, width: 0.8.w)
                : null,
            color: AppColor.lightGrayColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Icon(
            Icons.camera_alt,
            color: AppColor.blackColor.withOpacity(0.5),
            size: buttonHeight * 0.8,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
        builder: (context, state) {
      if (state is ProfileInfoLoaded) {
        if (state.loadingState || _isUpdating) {
          return const Scaffold(
            backgroundColor: AppColor.splashColor,
            body: Center(child: CustomLottieLoader()),
          );
        }
        
        final profileCubit = context.read<ProfileInfoCubit>();
        return Scaffold(
          backgroundColor: AppColor.splashColor,
          resizeToAvoidBottomInset: true,
          body: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              return SafeArea(
                child: Form(
                    key: profileInfoCubit.createProfileFormKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 24.0.sp),
                            child: Focus(
                              focusNode: _genderFocusNode,
                              child: Column(
                                key: _genderKey,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocBuilder<ProfileInfoCubit,
                                      ProfileInfoState>(
                                    builder: (context, state) {
                                      if (state is ProfileInfoLoaded) {
                                        return Center(
                                          child: Stack(
                                            children: [
                                              Hero(
                                                tag: 'avatar',
                                                child: Material(
                                                  elevation: 0,
                                                  shadowColor: Colors.black26,
                                                  shape: const CircleBorder(),
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child:
                                                        state.profileInfoModel
                                                                    ?.dp !=
                                                                null
                                                            ? GestureDetector(
                                                                onTap: () => ImageHelper
                                                                    .showImagePreview(
                                                                        context,
                                                                        state
                                                                            .profileInfoModel
                                                                            ?.dp!),
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundImage:
                                                                      NetworkImage(state
                                                                          .profileInfoModel!
                                                                          .dp!),
                                                                  radius: 55.r,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              )
                                                            : CircleAvatar(
                                                                backgroundColor:
                                                                    Colors.grey
                                                                        .shade200,
                                                                radius: 55.r,
                                                                child: Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 65.r,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400),
                                                              ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 6,
                                                right: 6,
                                                child: _buildCameraButton(
                                                  () => _showImagePicker(true),
                                                  height: 22.h,
                                                  width: 22.w,
                                                  isBorder: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return const Center(
                                        child: Text("No data"),
                                      );
                                    },
                                  ),
                                  Gap(18.h),
                                  CommonTextfield(
                                    isRequired: true,
                                    title: StringConstant.fullName,
                                    controller:
                                        profileInfoCubit.firstNameController,
                                    validator: profileInfoCubit
                                        .userNameValidator,
                                  ),
                                  Gap(10.h),
                                  Text(
                                    "${StringConstant.phoneNumber} *",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                  Gap(10.h),
                                  FormField<String>(
                                    key: _phoneFieldKey,
                                    validator: (value) {
                                      return profileInfoCubit.phoneValidator(
                                          profileInfoCubit.phoneController.text);
                                    },
                                    builder: (FormFieldState<String> state) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              border: Border.all(
                                                  color: state.hasError
                                                      ? Colors.red
                                                      : AppColor.greyColor
                                                          .withOpacity(0.4)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: IgnorePointer(
                                                    ignoring: true,
                                                    child: Opacity(
                                                      opacity: 0.6,
                                                      child: CountryCodePicker(
                                                        onChanged: (countryCode) {
                                                          // Disabled - phone number is read-only
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
                                                        flagWidth: 30.w,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    height: 50.h,
                                                    width: 1,
                                                    color: Colors.grey.shade300),
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: profileInfoCubit
                                                        .phoneController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    focusNode: _phoneFocusNode,
                                                    readOnly: true,
                                                    autovalidateMode: AutovalidateMode.disabled,
                                                    style: TextStyle(fontSize: 16.sp),
                                                    decoration: InputDecoration(
                                                      contentPadding: EdgeInsets.symmetric(
                                                        vertical: 14.sp,
                                                        horizontal: 10.sp,
                                                      ),
                                                      border: InputBorder.none,
                                                      hintText: '',
                                                      hintStyle: TextStyle(
                                                        color: AppColor.placeHolderColor.withOpacity(0.6),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      state.didChange(value);
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          if (state.hasError)
                                            Padding(
                                              padding: EdgeInsets.only(top: 8.h),
                                              child: Text(
                                                state.errorText ?? '',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  Gap(10.h),
                                  CommonTextfield(
                                    title: StringConstant.email,
                                    controller:
                                        profileInfoCubit.emailController,
                                    validator: (value) {
                                      // Email is optional, only validate format if provided
                                      if (value == null || value.trim().isEmpty) {
                                        return null;
                                      }
                                      // Use email_validator plugin for proper email validation
                                      if (!EmailValidator.validate(value.trim())) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  Gap(10.h),
                                  Text(
                                    "${StringConstant.dateOfBirth} *",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                  Gap(10.h),
                                  TextFormField(
                                    controller: profileCubit.dobController,
                                    readOnly: true,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: profileInfoCubit.dobValidator,
                                    decoration: InputDecoration(
                                      suffixIcon: Icon(
                                        Icons.calendar_today_outlined,
                                        color: AppColor.greyColor
                                            .withOpacity(0.4),
                                      ),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: AppColor.greyColor
                                            .withOpacity(0.4),
                                      )),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4.r),
                                        borderSide: const BorderSide(color: Colors.red),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4.r),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                    ),
                                    onTap: () async {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());

                                      final DateTime today = DateTime.now();
                                      final DateTime lastDate = DateTime(
                                          today.year - 18,
                                          today.month,
                                          today.day);

                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate:
                                            lastDate,
                                        firstDate: DateTime(1925),
                                        lastDate:
                                            lastDate,
                                      );

                                      if (pickedDate != null) {
                                        profileCubit.dobController.text =
                                            "${pickedDate.toLocal()}"
                                                .split(' ')[0];
                                        if (profileInfoCubit.createProfileFormKey.currentState != null) {
                                          profileInfoCubit.createProfileFormKey.currentState!.validate();
                                        }
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  Gap(10.h),
                                  Text("${StringConstant.gender} *",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  Gap(10.h),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xffD9D9D9)),
                                      borderRadius:
                                          BorderRadius.circular(4.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.sp),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _showGenderDropdown =
                                              !_showGenderDropdown;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.sp),
                                              child: Text(
                                                profileCubit.dropdownValue ??
                                                    'Select Gender',
                                                style: TextStyle(
                                                  color: profileCubit
                                                              .dropdownValue !=
                                                          null
                                                      ? Colors.black
                                                      : AppColor
                                                          .lightTextColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            _showGenderDropdown
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: AppColor.lightTextColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Gap(8.h),
                                  AnimatedSize(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    child: _showGenderDropdown
                                        ? Container(
                                            height: 150.h,
                                            margin: EdgeInsets.only(top: 4.h),
                                            decoration: BoxDecoration(
                                              color: AppColor.splashColor,
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              border: Border.all(
                                                  color: const Color(
                                                      0xffD9D9D9)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ListView(
                                              shrinkWrap: true,
                                              children: [
                                                'Male',
                                                'Female',
                                                'Other'
                                              ].map((gender) {
                                                final isSelected =
                                                    profileCubit
                                                            .dropdownValue ==
                                                        gender;

                                                return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      profileCubit
                                                              .dropdownValue =
                                                          gender;
                                                      _showGenderDropdown =
                                                          false;
                                                      _genderFocusNode
                                                          .unfocus();
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 18.0.sp,
                                                      vertical: 12.sp,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? AppColor
                                                              .appbarBgColor
                                                              .withOpacity(
                                                                  0.1)
                                                          : Colors
                                                              .transparent,
                                                    ),
                                                    child: Text(
                                                      gender,
                                                      style: TextStyle(
                                                        fontWeight: isSelected
                                                            ? FontWeight.w500
                                                            : FontWeight
                                                                .normal,
                                                        color: isSelected
                                                            ? AppColor
                                                                .appbarBgColor
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  Gap(16.h),
                                  // Provider Services Toggle
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isProviderService,
                                        onChanged: (value) {
                                          setState(() {
                                            _isProviderService = value ?? false;
                                            if (_isProviderService) {
                                              // Fetch roles when enabled
                                              context.read<ServiceCubit>().fetchRoleData();
                                             
                                            } else {
                                              // Clear selected role when disabled
                                              _selectedRole = null;
                                            }
                                              widget.onProviderServiceChanged?.call(_isProviderService);
                                          });
                                        },
                                        activeColor: AppColor.appbarBgColor,
                                      ),


                                      Expanded(
                                        child: Text(
                                          'Do you work as a pandit or provide related services?',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                              
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    child: _isProviderService
                                        ? 
                                        BlocBuilder<ServiceCubit, ServiceState>(
                                            builder: (context, serviceState) {
                                              if (serviceState is ServiceLoadedState) {
                                                if (serviceState.loadingState) {
                                                  return Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                                    child: const Center(
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                  );
                                                }
                                                
                                                final roleList = serviceState.languageList ?? [];
                                                
                                                if (roleList.isEmpty) {
                                                  return const SizedBox.shrink();
                                                }
                                                
                                                return Padding(
                                                  padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                                                  child: Wrap(
                                                    spacing: 8.w,
                                                    runSpacing: 8.h,
                                                    children: roleList.map((role) {
                                                      final isSelected = _selectedRole?.id == role.id;
                                                      
                                                      return InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (isSelected) {
                                                              // Deselect if already selected
                                                              _selectedRole = null;
                                                            } else {
                                                              // Select this role (only one can be selected)
                                                              _selectedRole = role;
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: 16.w,
                                                            vertical: 10.h,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: isSelected
                                                                ? AppColor.appbarBgColor.withOpacity(0.3) // More visible when selected
                                                                : const Color(0xFFFFE4E1).withOpacity(0.8), // Light pink
                                                            borderRadius: BorderRadius.circular(20.r),
                                                            border: Border.all(
                                                              color: isSelected
                                                                  ? AppColor.appbarBgColor
                                                                  : Colors.transparent,
                                                              width: isSelected ? 2 : 0,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                role.name ?? '',
                                                                style: TextStyle(
                                                                  fontSize: 14.sp,
                                                                  color: isSelected
                                                                      ? AppColor.appbarBgColor
                                                                      : const Color(0xFF424242), // Dark grey
                                                                  fontWeight: isSelected
                                                                      ? FontWeight.w600
                                                                      : FontWeight.normal,
                                                                ),
                                                              ),
                                                              if (isSelected) ...[
                                                                Gap(6.w),
                                                                Icon(
                                                                  Icons.check_circle,
                                                                  size: 18.sp,
                                                                  color: AppColor.appbarBgColor,
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                
                        
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.0.sp, 16.h, 24.0.sp, 16.h),
                          child: CustomIntroButton(
                              calledFrom: 'first',
                              onNextTap: () async {
                                if (_showGenderDropdown) {
                                  setState(() {
                                    _showGenderDropdown = false;
                                  });
                                }

                                _phoneFieldKey.currentState?.validate();
                                final isFormValid = profileInfoCubit.createProfileFormKey.currentState!.validate();
                                
                                if (profileCubit.dropdownValue == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select gender'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final phoneError = profileInfoCubit.phoneValidator(
                                    profileInfoCubit.phoneController.text);
                                if (phoneError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(phoneError),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  _phoneFocusNode.requestFocus();
                                  return;
                                }

                                if (!isFormValid) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill all required fields correctly'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isUpdating = true;
                                });

                                try {
                                  final success = await profileInfoCubit
                                      .updateAllLoginTimeData(
                                          selectedCountryCode, context ,_isProviderService);

                                  if (mounted) {
                                    setState(() {
                                      _isUpdating = false;
                                    });

                                    if (success) {
                                      
                                      widget.onNext();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Profile updated successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Failed to update profile'),
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
                               
                                  }
                                }
                              },
                          ),
                        ),
                      ],
                    )),
              );
            },
          ),
        );
      }
      return const Scaffold(
        body: Center(child: CustomLottieLoader()),
      );
    });
  }

  @override
  void dispose() {
    _genderFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }
}