import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/kriti/widget/custom_buid_section.dart';
import 'package:devalay_app/src/presentation/kriti/widget/puja_addon_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../data/model/kirti/service_detail_model.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key, required this.serviceModel});
  final ServiceDetailModel serviceModel;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String? selectedPlan;
  String? selectedPlanPrice;
  int? selectedPlanIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColor.whiteColor,
          leadingWidth: 30,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: AppColor.blackColor)),
          title: Text(StringConstant.plan,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColor.blackColor,
                fontWeight: FontWeight.w600,
              ))),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp),
          child: Column(
            children: [
              ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.serviceModel.plans?.length ?? 0,
                  itemBuilder: (context, index) {
                    final plan = widget.serviceModel.plans![index];
                    final isSelected = selectedPlanIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPlanIndex = index;
                          selectedPlanPrice = plan.price.toString();
                          selectedPlan = plan.type;
                        });
                      },
                      child: Card(
                        color: isSelected
                            ? const Color(0XFFFF9500).withOpacity(0.75)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0XFFFF9500).withOpacity(0.75),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(plan.type!.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                          color: isSelected
                                              ? AppColor.whiteColor
                                              : AppColor.orangeColor,
                                          fontWeight: FontWeight.w600)),
                                  Text('₹ ${plan.price!.round()}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                          color: isSelected
                                              ? AppColor.whiteColor
                                              : AppColor.blackColor,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Gap(12.h),
                              buildDescriptionWidget(
                                  plan.description?.html, isSelected)
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Gap(10.sp)),
              if (selectedPlan != null) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PujaAddonScreen(
                          pujaName: widget.serviceModel.name  ??""  ,
                          planName: widget.serviceModel.plans![selectedPlanIndex!].type ??'',
                          planPrice: selectedPlanPrice!,
                          serviceId: widget.serviceModel.id.toString(),
                          planId: widget
                              .serviceModel.plans![selectedPlanIndex!].id
                              .toString(),
                          serviceModel: widget.serviceModel,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 40.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.orangeColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                        child: Text('${StringConstant.book} ${selectedPlan!} ${StringConstant.plan}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColor.whiteColor))),
                  ),
                ),
                Gap(40.sp)
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDescriptionWidget(dynamic description, bool isSelected) {
    if (description == null) return const SizedBox();

    String htmlContent = '';

    if (description is String) {
      if (description.trim().isEmpty) return const SizedBox();
      htmlContent = description;
    } else if (description is Map<String, dynamic>) {
      final htmlData = description['html'];
      if (htmlData is String && htmlData.trim().isNotEmpty) {
        htmlContent = htmlData;
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }

    return IconHtmlListRenderer(
      htmlContent: htmlContent,
      icon: "assets/icon/charm--tick.svg",
      iconColor: isSelected ? AppColor.whiteColor : AppColor.orangeColor,
      textColor: isSelected ? AppColor.whiteColor : AppColor.lightTextColor,
    );
  }
}