import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../contribute/widget/common_textfield.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_button.dart';

class EditSkillScreen extends StatefulWidget {
  const EditSkillScreen({super.key});

  @override
  State<EditSkillScreen> createState() => _EditSkillScreenState();
}

class _EditSkillScreenState extends State<EditSkillScreen> {
  TextEditingController experienceController = TextEditingController();
  TextEditingController travelPreferenceController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  File? bannerImage;
  List<File> galleryFiles = [];
  final _imagePicker = ImagePicker();

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
      {required bool isGallery}) async
  {
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
        galleryFiles.add(cropped); // Add to gallery list
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
    });
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
                        Icon(Icons.camera_alt_outlined, size: 30.sp, color: AppColor.blackColor,),
                        SizedBox(height: 5.h),
                        Text(StringConstant.camera, style: const TextStyle(color: AppColor.blackColor),),
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
                        Icon(Icons.photo, size: 30.sp, color: AppColor.blackColor),
                        SizedBox(height: 5.h),
                        Text(StringConstant.gallery, style: const TextStyle(color: AppColor.blackColor),),
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
      galleryFiles.removeAt(index);
    });

  }

  @override
  void dispose() {
    experienceController.dispose();
    travelPreferenceController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.whiteColor,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: AppColor.blackColor),
        ),
        leadingWidth: 25.sp,
        title: Text(
          StringConstant.editSkill,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColor.blackColor,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.only(left: 15.0.sp, right: 15.sp, bottom: 15.sp, top: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skill Name (Figma design)
              Text(
                "Acharya",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF000000).withOpacity(0.9),
                  letterSpacing: 1,
                ),
              ),
              Gap(4.h),
              // Category
              Text(
                "Spiritual & Religious | Pandit/Purohit",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF000000).withOpacity(0.8),
                  height: 1.4,
                ),
              ),
              Gap(14.h),
              // Available for Online Services
              Text(
                StringConstant.availableForOnlineServices,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF000000).withOpacity(0.9),
                ),
              ),
              Gap(4.h),
              Text(
                "Yes",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF000000).withOpacity(0.8),
                  height: 1.4,
                ),
              ),
              Gap(10.h),
              // Experience
              CommonTextfield(
                title: StringConstant.experience,
                controller: experienceController,
              ),
              Gap(10.h),
              // Travel Preference
              CommonTextfield(
                title: StringConstant.travelPreference,
                controller: travelPreferenceController,
              ),
              Gap(10.h),
              // About
              CommonTextfield(
                title: StringConstant.about,
                controller: aboutController,
                maxLines: 5,
              ),
              Gap(10.h),
              // Upload Past Work Images
              Text(
                StringConstant.uploadPastWorkImages,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF000000).withOpacity(0.9),
                ),
              ),
              Gap(10.h),
              // Image Grid (2 columns matching Figma)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1.32,
                ),
                itemCount: galleryFiles.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () => _showImagePickerModal(isBanner: false),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff241601).withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4.r),
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
                  } else {
                    final galleryIndex = index - 1;
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 0.93,
                            ),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: Image.file(
                              galleryFiles[galleryIndex],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Remove button
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: GestureDetector(
                            onTap: () => _removeGalleryImage(galleryIndex),
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
              Gap(20.h),
              // Save Changes Button
              SizedBox(
                height: 35.h,
                width: MediaQuery.of(context).size.width / 2 - 15,
                child: CustomButton(
                  onTap: () {
                    // TODO: Implement save functionality
                    Navigator.pop(context, true);
                  },
                  buttonAssets: "",
                  borderRadius: BorderRadius.circular(6.r),
                  textColor: AppColor.whiteColor,
                  textButton: StringConstant.saveChanges,
                  btnColor: AppColor.appbarBgColor,
                  mypadding: EdgeInsets.symmetric(vertical: 4.sp),
                ),
              ),
              Gap(20.h),
            ],
          ),
        ),
      ),
    );
  }
}
