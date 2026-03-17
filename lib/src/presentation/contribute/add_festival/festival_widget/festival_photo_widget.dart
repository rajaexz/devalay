import 'dart:io';

import 'package:devalay_app/src/application/contribution/contribution_festival/contribution_festival_state.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/core/widget/common_photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_festival/contribution_festival_cubit.dart';
import '../../../core/constants/strings.dart';


class FestivalPhotoWidget extends StatefulWidget {
  const FestivalPhotoWidget({
    super.key, 
    required this.onNext, 
    this.onBack, 
    this.festivalId
  });
  
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? festivalId;

  @override
  State<FestivalPhotoWidget> createState() => _FestivalPhotoWidgetState();
}

class _FestivalPhotoWidgetState extends State<FestivalPhotoWidget> {
  late ContributeFestivalCubit contributeFestivalCubit;
  List<File> bannerFiles = [];
  List<File> galleryFiles = [];
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    contributeFestivalCubit = context.read<ContributeFestivalCubit>();
  }

  Future<void> _uploadAllImages() async {
    if (widget.festivalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Festival ID is required')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final festivalCubit = context.read<ContributeFestivalCubit>();
      
      // Upload banner images if any
      if (bannerFiles.isNotEmpty) {
        await festivalCubit.updateFestivalPhoto(
          widget.festivalId!,
          bannerFiles,
          'Banner',
        );
      }

      // Upload gallery images if any
      if (galleryFiles.isNotEmpty) {
        await festivalCubit.updateFestivalPhoto(
          widget.festivalId!,
          galleryFiles,
          'Gallery',
        );
      }

      // Proceed to next step after successful upload
      widget.onNext();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading images: $e')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeFestivalCubit, ContributeFestivalState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Images Section
                    CommonPhotoPicker(
                      title: StringConstant.pleaseUploadAt,
                      subtitle: StringConstant.ratioShould,
                      allowMultiple: true,
                      onImagesSelected: (files) {
                        setState(() {
                          bannerFiles = files;
                        });
                      },
                    ),
                    Gap(30.h),
                    
                    // Gallery Images Section
                    CommonPhotoPicker(
                      title: StringConstant.pleaseUploadAtLeastSixSalleryImage,
                      subtitle: StringConstant.ratioShould,
                      allowMultiple: true,
                      onImagesSelected: (files) {
                        setState(() {
                          galleryFiles = files;
                        });
                      },
                    ),
                    
                    // Show selected images count
                    if (bannerFiles.isNotEmpty || galleryFiles.isNotEmpty) ...[
                      Gap(20.h),
                      Container(
                        padding: EdgeInsets.all(12.sp),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Images:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Gap(5.h),
                            if (bannerFiles.isNotEmpty)
                              Text('Banner Images: ${bannerFiles.length}'),
                            if (galleryFiles.isNotEmpty)
                              Text('Gallery Images: ${galleryFiles.length}'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            CommonFooterText(
              onNextTap: isUploading
                  ? () {}
                  : () {
                      _uploadAllImages();
                    },
              onBackTap: widget.onBack,
              // You can customize the button text if CommonFooterText supports it
              // nextButtonText: isUploading ? 'Uploading...' : 'Upload & Next',
            ),
          ],
        );
      },
    );
  }
}