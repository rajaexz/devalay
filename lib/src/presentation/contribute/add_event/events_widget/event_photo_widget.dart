import 'dart:io';
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_state.dart';
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
import '../../../../application/contribution/contribution_event/contribution_event_cubit.dart';
import '../../../core/constants/strings.dart';
import '../../../create/widget/common_guideline_text.dart';

class EventPhotoWidget extends StatefulWidget {
  const EventPhotoWidget({
    super.key,
    required this.onNext,
    this.onBack,
    this.eventId,
  });

  final void Function() onNext;
  final VoidCallback? onBack;
  final String? eventId;

  @override
  State<EventPhotoWidget> createState() => _EventPhotoWidgetState();
}

class _EventPhotoWidgetState extends State<EventPhotoWidget> {
  late ContributeEventCubit contributeEventCubit;
  File? bannerImage;
  List<File> galleryFiles = [];
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    contributeEventCubit = context.read<ContributeEventCubit>();
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

    contributeEventCubit.updateEventPhoto(
      widget.eventId!,
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
      contributeEventCubit.updateEventPhoto(
        widget.eventId!,
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

    contributeEventCubit.updateEventPhoto(
      widget.eventId!,
      galleryFiles,
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

    contributeEventCubit.updateEventPhoto(
      widget.eventId!,
      galleryFiles,
      'Gallery',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeEventCubit, ContributeEventState>(
      builder: (context, state) {
        final templeCubit = context.read<ContributeEventCubit>();
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    StringConstant.uploadBannerImage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.appbarBgColor
                    ),
                  ),
                ],
              ),
              Gap(12.h),
              GestureDetector(
                onTap: _pickBannerImage,
                child: Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xff241601).withOpacity(0.3),
                      width: bannerImage != null? 0.sp :1.sp,
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                    color: Colors.white,
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
              Gap(30.h),
              Row(
                children: [
                  Text(
                    StringConstant.uploadGalleryImages,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.appbarBgColor
                    ),
                  ),
                ],
              ),
              Gap(12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.2,
                ),
                itemCount: galleryFiles.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () => _showImagePickerModal(isBanner: false),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                const Color(0xff241601).withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4.r),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: SvgPicture.asset("assets/icon/Plus.svg", height: 40.sp, width: 40.sp,),
                        ),
                      ),
                    );
                  } else {
                    final galleryIndex = index - 1;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: Image.file(
                            galleryFiles[galleryIndex],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Remove button
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: GestureDetector(
                            onTap: () =>
                                _removeGalleryImage(galleryIndex),
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
              CommonFooterText(
                onNextTap: () async {
                  if (bannerImage != null) {
                    await templeCubit.updateEventAllPhoto(
                      widget.eventId!,
                      [bannerImage!],
                      galleryFiles,
                    );
                  }
                  widget.onNext();
                },
                onBackTap: widget.onBack,
              ),
              Gap(20.h),
              Guideline(title: StringConstant.guideline, points: [
                StringConstant.eventPhotoGuideline,
                StringConstant.eventGalleryImage,
                StringConstant.uploadGodHighQualityImages,
                StringConstant.avoidInappropriateImage
              ]),
              Gap(20.h)
            ],
          ),
        );
      },
    );
  }
}
