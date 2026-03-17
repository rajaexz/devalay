

import 'package:devalay_app/src/application/feed/feed_home/feed_home_cubit.dart';
import 'package:devalay_app/src/application/feed/feed_home/feed_home_state.dart';
import 'package:devalay_app/src/data/model/feed/Report_reason_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';

import 'package:devalay_app/src/presentation/core/widget/blurred_dialoge_box.dart';
import 'package:devalay_app/src/presentation/core/helper/show_blurred_dialoge.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
class PostOptionsBottomSheet<T> extends StatelessWidget {
  final T feeData;
  final BuildContext context;
  final String loggedInUserId;
  final int? Function(T) getId;

  final bool? Function(T) getReport;
  final dynamic Function(T) getUser;
  final void Function(BuildContext, int id) onDelete;
  final void Function(BuildContext, int id, bool newSaved) onSaveToggle;

  final void Function(BuildContext, T feeData) onEdit;

  const PostOptionsBottomSheet({
    super.key,
    required this.feeData,
    required this.context,
    required this.loggedInUserId,
    required this.getId,

    required this.getReport,
    required this.getUser,
    required this.onDelete,
    required this.onSaveToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final feedHomeCubit = context.read<FeedHomeCubit>();
    feedHomeCubit.fetchReportReasons();
    final isOwner = getUser(feeData)?.user?.id == int.tryParse(loggedInUserId);

    void warningWidget() {
   
      showBlurredDialoge(
        context,
        dialoge: BlurredDialogBox(
          title: StringConstant.deletePostTitle,
          onAccept: () async {
            onDelete(context, getId(feeData)!);
          },
       
          content: Text(StringConstant.areYouSureDeletePost),
        ),
      );
    }

    showReportDialog(
        BuildContext context, List<ReportReason> reasons, Function() onReport) {
      int? selectedReasonId;
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(StringConstant.reportPost),
                content: DropdownButton<int>(
                  value: selectedReasonId,
                  hint: Text(StringConstant.selectReason),
                  isExpanded: true,
                  items: reasons.map((reason) {
                    return DropdownMenuItem<int>(
                      value: reason.id,
                      child: Text(reason.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedReasonId = value;
                    });
                  },
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        mypadding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        onTap: () => Navigator.pop(context),
                        buttonAssets: '',
                        textButton: StringConstant.cancel,
                      ),
                      CustomButton(
                        mypadding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        onTap: selectedReasonId != null
                            ? () {
                                Navigator.pop(context);

                                feedHomeCubit.isReportPost(
                                    getUser(feeData)!.id.toString(),
                                    selectedReasonId!);
                              }
                            : () {},
                        buttonAssets: '',
                        textColor: selectedReasonId != null
                            ? AppColor.whiteColor
                            : null,
                        btnColor: selectedReasonId != null
                            ? AppColor.appbarBgColor
                            : null,
                        textButton: selectedReasonId != null
                            ? StringConstant.report
                            : ' ',
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
      );
    }

    void reportWidget(isReport) {
      showReportDialog(context, feedHomeCubit.reportReasons, () {});
    }

    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColor.blackColor
              : AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          border: Border(
            right: BorderSide(color: accentColor, width: 2.w),
            left: BorderSide(color: accentColor, width: 2.w),
            top: BorderSide(color: accentColor, width: 2.w),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(20.h),
            Container(
              alignment: Alignment.center,
              width: 70,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColor.whiteColor
                    : Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 40, bottom: 20),
              child: Column(
                children: [
                 
                  Gap(13.h),
                  BlocBuilder<FeedHomeCubit, FeedHomeState>(
                    builder: (context, state) {
                      final isReport = getReport(feeData) ?? false;
                      return !isReport
                          ? rowImageIcon(
                              context: context,
                              onTap: () => reportWidget(isReport),
                              isSVG: true,
                              h: 25.h,
                              s: 10,
                              w: 25.w,
                              imag: "assets/icon/flag.svg",
                              text: StringConstant.report,
                            )
                          : Gap(0.h);
                    },
                  ),
                  Gap(10.h),
                  if (isOwner) ...[
                    // rowImageIcon(
                    //   context: context,
                    //   onTap: () => onEdit(context, feeData),
                    //   isSVG: true,
                    //   h: 25.h,
                    //   s: 10,
                    //   w: 25.w,
                    //   imag: "assets/icon/Edit.svg",
                    //   text: StringConstant.edit,
                    // ),
                    // Gap(13.h),
                    rowImageIcon(
                      context: context,
                      onTap: () =>warningWidget(),
                      isSVG: true,
                      h: 25.h,
                      s: 10,
                      w: 25.w,
                      imag: "assets/icon/delete.svg",
                      text: StringConstant.delete,
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
