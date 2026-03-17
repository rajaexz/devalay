import 'package:devalay_app/src/application/kirti/service/service_cubit.dart';
import 'package:devalay_app/src/application/kirti/service/service_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/kriti/plan_screen.dart';
import 'package:devalay_app/src/presentation/widgets/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'custom_buid_section.dart';
import 'numbered_html_custom.dart';
import '../../core/widget/translatable_text_widget.dart';

class PujaServiceDetailScreen extends StatefulWidget {
  const PujaServiceDetailScreen(
      {super.key, required this.pujaName, required this.serviceId});
  final String pujaName;
  final String serviceId;

  @override
  State<PujaServiceDetailScreen> createState() =>
      _PujaServiceDetailScreenState();
}

class _PujaServiceDetailScreenState extends State<PujaServiceDetailScreen> {
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
          title: TranslatableTextWidget(
            text: widget.pujaName,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500, color: AppColor.blackColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
      body: SingleChildScrollView(
        child: BlocProvider(
          create: (context) =>
              ServiceCubit()..fetchSingleServiceData(widget.serviceId),
          child:  BlocBuilder<ServiceCubit, ServiceState>(
            builder: (context, state) {
              if (state is ServiceLoadedState) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.errorMessage.isNotEmpty) {
                  return Center(child: Text(state.errorMessage));
                }

                final item = state.service;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                        aspectRatio: 4 / 3,
                        child: CustomCacheImage(
                          imageUrl: item?.images ?? '',
                          borderRadius: BorderRadius.zero,
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(20.h),
                          TranslatableTextWidget(
                            text: StringConstant.description,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              color: AppColor.blackColor,
                            ),
                          ),
                          Gap(10.h),
                          Html(
                            data: item?.description!.html!.trim() ?? '',
                            shrinkWrap: true,
                            style: {
                              "p": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                lineHeight: LineHeight(1.8.sp), // Reduce line height
                              ),
                              "div": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "br": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "body": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "*": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                            },
                            extensions: [
                              TagExtension(
                                tagsToExtend: {"p"},
                                builder: (extensionContext) {
                                  final text = extensionContext.element?.text ?? '';
                                  if (text.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return TranslatableTextWidget(
                                    text: text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          height: 1.8,
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Gap(10.h),
                          TranslatableTextWidget(
                            text: StringConstant.benefits,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: AppColor.blackColor,
                                   ),
                          ),
                          Gap(12.h),
                          IconHtmlListRenderer(
                            htmlContent: item?.benefits!.html ?? '',
                            icon: "assets/icon/charm--tick.svg",
                            iconColor: AppColor.lightTextColor,
                          ),
                          Gap(10.h),
                          TranslatableTextWidget(
                            text: StringConstant.steps,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: AppColor.blackColor,
                            ),
                          ),
                          Gap(12.h),
                          // Html(data: item?.steps.html ?? ''),
                          NumberedHtmlListRenderer(
                            htmlContent: item?.steps!.html ?? '',
                          ),
                          Gap(10.h),
                          TranslatableTextWidget(
                            text: StringConstant.duration,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: AppColor.blackColor,
                                    ),
                          ),
                          Gap(12.h),
                          TranslatableTextWidget(
                            text: item?.duration ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap(30.h),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PlanScreen(serviceModel: item!)
                                  ));
                            },
                            child: Container(
                              height: 40.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColor.orangeColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Center(
                                  child: Text(StringConstant.next,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: AppColor.whiteColor))),
                            ),
                          ),
                          Gap(30.h),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
