import 'dart:io';

import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CommonPhotoPicker extends StatefulWidget {
  const CommonPhotoPicker({
    super.key,
    required this.onImagesSelected,
    required this.title,
    this.subtitle,
    this.allowMultiple = false,
  });

  final Function(List<File> files) onImagesSelected;
  final String title;
  final String? subtitle;
  final bool allowMultiple;

  @override
  State<CommonPhotoPicker> createState() => _CommonPhotoPickerState();
}

class _CommonPhotoPickerState extends State<CommonPhotoPicker> {
  final _imagePicker = ImagePicker();
  List<Map<String, dynamic>> uploadedImages = [];

  Future<void> _pickMultipleImages() async {
    final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
      imageQuality: 75,
      maxHeight: 1024,
      maxWidth: 1024,
    );

    for (var pickedImage in pickedImages) {
      final croppedFile = await _cropImage(pickedImage.path);
      if (croppedFile == null) continue;

      final file = File(croppedFile.path);
      uploadedImages.add({'file': file, "progress": 0.0, "status": "uploading"});
      _simulateUpload(uploadedImages.length - 1);
    }

    setState(() {});
    final files = uploadedImages.map<File>((e) => e['file'] as File).toList();
    widget.onImagesSelected(files);
  }

  Future<void> _pickSingleImage(ImageSource source) async {
    final pickedImage = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
      maxHeight: 1024,
      maxWidth: 1024,
    );

    if (pickedImage == null) return;

    final croppedFile = await _cropImage(pickedImage.path);
    if (croppedFile == null) return;

    final file = File(croppedFile.path);
    uploadedImages.add({'file': file, 'progress': 0.0, 'status': "uploading"});
    _simulateUpload(uploadedImages.length - 1);

    setState(() {});
    final files = uploadedImages.map<File>((e) => e['file'] as File).toList();
    widget.onImagesSelected(files);
  }

  Future<CroppedFile?> _cropImage(String sourcePath) async {
    return ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColor.appbarBgColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          minimumAspectRatio: 4.3,
        ),
      ],
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
  }

  void _simulateUpload(int index) async {
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          uploadedImages[index]['progress'] = i / 100;
          if (i == 100) uploadedImages[index]['status'] = 'completed';
        });
      }
    }
  }

  Future<void> _showImagePicker() {
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
                      _pickSingleImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 30.sp),
                        SizedBox(height: 5.h),
                        const Text('Camera'),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget.allowMultiple ? _pickMultipleImages() : _pickSingleImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo, size: 30.sp),
                        SizedBox(height: 5.h),
                        const Text('Gallery'),
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

  Widget _buildProgressBar(double value, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: value,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    status == 'completed' ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ),
            Gap(4.w),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: status == 'completed' ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        if (status == 'completed') ...[
          Gap(5.h),
          Text(
            'Upload Complete',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.green,
            ),
          ),
        ] else if (status == 'uploading') ...[
          Gap(5.h),
          Text(
            'Uploading...',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.orange,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Gap(5.h),
        InkWell(
          onTap: _showImagePicker,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 50.sp),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff241601).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               const Icon(Icons.add),
                Gap(5.h),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ),
        Gap(20.h),
        if (uploadedImages.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: uploadedImages.length,
            itemBuilder: (context, index) {
              var image = uploadedImages[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 4.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(image['file'].path.split('/').last),
                      _buildProgressBar(image['progress'], image['status']),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
