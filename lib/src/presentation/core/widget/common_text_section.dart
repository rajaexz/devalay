import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../constants/strings.dart';

class CommonTextSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool isReviewMode;
  final Function(String, String)? onObjectionSubmitted;
  final Map<String, bool>? showTextFields;
  final Map<String, TextEditingController>? objectionControllers;

  const CommonTextSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.isReviewMode = false,
    this.onObjectionSubmitted,
    this.showTextFields,
    this.objectionControllers,
  });

  @override
  State<CommonTextSection> createState() => _CommonTextSectionState();
}

class _CommonTextSectionState extends State<CommonTextSection> {
  late bool showTextField;
  late TextEditingController objectionController;

  @override
  void initState() {
    super.initState();
    showTextField = widget.showTextFields?[widget.title] ?? false;
    objectionController = widget.objectionControllers?[widget.title] ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subtitle.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: widget.titleStyle ?? Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          Gap(10.h),
          Text(
            widget.subtitle,
            style: widget.subtitleStyle ?? Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
          if (widget.isReviewMode)
            Column(
              children: [
                Gap(10.h),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showTextField = !showTextField;
                      if (widget.showTextFields != null) {
                        widget.showTextFields![widget.title] = showTextField;
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        StringConstant.objection,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColor.orangeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (showTextField && widget.isReviewMode)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: objectionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "${StringConstant.enterYourObjectionFor} ${widget.title}",
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 8.sp),
                ),
                onChanged: (value) {
                  if (widget.onObjectionSubmitted != null) {
                    widget.onObjectionSubmitted!(widget.title, value);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class CommonTextSectionList extends StatelessWidget {
  final List<Widget> commonTextSection;
  final bool showDivider;
  final EdgeInsets? padding;

  const CommonTextSectionList({
    super.key,
    required this.commonTextSection,
    this.showDivider = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (commonTextSection.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.sp, vertical: 20.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: showDivider ? Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.w,
          ),
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: commonTextSection,
      ),
    );
  }
} 