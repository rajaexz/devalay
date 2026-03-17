import 'dart:io';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../application/contribution/contribution_temple/contribution_temple_cubit.dart';
import '../../../../application/contribution/contribution_temple/contribution_temple_state.dart';
import '../../../core/constants/strings.dart';
import '../../../create/widget/common_guideline_text.dart';

class TemplePhotoWidget extends StatefulWidget {
  const TemplePhotoWidget({
    super.key,
    required this.onNext,
    this.onBack,
    this.calledFrom,
    this.templeId,
  });

  final void Function() onNext;
  final String? calledFrom;
  final VoidCallback? onBack;
  final String? templeId;

  @override
  State<TemplePhotoWidget> createState() => _TemplePhotoWidgetState();
}

class _TemplePhotoWidgetState extends State<TemplePhotoWidget> {
  late ContributeTempleCubit contributeTempleCubit;
  File? bannerImage;
  List<File> galleryFiles = [];
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    contributeTempleCubit = context.read<ContributeTempleCubit>();
  }

  Future<void> _pickBannerImage() async {
    await _showImagePickerModal(isBanner: true);
  }

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

    // Update banner image immediately
    contributeTempleCubit.updateTempleBannerPhoto(
      widget.templeId!,
      [bannerImage!],
      'Banner',
    );
  }

  void _removeBannerImage() {
    setState(() {
      bannerImage = null;
    });
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

      // ✅ Hit API immediately after each crop with full galleryFiles
      contributeTempleCubit.updateTempleBannerPhoto(
        widget.templeId!,
        galleryFiles,
        'Gallery',
      );
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

    // Update gallery images immediately with ALL gallery files
    contributeTempleCubit.updateTempleBannerPhoto(
      widget.templeId!,
      galleryFiles, // This should contain all gallery images
      'Gallery',
    );
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
                        Text(StringConstant.camera, style: const TextStyle( color: AppColor.blackColor,)),
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
                        Icon(Icons.photo, size: 30.sp, color: AppColor.blackColor,),
                        SizedBox(height: 5.h),
                        Text(StringConstant.gallery, style: const TextStyle( color: AppColor.blackColor,),),
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

    // Update gallery images immediately with remaining files
    contributeTempleCubit.updateTempleBannerPhoto(
      widget.templeId!,
      galleryFiles,
      'Gallery',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        final templeCubit = context.read<ContributeTempleCubit>();
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image Label (Figma style)
              RichText(
                text: TextSpan(
                  text: StringConstant.uploadBannerImage,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF374151),
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFFF9500),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(12.h),
              // Banner Image Upload Box (Figma style)
              GestureDetector(
                onTap: _pickBannerImage,
                child: Container(
                  height: 180.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: bannerImage != null 
                          ? Colors.transparent 
                          : const Color(0xFFD1D5DB),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    color: const Color(0xFFF9FAFB),
                  ),
                  child: bannerImage != null
                      ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.file(
                          bannerImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                      Center(
                        child: SvgPicture.asset("assets/icon/Plus.svg",),
                      ),
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: _removeBannerImage,
                          child: Container(
                            padding: EdgeInsets.all(4.sp),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Center(
                    child: SvgPicture.asset("assets/icon/Plus.svg",),
                  ),
                ),
              ),
              Gap(24.h),
              // Gallery Images Label (Figma style)
              RichText(
                text: TextSpan(
                  text: StringConstant.uploadGalleryImages,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF374151),
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFFF9500),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(12.h),
              // Gallery Grid (Figma 2x2 layout with + icons)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 1.6,
                ),
                itemCount: galleryFiles.length < 4 
                    ? galleryFiles.length + 1 
                    : galleryFiles.length,
                itemBuilder: (context, index) {
                  // Show add button if less than 4 images
                  if (index == galleryFiles.length && galleryFiles.length < 4) {
                    return GestureDetector(
                      onTap: () => _showImagePickerModal(isBanner: false),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          color: const Color(0xFFF9FAFB),
                        ),
                        child: Center(
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF9CA3AF),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 24.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            galleryFiles[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6.h,
                          right: 6.w,
                          child: GestureDetector(
                            onTap: () => _removeGalleryImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4.sp),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 14.sp,
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
              CommonFooterText(
                onNextTap: () async {
                  if (bannerImage != null || galleryFiles.isNotEmpty) {
                    await templeCubit.updateTemplePhoto(
                      widget.templeId!,
                      bannerImage != null ? [bannerImage!] : [],
                      galleryFiles, // This contains all gallery images
                    );
                  }
                  widget.onNext();
                },
                onBackTap: widget.onBack,
              ),
              Gap(20.h),
              Guideline(title: StringConstant.guideline, points: [
                StringConstant.bannerImageGuideline,
                StringConstant.galleryImageGuideline,
                StringConstant.imageHighQuality,
                StringConstant.avoidInappropriateImage,
              ]),
              Gap(20.h)
            ],
          ),
        );
      },
    );
  }
}