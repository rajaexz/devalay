import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_footer_text.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/create/widget/common_guideline_text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:devalay_app/src/presentation/contribute/widget/common_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class TempleInfoWidget extends StatefulWidget {
  const TempleInfoWidget({
    super.key,
    required this.onNext,
    required this.templeId,
    this.governingId,
  });

  final void Function(String templeId, String governingId) onNext;
  final String? templeId;
  final String? governingId;

  @override
  State<TempleInfoWidget> createState() => _TempleInfoWidgetState();
}

class _TempleInfoWidgetState extends State<TempleInfoWidget> {
  final templeInfoFormKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeWebsite = FocusNode();
  final FocusNode _focusNodeGoverning = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePhone = FocusNode();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ContributeTempleCubit>();
    _focusNodeName.addListener(() => _scrollToFocusedField(_focusNodeName));
    _focusNodeWebsite.addListener(() => _scrollToFocusedField(_focusNodeWebsite));
    _focusNodeGoverning.addListener(() => _scrollToFocusedField(_focusNodeGoverning));
    _focusNodeEmail.addListener(() => _scrollToFocusedField(_focusNodeEmail));
    _focusNodePhone.addListener(() => _scrollToFocusedField(_focusNodePhone));
    if (widget.templeId == null) {
      cubit.templeNameController.text = '';
      cubit.templeWebsiteController.text = '';
      cubit.templeGoverningController.text = '';
      cubit.emailController.text = '';
      cubit.phoneController.text = '';
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }
  
  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(_scrollController.position.extentBefore,
            duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNodeName.dispose();
    _focusNodeWebsite.dispose();
    _focusNodeGoverning.dispose();
    _focusNodeEmail.dispose();
    _focusNodePhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributeTempleCubit, ContributeTempleState>(
      listener: (context, state) {
        if (state is ContributeTempleLoaded) {
          final tid = state.templeId;
          final gid = state.governingId;
          if (tid != null && tid.isNotEmpty && gid != null && gid.isNotEmpty) {
            widget.onNext(tid, gid);
          }
        }
      },
      builder: (context, state) {
        final templeCubit = context.read<ContributeTempleCubit>();
        return Form(
          key: templeInfoFormKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                CommonTextfield(
                  isRequired: true,
                  title:
                      "${StringConstant.temples} ${StringConstant.name.toLowerCase()}",
                  controller: templeCubit.templeNameController,
                  validator: templeCubit.templeTitleValidator,
                ),
                Gap(10.h),
                CommonTextfield(
                  title: StringConstant.website,
                  controller: templeCubit.templeWebsiteController,
                  validator: templeCubit.templeWebsiteControllerValidator,
                ),
                Gap(10.h),
                CommonTextfield(
                  isRequired: true,
                  title: StringConstant.panditname,
                  controller: templeCubit.governingName,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter pandit name';
                    }
                    if (value.trim().length < 2) {
                      return 'Pandit name must be at least 2 characters long';
                    }
                    return null;
                  },
                ),
                Gap(10.h),
                CommonTextfield(
                  title: StringConstant.email,
                  controller: templeCubit.governingSubtitle,
                  focusNode: _focusNodeEmail,
                  validator: (value) {
                    // Email is optional, only validate if provided
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
                CommonTextfield(
                  isRequired: true,
                  hintText: "Add 91",
                  title: StringConstant.panditPhoneNumber,
                  controller: templeCubit.governingDescription,
                  focusNode: _focusNodePhone,
                  validator: (value) {
                    // Phone number is required
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter pandit phone number';
                    }
                    // Remove spaces, dashes, and parentheses
                    String cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                    // Regular expression for Indian phone numbers
                    final phonePattern = RegExp(
                      r'^(\+91|91)?[6-9]\d{9}$',
                    );
                    if (!phonePattern.hasMatch(cleanedValue)) {
                      return 'Please enter a valid Indian phone number';
                    }
                    return null;
                  },
                ),
                CommonFooterText(
                  calledFrom: 'first',
                  onNextTap: () async {
                    if (templeInfoFormKey.currentState!
                        .validate()) {
                      if (widget.templeId != null) {
                        await templeCubit.updateTemple(
                          widget.templeId ?? '',
                          widget.governingId ?? '',
                        );
                        // await templeCubit.updateTempleGoverningBody(widget.governingId!);
                      } else {
                        await templeCubit.createTemple();
                      }
                    }
                  },
                ),
                Gap(10.h),
                Guideline(title: StringConstant.guideline, points: [
                  StringConstant.officialTemple,
                  StringConstant.websiteTemple,
                  StringConstant.managingTemple,
                  StringConstant.panditEmail
                ]),
                Gap(10.h)
              ],
            ),
          ),
        );
      },
    );
  }
}
