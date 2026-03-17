import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_dev/contribution_dev_cubit.dart';
import '../../../../application/contribution/contribution_dev/contribution_dev_state.dart';
import '../../../../application/contribution/god_form/god_form_cubit.dart';
import '../../../../application/contribution/god_form/god_form_state.dart';
import '../../../../data/model/contribution/avatar_model.dart';
import '../../../core/constants/strings.dart';
import '../../../create/widget/common_guideline_text.dart';
import '../../widget/common_footer_text.dart';

class DevAvatarWidget extends StatefulWidget {
  const DevAvatarWidget(
      {super.key, required this.onNext, this.onBack, this.devId});
  final void Function() onNext;
  final VoidCallback? onBack;
  final String? devId;

  @override
  State<DevAvatarWidget> createState() => _DevAvatarWidgetState();
}

class _DevAvatarWidgetState extends State<DevAvatarWidget> {
  bool isChecked = false;
  AvatarModel? selectedTemple;
  String isValue = '';
  bool isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    context.read<GodFormCubit>().fetchAvatarForm();
    super.initState();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    isDropdownOpen = false;
  }

  void _toggleDropdown(List<AvatarModel?> items) {
    if (isDropdownOpen) {
      _removeOverlay();
    } else {
      _showDropdown(items);
    }
    setState(() {
      isDropdownOpen = !isDropdownOpen;
    });
  }

  void _showDropdown(List<AvatarModel?> items) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedTemple = item;
                      });
                      _removeOverlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index == items.length - 1
                                ? Colors.transparent
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        item?.title ?? '',
                        style: TextStyle(
                          color:
                              isChecked ? Colors.grey.shade500 : Colors.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeDevCubit, ContributeDevState>(
        builder: (context, state) {
      final devCubit = context.read<ContributeDevCubit>();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isChecked ? AppColor.appbarBgColor : Colors.grey,
                    width: isChecked ? 2.0 : 2.0,
                  ),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Checkbox(
                  fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    return Colors.white;
                  }),
                  side: BorderSide.none,
                  checkColor: AppColor.appbarBgColor,
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                    if (value == true) {
                      isValue = "on";
                    }
                  },
                ),
              ),
              Gap(8.w),
              Expanded(
                  child: Text(StringConstant.isThisDevTheMostProminent,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.blackColor, fontSize: 14.sp))),
            ],
          ),
          Gap(12.h),
          Text(StringConstant.avatarOf),
          BlocBuilder<GodFormCubit, GodFormState>(builder: (context, state) {
            if (state is GodFormLoaded) {
              if (state.loadingState) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.errorMessage.isNotEmpty) {
                return Center(child: Text(state.errorMessage));
              }

              final items = state.avatarList ?? [];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0.sp),
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: GestureDetector(
                    onTap: isChecked ? null : () => _toggleDropdown(items),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.sp, vertical: 10.sp),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: isChecked ? Colors.grey.shade200 : Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedTemple?.title ?? '',
                              style: TextStyle(
                                color: selectedTemple == null
                                    ? (isChecked
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600)
                                    : (isChecked
                                        ? Colors.grey.shade500
                                        : Colors.black),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(
                            isDropdownOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color:
                                isChecked ? Colors.grey.shade500 : Colors.black,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
          CommonFooterText(
            onNextTap: () {
              devCubit.updateDevAvatar(widget.devId ?? '',
                  selectedTemple?.id.toString() ?? '', isValue.trim());
              widget.onNext();
            },
            onBackTap: widget.onBack,
          ),
          Gap(20.h),
          Guideline(title: StringConstant.guideline, points: [
            StringConstant.guidelineGodAvatar,
            StringConstant.guidelineGodAvatarSelection,
          ]),
          Gap(20.h)
        ],
      );
    });
  }
}
