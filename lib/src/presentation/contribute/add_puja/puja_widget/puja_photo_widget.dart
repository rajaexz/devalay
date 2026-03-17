import 'dart:io';

import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_state.dart';
import 'package:devalay_app/src/presentation/core/widget/common_photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/strings.dart';
import '../../widget/common_footer_text.dart';

class PujaPhotoWidget extends StatefulWidget {
  const PujaPhotoWidget({
    super.key,
    required this.onNext,
    this.onBack,
    this.pujaId,
  });

  final void Function() onNext;
  final VoidCallback? onBack;
  final String? pujaId;

  @override
  State<PujaPhotoWidget> createState() => _PujaPhotoWidgetState();
}

class _PujaPhotoWidgetState extends State<PujaPhotoWidget> {
  List<File> bannerFiles = [];
  List<File> galleryFiles = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributePujaCubit, ContributePujaState>(
      builder: (context, state) {
        final pujaCubit = context.read<ContributePujaCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonPhotoPicker(
                      title: StringConstant.pleaseUploadAt,
                      subtitle: StringConstant.ratioShould,
                      allowMultiple: true,
                      onImagesSelected: (files) {
                        setState(() {
                          bannerFiles = files;
                        });
                        pujaCubit.updatePujaPhoto(
                          widget.pujaId!,
                          files,
                          'Banner',
                        );
                      },
                    ),
                    Gap(30.h),
                    CommonPhotoPicker(
                      title: StringConstant.pleaseUploadAtLeastSixSalleryImage,
                      subtitle: StringConstant.ratioShould,
                      allowMultiple: true,
                      onImagesSelected: (files) {
                        setState(() {
                          galleryFiles = files;
                        });
                        pujaCubit.updatePujaPhoto(
                          widget.pujaId!,
                          files,
                          'Gallery',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            CommonFooterText(
              onNextTap: () async {
                await pujaCubit.updatePujaAllPhoto(
                  widget.pujaId ?? "",
                  bannerFiles,
                  galleryFiles,
                );
                widget.onNext();
              },
              onBackTap: widget.onBack,
            ),
          ],
        );
      },
    );
  }
}
