import 'dart:io';

import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart'
    show RouterConstant;
import 'package:devalay_app/src/core/shared_preference.dart' show PrefManager;
import 'package:devalay_app/src/data/model/kirti/category_model.dart';
import 'package:devalay_app/src/data/model/kirti/experience_model.dart';
import 'package:devalay_app/src/data/model/kirti/expertise_model.dart';
import 'package:devalay_app/src/data/model/kirti/fetch_skill_model.dart';
import 'package:devalay_app/src/data/model/kirti/language_model.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../application/kirti/service/service_cubit.dart';
import '../../../../application/kirti/service/service_state.dart';
import '../../../core/constants/strings.dart';
import '../../../core/helper/loader.dart';
import '../../../core/utils/colors.dart';

class AddSkillScreen extends StatefulWidget {
  final FetchSkillModel? existingSkill;
  final bool? isApbar;
  final Color? isColor;
  final bool? isInside;
  const AddSkillScreen(
      {super.key,
      this.existingSkill,
      this.isApbar,
      this.isColor,
      this.isInside});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  late ServiceCubit serviceCubit;

  TextEditingController aboutController = TextEditingController();
  TextEditingController travelController = TextEditingController();
  File? bannerImage;
  List<File> galleryFiles = [];
  List<String> existingImageUrls = [];
  List<String> removedImageUrls = [];
  final _imagePicker = ImagePicker();
  bool showItems = false;
  bool showItems1 = false;
  bool showItems2 = false;
  LanguageModel? selectedItem;
  CategoryModel? selectedCategory;
  ExpertiseModel? selectedExpertise;
  String selectedGod = '';
  String selectCategory = '';
  String selectExpertise = '';
  bool showItem = false;
  ExperienceModel? selectedExperience;
  TravelPreferenceModel? selectedTravelPreference;
  bool availableOnlineServices = false;
  bool isPandit = false;

 
  bool roleError = false;
  bool categoryError = false;
  bool expertiseError = false;
  bool aboutError = false;
  bool experienceError = false;
  bool travelPreferenceError = false;
  bool imagesError = false;

  // Removed static experienceList - now using API data from ServiceCubit

  /// Travel preference options mapped to backend pk values.
  /// Adjust ids/names here if your backend uses different values.
  final List<TravelPreferenceModel> travelPreferenceList = [
    TravelPreferenceModel(id: 1, name: "Yes"),
    TravelPreferenceModel(id: 2, name: "No"),
  ];

  Future<void> _pickBannerImageFromSource(ImageSource source) async {
    final pickedImage = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
      maxHeight: 1024,
      maxWidth: 1024,
    );

    if (pickedImage == null) return;

    final croppedFile = await _cropImage(pickedImage.path, isGallery: false);
    if (croppedFile == null) return;

    setState(() {
      bannerImage = File(croppedFile.path);
    });
  }

  Future<CroppedFile?> _cropImage(String sourcePath,
      {required bool isGallery}) async {
    return ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColor.blackColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          minimumAspectRatio: 4.0 / 3.0,
        ),
      ],
      aspectRatio: const CropAspectRatio(ratioX: 4.0, ratioY: 3.0),
    );
  }

  Future<void> _pickGalleryImages() async {
    final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
      imageQuality: 75,
      maxHeight: 1024,
      maxWidth: 1024,
    );

    for (var pickedImage in pickedImages) {
      final croppedFile = await _cropImage(pickedImage.path, isGallery: true);
      if (croppedFile == null) continue;

      final File cropped = File(croppedFile.path);

      setState(() {
        galleryFiles.add(cropped);
        imagesError = false; // Clear error when images are added
      });
    }
  }

  Future<void> _pickSingleGalleryImage(ImageSource source) async {
    final pickedImage = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
      maxHeight: 1024,
      maxWidth: 1024,
    );

    if (pickedImage == null) return;

    final croppedFile = await _cropImage(pickedImage.path, isGallery: true);
    if (croppedFile == null) return;

    setState(() {
      galleryFiles.add(File(croppedFile.path));
      imagesError = false; // Clear error when images are added
    });
  }

  void _prefillFromExistingSkill() {
    final skill = widget.existingSkill;
    if (skill == null) return;

    aboutController.text = skill.abouts?.toString() ?? '';
    availableOnlineServices =
        skill.isAvailableForOnline ?? skill.availableForOnlineServices ?? false;

    if (skill.role != null || (skill.skillsDetail?.role?.isNotEmpty ?? false)) {
      selectedItem = LanguageModel(
        id: skill.role,
        name: skill.skillsDetail?.role,
      );
      selectedGod = skill.role?.toString() ?? selectedGod;
    }

    if (skill.category != null ||
        (skill.skillsDetail?.category?.isNotEmpty ?? false)) {
      selectedCategory = CategoryModel(
        id: skill.category,
        category: skill.skillsDetail?.category,
      );
      selectCategory = skill.category?.toString() ?? selectCategory;
    }

    if (skill.expertise != null ||
        (skill.skillsDetail?.expertise?.isNotEmpty ?? false)) {
      selectedExpertise = ExpertiseModel(
        id: skill.expertise,
        expertise: skill.skillsDetail?.expertise,
      );
      selectExpertise = skill.expertise?.toString() ?? selectExpertise;
    }

    if (skill.experience != null) {
      selectedExperience = ExperienceModel(
        id: skill.experience,
        name: skill.skillsDetail!.expertise.toString(),
      );
    }

    final prefId = _parseIntValue(skill.travelPreference);
    if (prefId != null) {
      selectedTravelPreference = _getTravelPreferenceById(prefId);
    }

    // Load existing images
    if (skill.workImages != null && skill.workImages!.isNotEmpty) {
      existingImageUrls = skill.workImages!
          .map((img) {
            if (img is String) return img;
            if (img is Map) {
              // Handle object with 'file', 'image', or 'url' field
              return img['file'] ??
                  img['image'] ??
                  img['url'] ??
                  img['work_image'] ??
                  img.toString();
            }
            return img.toString();
          })
          .where((url) => url != null && url.toString().isNotEmpty)
          .map((url) => url.toString())
          .toList();
    } else if (skill.workImage != null && skill.workImage!.isNotEmpty) {
      existingImageUrls = skill.workImage!
          .map((img) {
            if (img is String) return img;
            if (img is Map) {
              return img['file'] ??
                  img['image'] ??
                  img['url'] ??
                  img['work_image'] ??
                  img.toString();
            }
            return img.toString();
          })
          .where((url) => url != null && url.toString().isNotEmpty)
          .map((url) => url.toString())
          .toList();
    }
  }

  Future<void> _showImagePickerModal({bool isBanner = false}) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            child: SizedBox(
              height: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (isBanner) {
                        _pickBannerImageFromSource(ImageSource.camera);
                      } else {
                        _pickSingleGalleryImage(ImageSource.camera);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 30.sp,
                          color: AppColor.blackColor,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          StringConstant.camera,
                          style: const TextStyle(color: AppColor.blackColor),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (isBanner) {
                        _pickBannerImageFromSource(ImageSource.gallery);
                      } else {
                        _pickGalleryImages();
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo,
                            size: 30.sp, color: AppColor.blackColor),
                        SizedBox(height: 5.h),
                        Text(
                          StringConstant.gallery,
                          style: const TextStyle(color: AppColor.blackColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _removeGalleryImage(int index) {
    setState(() {
      // Check if it's an existing image (URL) or new file
      final totalExisting = existingImageUrls.length;
      if (index < totalExisting) {
        // Remove existing image URL
        final removedUrl = existingImageUrls.removeAt(index);
        removedImageUrls.add(removedUrl);
      } else {
        // Remove new file
        final fileIndex = index - totalExisting;
        galleryFiles.removeAt(fileIndex);
      }

      // Check if all images are removed
      if (existingImageUrls.isEmpty && galleryFiles.isEmpty) {
        imagesError = true;
      } else {
        imagesError = false;
      }
    });
  }

  bool _validateForm() {
    setState(() {
      roleError = selectedItem == null;
      categoryError = selectedCategory == null;
      expertiseError = selectedExpertise == null;
      aboutError = aboutController.text.trim().isEmpty;
      experienceError = selectedExperience == null;
      travelPreferenceError = selectedTravelPreference == null;
      imagesError = existingImageUrls.isEmpty && galleryFiles.isEmpty;
    });

    if (roleError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a role")),
      );
      return false;
    }

    if (categoryError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category")),
      );
      return false;
    }

    if (expertiseError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select expertise")),
      );
      return false;
    }

    if (aboutError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter about information")),
      );
      return false;
    }

    if (experienceError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select experience")),
      );
      return false;
    }

    if (travelPreferenceError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select travel preference")),
      );
      return false;
    }

    if (imagesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please upload at least one past work image")),
      );
      return false;
    }

    return true;
  }

  /// Handles back navigation based on context.
  /// When opened from Service Provider popup (isInside == true), always go to
  /// Landing so user doesn't get stuck on Splash.
  void _handleBackNavigation(bool isPandit) {
    if (widget.isInside == true) {
      AppRouter.go(RouterConstant.landingScreen);
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      AppRouter.go(RouterConstant.landingScreen);
    }
  }

  @override
  void initState() {
    super.initState();

    serviceCubit = context.read<ServiceCubit>();
    context.read<ServiceCubit>().fetchRoleData();
    context.read<ServiceCubit>().fetchExperienceData();
    _prefillFromExistingSkill();
    _loadIsPandit();
  }

  Future<void> _loadIsPandit() async {
    final value = await PrefManager.getIsPandit();
    if (mounted) {
      setState(() {
        isPandit = value ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
        return PopScope(
          canPop: widget.isInside != true && Navigator.canPop(context),
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _handleBackNavigation(isPandit);
            }
          },
          child: Scaffold(
          backgroundColor: (widget.isColor ?? AppColor.whiteColor),
          appBar: widget.isApbar ?? true
              ? AppBar(
                  elevation: 0,
                  backgroundColor: AppColor.whiteColor,
                  leading: IconButton(
                    onPressed: () => _handleBackNavigation(isPandit),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColor.blackColor,
                    ),
                  ),
                  leadingWidth: 30.sp,
                  actions: widget.isInside == true
                      ? [
                          Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: Row(
                              children: [
                                Text(
                                  "Uncheck if not a Pandit",
                                  style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Checkbox(
                                  value: isPandit,
                                  onChanged: (bool? value) {
                                    final newValue = value ?? false;
                                    PrefManager.setIsPandit(newValue);
                                    if (mounted) {
                                      setState(() {
                                        isPandit = newValue;
                                      });
                                      AppRouter.push(
                                          RouterConstant.landingScreen);
                                    }
                                  },
                                  activeColor: AppColor.appbarBgColor,
                                  checkColor: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ]
                      : [],
                  title: Text(
                    widget.existingSkill == null
                        ? StringConstant.addSkill
                        : 'Edit Skill',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColor.blackColor),
                  ),
                )
              : null,
          body: BlocConsumer<ServiceCubit, ServiceState>(
            listener: (context, state) {
              if (state is ServiceLoadedState &&
                  state.errorMessage.isNotEmpty) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(state.errorMessage)),
                  );
                serviceCubit.clearError();
              }
            },
            builder: (context, state) {
              if (state is ServiceLoadedState) {
                if (state.loadingState) {
                  return const Center(child: CustomLottieLoader());
                }
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Skill(1 or more)",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColor.blackColor),
                          ),
                          Gap(18.h),
                          Row(
                            children: [
                              Text(
                                StringConstant.role,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          Gap(8.h),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: roleError
                                      ? Colors.red
                                      : AppColor.boxColor,
                                  width: roleError ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(4)),
                            padding: EdgeInsets.symmetric(horizontal: 8.sp),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 10.sp),
                                  child: Text(
                                    selectedItem != null
                                        ? selectedItem!.name ?? ""
                                        : "Select Role",
                                    style: TextStyle(
                                        color: selectedItem != null
                                            ? AppColor.blackColor
                                            : AppColor.lightTextColor),
                                  ),
                                )),
                                InkWell(
                                  child: showItems
                                      ? const Icon(
                                          Icons.keyboard_arrow_up,
                                          color: AppColor.lightTextColor,
                                        )
                                      : const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColor.lightTextColor,
                                        ),
                                  onTap: () {
                                    setState(() {
                                      showItems = !showItems;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                          if (roleError)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h, left: 8.sp),
                              child: Text(
                                "This field is required",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          Gap(10.h),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: showItems
                                ? BlocProvider(
                                    create: (context) =>
                                        ServiceCubit()..fetchRoleData(),
                                    child:
                                        BlocBuilder<ServiceCubit, ServiceState>(
                                      builder: (context, state) {
                                        if (state is ServiceLoadedState) {
                                          if (state.loadingState) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          if (state.errorMessage.isNotEmpty) {
                                            return Center(
                                                child:
                                                    Text(state.errorMessage));
                                          }

                                          return Container(
                                              margin: EdgeInsets.only(top: 4.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                border: Border.all(
                                                    color: AppColor.boxColor),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              constraints: BoxConstraints(
                                                maxHeight: 250.h,
                                              ),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: state
                                                        .languageList?.length ??
                                                    0,
                                                itemBuilder: (context, index) {
                                                  final items = state
                                                      .languageList?[index];
                                                  final isSelected =
                                                      selectedItem?.id ==
                                                          items?.id;

                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedItem = items;
                                                        selectedGod = items?.id
                                                                ?.toString() ??
                                                            '';
                                                        showItems = false;
                                                        selectedCategory = null;
                                                        selectedExpertise =
                                                            null;
                                                        selectCategory = '';
                                                        selectExpertise = '';
                                                        showItems1 = false;
                                                        showItems2 = false;
                                                        roleError = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  18.0.sp,
                                                              vertical: 12.sp),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? AppColor
                                                                .appbarBgColor
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            items?.name ?? "",
                                                            style: TextStyle(
                                                              color: isSelected
                                                                  ? AppColor
                                                                      .appbarBgColor
                                                                  : AppColor
                                                                      .blackColor,
                                                              fontWeight: isSelected
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .normal,
                                                            ),
                                                          )),
                                                          if (isSelected)
                                                            Icon(
                                                              Icons.check,
                                                              color: AppColor
                                                                  .appbarBgColor,
                                                              size: 20.sp,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ));
                                        }
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      },
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Row(
                            children: [
                              Text(
                                StringConstant.category,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          Gap(8.h),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: categoryError
                                    ? Colors.red
                                    : selectedGod.isEmpty
                                        ? AppColor.boxColor.withOpacity(0.5)
                                        : AppColor.boxColor,
                                width: categoryError ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: selectedGod.isEmpty
                                  ? Colors.grey.withOpacity(0.1)
                                  : Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8.sp),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 10.sp),
                                  child: Text(
                                    selectedCategory != null
                                        ? selectedCategory!.category ?? ""
                                        : selectedGod.isEmpty
                                            ? "Select Role First"
                                            : "Select Category",
                                    style: TextStyle(
                                        color: selectedGod.isEmpty
                                            ? AppColor.lightTextColor
                                                .withOpacity(0.6)
                                            : selectedCategory != null
                                                ? AppColor.blackColor
                                                : AppColor.lightTextColor),
                                  ),
                                )),
                                InkWell(
                                  onTap: selectedGod.isEmpty
                                      ? null
                                      : () {
                                          setState(() {
                                            showItems1 = !showItems1;
                                          });
                                        },
                                  child: showItems1
                                      ? const Icon(
                                          Icons.keyboard_arrow_up,
                                          color: AppColor.lightTextColor,
                                        )
                                      : const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColor.lightTextColor,
                                        ),
                                )
                              ],
                            ),
                          ),
                          if (categoryError)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h, left: 8.sp),
                              child: Text(
                                "This field is required",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          Gap(10.h),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: showItems1 && selectedGod.isNotEmpty
                                ? BlocProvider(
                                    create: (context) => ServiceCubit()
                                      ..fetchCategoryData(selectedGod),
                                    child:
                                        BlocBuilder<ServiceCubit, ServiceState>(
                                      builder: (context, state) {
                                        if (state is ServiceLoadedState) {
                                          if (state.loadingState) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          if (state.errorMessage.isNotEmpty) {
                                            return Center(
                                                child:
                                                    Text(state.errorMessage));
                                          }

                                          if (state.categoryList == null ||
                                              state.categoryList!.isEmpty) {
                                            return Container(
                                              margin: EdgeInsets.only(top: 4.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                border: Border.all(
                                                    color: AppColor.boxColor),
                                              ),
                                              padding: EdgeInsets.all(16.sp),
                                              child: Center(
                                                child: Text(
                                                  "No categories available for selected skill",
                                                  style: TextStyle(
                                                    color:
                                                        AppColor.lightTextColor,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          return Container(
                                              margin: EdgeInsets.only(top: 4.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                border: Border.all(
                                                    color: AppColor.boxColor),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              constraints: BoxConstraints(
                                                maxHeight: 250.h,
                                              ),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: state
                                                        .categoryList?.length ??
                                                    0,
                                                itemBuilder: (context, index) {
                                                  final items = state
                                                      .categoryList?[index];
                                                  final isSelected =
                                                      selectedCategory?.id ==
                                                          items?.id;

                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedCategory =
                                                            items;
                                                        selectCategory = items
                                                                ?.id
                                                                ?.toString() ??
                                                            '';
                                                        showItems1 = false;
                                                        selectedExpertise =
                                                            null;
                                                        selectExpertise = '';
                                                        showItems2 = false;
                                                        categoryError = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  18.0.sp,
                                                              vertical: 12.sp),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? AppColor
                                                                .appbarBgColor
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            items?.category ??
                                                                "",
                                                            style: TextStyle(
                                                              color: isSelected
                                                                  ? AppColor
                                                                      .appbarBgColor
                                                                  : AppColor
                                                                      .blackColor,
                                                              fontWeight: isSelected
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .normal,
                                                            ),
                                                          )),
                                                          if (isSelected)
                                                            Icon(
                                                              Icons.check,
                                                              color: AppColor
                                                                  .appbarBgColor,
                                                              size: 20.sp,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ));
                                        }

                                        return const Center(
                                            child: CircularProgressIndicator());
                                      },
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Row(
                            children: [
                              Text(
                                StringConstant.expertise,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          Gap(8.h),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: expertiseError
                                    ? Colors.red
                                    : selectCategory.isEmpty
                                        ? AppColor.boxColor.withOpacity(0.5)
                                        : AppColor.boxColor,
                                width: expertiseError ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: selectCategory.isEmpty
                                  ? Colors.grey.withOpacity(0.1)
                                  : Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8.sp),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 10.sp),
                                  child: Text(
                                    selectedExpertise != null
                                        ? selectedExpertise!.expertise ?? ""
                                        : selectCategory.isEmpty
                                            ? "Select Category First"
                                            : "Select Expertise",
                                    style: TextStyle(
                                        color: selectCategory.isEmpty
                                            ? AppColor.lightTextColor
                                                .withOpacity(0.6)
                                            : selectedExpertise != null
                                                ? AppColor.blackColor
                                                : AppColor.lightTextColor),
                                  ),
                                )),
                                InkWell(
                                  onTap: selectCategory.isEmpty
                                      ? null
                                      : () {
                                          setState(() {
                                            showItems2 = !showItems2;
                                          });
                                        },
                                  child: showItems2
                                      ? const Icon(
                                          Icons.keyboard_arrow_up,
                                          color: AppColor.lightTextColor,
                                        )
                                      : const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColor.lightTextColor,
                                        ),
                                )
                              ],
                            ),
                          ),
                          if (expertiseError)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h, left: 8.sp),
                              child: Text(
                                "This field is required",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          Gap(10.h),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: showItems2 && selectCategory.isNotEmpty
                                ? BlocProvider(
                                    create: (context) => ServiceCubit()
                                      ..fetchExpertiseData(
                                          selectedGod, selectCategory),
                                    child:
                                        BlocBuilder<ServiceCubit, ServiceState>(
                                      builder: (context, state) {
                                        if (state is ServiceLoadedState) {
                                          if (state.loadingState) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (state.errorMessage.isNotEmpty) {
                                            return Center(
                                                child:
                                                    Text(state.errorMessage));
                                          }
                                          if (state.expertiseList == null ||
                                              state.expertiseList!.isEmpty) {
                                            return Container(
                                              margin: EdgeInsets.only(top: 4.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                border: Border.all(
                                                    color: AppColor.boxColor),
                                              ),
                                              padding: EdgeInsets.all(16.sp),
                                              child: Center(
                                                child: Text(
                                                  "No expertise available for selected category",
                                                  style: TextStyle(
                                                    color:
                                                        AppColor.lightTextColor,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          return Container(
                                              margin: EdgeInsets.only(top: 4.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                border: Border.all(
                                                    color: AppColor.boxColor),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              constraints: BoxConstraints(
                                                maxHeight: 250.h,
                                              ),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: state.expertiseList
                                                        ?.length ??
                                                    0,
                                                itemBuilder: (context, index) {
                                                  final items = state
                                                      .expertiseList?[index];
                                                  final isSelected =
                                                      selectedExpertise?.id ==
                                                          items?.id;

                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedExpertise =
                                                            items;
                                                        selectExpertise = items
                                                                ?.id
                                                                ?.toString() ??
                                                            '';
                                                        showItems2 = false;
                                                        expertiseError = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  18.0.sp,
                                                              vertical: 12.sp),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? AppColor
                                                                .appbarBgColor
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            items?.expertise ??
                                                                "",
                                                            style: TextStyle(
                                                              color: isSelected
                                                                  ? AppColor
                                                                      .appbarBgColor
                                                                  : AppColor
                                                                      .blackColor,
                                                              fontWeight: isSelected
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .normal,
                                                            ),
                                                          )),
                                                          if (isSelected)
                                                            Icon(
                                                              Icons.check,
                                                              color: AppColor
                                                                  .appbarBgColor,
                                                              size: 20.sp,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ));
                                        }
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      },
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Gap(10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                StringConstant.availableForOnlineServices,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              SizedBox(
                                height: 30.sp,
                                width: 50.sp,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: CupertinoSwitch(
                                    value: availableOnlineServices,
                                    activeColor: const Color.fromARGB(
                                        255, 157, 224, 160),
                                    inactiveThumbColor: const Color.fromARGB(
                                        255, 197, 197, 197),
                                    thumbColor:
                                        const Color.fromARGB(255, 16, 139, 92),
                                    trackColor: const Color.fromARGB(
                                        255, 232, 232, 232),
                                    onChanged: (value) {
                                      setState(() =>
                                          availableOnlineServices = value);
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                          Gap(20.h),
                          Row(
                            children: [
                              Text(
                                StringConstant.about,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          Gap(8.h),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    aboutError ? Colors.red : AppColor.boxColor,
                                width: aboutError ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: aboutController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Enter about information',
                                hintStyle: const TextStyle(
                                    color: AppColor.lightTextColor),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.sp,
                                  vertical: 10.sp,
                                ),
                              ),
                              onChanged: (value) {
                                if (aboutError && value.trim().isNotEmpty) {
                                  setState(() {
                                    aboutError = false;
                                  });
                                }
                              },
                            ),
                          ),
                          if (aboutError)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h, left: 8.sp),
                              child: Text(
                                "This field is required",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          Gap(10.h),
                          Row(
                            children: [
                              Text(
                                StringConstant.experience,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          Gap(8.h),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: experienceError
                                      ? Colors.red
                                      : AppColor.boxColor,
                                  width: experienceError ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(4)),
                            padding: EdgeInsets.symmetric(horizontal: 8.sp),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 10.sp),
                                  child: Text(
                                    selectedExperience != null
                                        ? selectedExperience!.name ?? ""
                                        : "Select Experience",
                                    style: TextStyle(
                                        color: selectedExperience != null
                                            ? AppColor.blackColor
                                            : AppColor.lightTextColor),
                                  ),
                                )),
                                InkWell(
                                  child: showItem
                                      ? const Icon(
                                          Icons.keyboard_arrow_up,
                                          color: AppColor.lightTextColor,
                                        )
                                      : const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColor.lightTextColor,
                                        ),
                                  onTap: () {
                                    setState(() {
                                      showItem = !showItem;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                          if (experienceError)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h, left: 8.sp),
                              child: Text(
                                "This field is required",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          Gap(10.h),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: showItem
                                ? BlocBuilder<ServiceCubit, ServiceState>(
                                    builder: (context, state) {
                                      final apiExperienceList =
                                          state is ServiceLoadedState
                                              ? (state.experienceList ?? [])
                                              : [];

                                      if (apiExperienceList.isEmpty) {
                                        return Container(
                                          padding: EdgeInsets.all(16.sp),
                                          child: Center(
                                            child: Text(
                                              'Loading experience data...',
                                              style: TextStyle(
                                                color: AppColor.lightTextColor,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return Container(
                                        margin: EdgeInsets.only(top: 4.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                          border: Border.all(
                                              color: AppColor.boxColor),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        constraints: BoxConstraints(
                                          maxHeight: 250.h,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: apiExperienceList.length,
                                          itemBuilder: (context, index) {
                                            final experience =
                                                apiExperienceList[index];
                                            final isSelected =
                                                selectedExperience?.id ==
                                                    experience.id;

                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedExperience =
                                                      ExperienceModel(
                                                    id: experience.id,
                                                    name: experience.name,
                                                  );
                                                  showItem = false;
                                                  experienceError = false;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 18.0.sp,
                                                    vertical: 12.sp),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColor.appbarBgColor
                                                          .withOpacity(0.1)
                                                      : Colors.transparent,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                      experience.name ?? "",
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? AppColor
                                                                .appbarBgColor
                                                            : AppColor
                                                                .blackColor,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                    )),
                                                    if (isSelected)
                                                      Icon(
                                                        Icons.check,
                                                        color: AppColor
                                                            .appbarBgColor,
                                                        size: 20.sp,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Gap(10.h),
                          Text(
                            StringConstant.travelPreference,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Gap(6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: travelPreferenceError
                                    ? Colors.red
                                    : AppColor.boxColor,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<TravelPreferenceModel>(
                                value: selectedTravelPreference,
                                isExpanded: true,
                                hint: const Text('Select'),
                                items: travelPreferenceList
                                    .map(
                                      (e) => DropdownMenuItem<
                                          TravelPreferenceModel>(
                                        value: e,
                                        child: Text(e.name ?? ''),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTravelPreference = value;
                                    travelPreferenceError = false;
                                  });
                                },
                              ),
                            ),
                          ),
                          Gap(10.h),
                          Row(
                            children: [
                              Text(
                                StringConstant.uploadPastWorkImages,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          Gap(10.h),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: imagesError
                                    ? Colors.red
                                    : Colors.transparent,
                                width: imagesError ? 1.5 : 0,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 5.w,
                                mainAxisSpacing: 5.h,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: existingImageUrls.length +
                                  galleryFiles.length +
                                  1,
                              itemBuilder: (context, index) {
                                // First item is always the "Add" button
                                if (index == 0) {
                                  return GestureDetector(
                                    onTap: () =>
                                        _showImagePickerModal(isBanner: false),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xff241601)
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          "assets/icon/Plus.svg",
                                          height: 40.sp,
                                          width: 40.sp,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                // Adjust index for actual images (subtract 1 for the add button)
                                final imageIndex = index - 1;

                                // Check if it's an existing image (URL) or new file
                                if (imageIndex < existingImageUrls.length) {
                                  // Display existing image from URL
                                  final imageUrl =
                                      existingImageUrls[imageIndex];
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        child: Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40.sp,
                                                color: Colors.grey[600],
                                              ),
                                            );
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 4.h,
                                        right: 4.w,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _removeGalleryImage(imageIndex),
                                          child: Container(
                                            padding: EdgeInsets.all(2.sp),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: 12.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // Display new file
                                  final fileIndex =
                                      imageIndex - existingImageUrls.length;
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        child: Image.file(
                                          galleryFiles[fileIndex],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4.h,
                                        right: 4.w,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _removeGalleryImage(imageIndex),
                                          child: Container(
                                            padding: EdgeInsets.all(2.sp),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: 12.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                          if (imagesError)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h, left: 8.sp),
                              child: Text(
                                "Please upload at least one image",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          // Find the submit button section (around line 1089) and wrap it with condition:

                          Gap(10.h),

                          SizedBox(
                            height: 35.h,
                            width: double.infinity,
                            child: CustomButton(
                              onTap: () async {
                                if (_validateForm()) {
                               
                                  try {
                                    context
                                        .read<ServiceCubit>()
                                        .updateSkillData(
                                          isPandit: isPandit,
                                          workImages: galleryFiles,
                                          context: context,
                                          skillId:
                                              selectedItem!.id?.toString() ??
                                                  '',
                                          categoryId: selectedCategory!.id
                                                  ?.toString() ??
                                              '',
                                          expertiseId: selectedExpertise!.id
                                                  ?.toString() ??
                                              '',
                                          available: availableOnlineServices
                                              .toString(),
                                          about: aboutController.text.trim(),
                                          experience: selectedExperience!.id
                                                  ?.toString() ??
                                              '',
                                          travelPreference:
                                              selectedTravelPreference?.id
                                                      ?.toString() ??
                                                  '',
                                        );

                                    // Show success message and navigate appropriately
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Skill added successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      // If opened from Service Provider popup (isInside == true),
                                      // go directly to landing instead of popping back to splash.
                                      if (widget.isInside == true) {
                                        AppRouter.go(RouterConstant.landingScreen);
                                      } else if (Navigator.canPop(context)) {
                                        Navigator.pop(context, true);
                                      }
                                    }

                                  
                                  } catch (e) {
                                    // Hide loading
                                    if (mounted) Navigator.pop(context);

                                    // Show error message
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              buttonAssets: "",
                              borderRadius: BorderRadius.circular(6.r),
                              textColor: AppColor.whiteColor,
                              textButton: StringConstant.submit,
                              btnColor: AppColor.appbarBgColor,
                              mypadding: EdgeInsets.symmetric(vertical: 4.sp),
                            ),
                          ),

                          Gap(20.h),
                        ]),
                  ),
                );
              }
              return const Center(child: CustomLottieLoader());
            },
          ),
          ),
    );
  }

  int? _parseIntValue(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  TravelPreferenceModel? _getTravelPreferenceById(int? id) {
    if (id == null) return null;
    for (final item in travelPreferenceList) {
      if (item.id == id) return item;
    }
    return null;
  }
}
class TravelPreferenceModel {
  final int? id;
  final String? name;

  TravelPreferenceModel({this.id, this.name});
}
