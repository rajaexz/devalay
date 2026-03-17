import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/explore/widget/read_more_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gap/gap.dart';
import 'package:html/parser.dart' as html_parser;

import '../../../../application/contribution/contribution_dev/contribution_dev_cubit.dart';
import '../../../../application/contribution/contribution_dev/contribution_dev_state.dart';
import '../../../../core/router/router.dart';
import '../../../../data/model/contribution/contribution_dev_model.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';

class ViewDevScreen extends StatefulWidget {
  const ViewDevScreen({super.key, required this.devId, this.calledFrom});
  final String devId;
  final String? calledFrom;
  @override
  State<ViewDevScreen> createState() => _ViewDevScreenState();
}

class _ViewDevScreenState extends State<ViewDevScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  Map<String, bool> showTextFields = {};
  Map<String, TextEditingController> objectionControllers = {};
  final List<GlobalKey> sectionKeys = List.generate(4, (_) => GlobalKey());

  final GlobalKey _essenceKey = GlobalKey();
  final GlobalKey _artiKey = GlobalKey();
  final GlobalKey _bannerKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  late List<GlobalKey> _sectionKeys;

  @override
  void initState() {
    super.initState();
    _sectionKeys = [_essenceKey, _bannerKey, _galleryKey, _artiKey];
    _tabController =
        TabController(length: sectionKeys.length, vsync: this, initialIndex: 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    (widget.calledFrom == 'review')
        ? context
            .read<ContributeDevCubit>()
            .fetchSingleContributeDevData(widget.devId, value: 'true')
        : context
            .read<ContributeDevCubit>()
            .fetchSingleContributeDevData(widget.devId, value: 'false');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    for (var controller in objectionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    for (int i = 0; i < sectionKeys.length; i++) {
      final keyContext = sectionKeys[i].currentContext;
      if (keyContext == null) continue;

      final box = keyContext.findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero, ancestor: null).dy;

      if (offset >= 0 && offset <= 200) {
        if (_tabController.index != i) {
          _tabController.animateTo(i);
        }
        break;
      }
    }
  }

  void _scrollToSection(int index) {
    Scrollable.ensureVisible(
      sectionKeys[index].currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text.trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<ContributeDevCubit, ContributeDevState>(
        builder: (context, state) {
      if (state is ContributeDevLoaded) {
        if (state.loadingState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state.errorMessage.isNotEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text("${StringConstant.view} ${StringConstant.dev}"),
            ),
            body: Center(
              child: Text(state.errorMessage),
            ),
          );
        }
        final dev = state.singleData;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor:
            isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
            elevation: 0,
            leadingWidth: 35,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.whiteColor
                      : AppColor.blackColor),
              onPressed: () {
                AppRouter.pop();
              },
            ),
            title: Text(
              dev?.title ?? '',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppColor.blackColor),
            ),
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TabBar(
                        isScrollable: true,
                        controller: _tabController,
                        onTap: (index) {
                          _scrollToSection(index);
                        },
                        labelColor: isDarkMode
                            ? AppColor.whiteColor
                            : AppColor.blackColor,
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        unselectedLabelColor: AppColor.blackColor,
                        indicatorColor: AppColor.blackColor,
                        indicatorWeight: 2,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          Tab(text: StringConstant.tabEssence),
                          Tab(text: StringConstant.arti),
                          Tab(
                            text: StringConstant.tabBanner,
                          ),
                          Tab(
                            text: StringConstant.gallery,
                          ),
                        ]),
                  ),
                ],
              ),
              Expanded(
                  child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Gap(20.h),
                    BuildSection(
                      whichMode: widget.calledFrom != 'review'
                          ? IconButton(
                              onPressed: () {
                                AppRouter.push(
                                    '/addDev/${dev!.id.toString()}/${'EditDev'}/${0}');
                              },
                              icon: Icon(
                                Icons.edit,
                                color: isDarkMode ? AppColor.orangeColor : null,
                              ))
                          : const SizedBox.shrink(),
                      keyWidget: _essenceKey, // Using unique key
                      temple: dev ?? ContributionDevModel(),
                      value: 0,
                      sectionTitle: StringConstant.tabEssence,
                      commonTextSection: [
                        commonTextSection(
                            StringConstant.title, dev?.title ?? ''),
                        commonTextSection(
                            StringConstant.subtitle, dev?.subtitle ?? ''),
                        commonTextSection(
                            StringConstant.aboutTab, dev?.description ?? ''),
                      ],
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                    ),

                    Gap(15.h),
                    // _buildAartiSection(
                    //     sectionKeys[1], dev ?? ContributionDevModel(), 3),

                    BuildSection(
                      whichMode: widget.calledFrom != 'review'
                          ? IconButton(
                              onPressed: () {
                                AppRouter.push(
                                    '/addDev/${dev!.id.toString()}/${'EditDev'}/${3}');
                              },
                              icon: Icon(
                                Icons.edit,
                                color: isDarkMode ? AppColor.orangeColor : null,
                              ))
                          : const SizedBox.shrink(),
                      keyWidget: _artiKey, // Using unique key
                      temple: dev ?? ContributionDevModel(),
                      value: 1,
                      sectionTitle: StringConstant.arti,
                      commonTextSection: [
                        commonTextSection(StringConstant.arti,
                            parseHtmlString(dev?.aarti?.html ?? '')),
                      ],
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                    ),

                    Gap(15.h),

                    BuildSection(
                      whichMode: const SizedBox
                          .shrink(),
                      keyWidget: _bannerKey,
                      temple: dev ?? ContributionDevModel(),
                      value: -1,
                      sectionTitle: StringConstant.tabBanner,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: dev?.images?.banner ?? [],
                      gridViewItemBuilder: (context, index, item) {
                        return Container(
                          key: widget.key,
                          color: const Color(0xfffffbfb),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.sp, vertical: 10.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(StringConstant.tabBanner,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20.sp)),
                                    // widget.calledFrom != 'review'
                                    //     ? IconButton(
                                    //         onPressed: () {
                                    //           // AppRouter.push(
                                    //           //     '/addEvent/${event.id.toString()}/${'EditEvent'}/$value');
                                    //         },
                                    //         icon: const Icon(Icons.edit))
                                    //     : const SizedBox.shrink()
                                  ],
                                ),
                                Gap(10.h),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10.sp,
                                          mainAxisSpacing: 10.sp,
                                          mainAxisExtent: 50.h),
                                  itemCount: dev?.images?.banner?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final banner = dev?.images?.banner![index];
                                    return Container(
                                        padding: EdgeInsets.all(5.sp),
                                        decoration: BoxDecoration(
                                            color: AppColor.whiteColor,
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                            border: Border.all(
                                                color:
                                                    const Color(0xffe7e7e7))),
                                        child: Row(
                                          children: [
                                            CustomCacheImage(
                                                borderRadius:
                                                    BorderRadius.circular(2.r),
                                                imageUrl: banner?.image ?? '',
                                                height: 30,
                                                width: 30),
                                            Gap(5.w),
                                            Expanded(
                                              flex: 7,
                                              child: Text(
                                                  HelperClass().getImageName(
                                                      banner?.image ?? ''),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                        child: InkWell(
                                                      onTap: () async {
                                                        // await context
                                                        //     .read<ContributeEventCubit>()
                                                        //     .updateAcceptBanner('Event',
                                                        //     widget.eventId,
                                                        //     banner?.id.toString() ?? '',
                                                        //     'true');
                                                      },
                                                      child: Image.asset(
                                                          height: 20.h,
                                                          width: 20.h,
                                                          'assets/icon/right.png'),
                                                    )),
                                                    Expanded(
                                                        child: InkWell(
                                                      onTap: () async {
                                                        // await context.read<ContributeEventCubit>().deleteEventImage('Event',
                                                        //
                                                        //   banner?.id.toString() ?? '',widget.eventId,);
                                                      },
                                                      child: Image.asset(
                                                          height: 20.h,
                                                          width: 20.h,
                                                          'assets/icon/cancel.png'),
                                                    )),
                                                  ],
                                                ))
                                          ],
                                        ));
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      commonTextSection: const [],
                    ),

                    Gap(15.h),
                    BuildSection(
                      whichMode: const SizedBox
                          .shrink(),
                      keyWidget: _galleryKey,
                      temple: dev ?? ContributionDevModel(),
                      value:
                          -1,
                      sectionTitle: StringConstant.gallery,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: dev?.images?.gallery ?? [],
                      gridViewItemBuilder: (context, index, item) {
                      
                        return Container(
                          key: widget.key,
                          color: const Color(0xfffffbfb),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.sp, vertical: 10.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(StringConstant.gallery,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20.sp)),
                                    // widget.calledFrom != 'review'
                                    //     ? IconButton(
                                    //     onPressed: () {
                                    //       // AppRouter.push(
                                    //       //     '/addEvent/${event.id.toString()}/${'EditEvent'}/$value');
                                    //     },
                                    //     icon: const Icon(Icons.edit))
                                    //     : const SizedBox.shrink()
                                  ],
                                ),
                                Gap(10.h),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10.sp,
                                          mainAxisSpacing: 10.sp,
                                          mainAxisExtent: 50.h),
                                  itemCount: dev?.images?.gallery?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final gallery =
                                        dev?.images?.gallery![index];
                                    return Container(
                                        padding: EdgeInsets.all(5.sp),
                                        decoration: BoxDecoration(
                                            color: AppColor.whiteColor,
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                            border: Border.all(
                                                color:
                                                    const Color(0xffe7e7e7))),
                                        child: Row(
                                          children: [
                                            CustomCacheImage(
                                                borderRadius:
                                                    BorderRadius.circular(2.r),
                                                imageUrl: gallery?.image ?? '',
                                                height: 30,
                                                width: 30),
                                            Gap(5.w),
                                            Expanded(
                                              flex: 7,
                                              child: Text(
                                                  HelperClass().getImageName(
                                                      gallery?.image ?? ''),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                        child: InkWell(
                                                      onTap: () async {
                                                        // await context
                                                        //     .read<ContributeEventCubit>()
                                                        //     .updateAcceptBanner('Event',
                                                        //     widget.eventId,
                                                        //     gallery?.id.toString() ?? '',
                                                        //     'true');
                                                      },
                                                      child: Image.asset(
                                                          height: 20.h,
                                                          width: 20.h,
                                                          'assets/icon/right.png'),
                                                    )),
                                                    Expanded(
                                                        child: InkWell(
                                                      onTap: () async {
                                                        // await context.read<ContributeEventCubit>().deleteEventImage('Event',
                                                        //
                                                        //   gallery?.id.toString() ?? '',widget.eventId,);
                                                      },
                                                      child: Image.asset(
                                                          height: 20.h,
                                                          width: 20.h,
                                                          'assets/icon/cancel.png'),
                                                    )),
                                                  ],
                                                ))
                                          ],
                                        ));
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      commonTextSection: const [],
                    ),
                    // Gap(15.h),
                    // _buildDevSection(
                    //     sectionKeys[5], event ?? ContributionEventModel()),
                    Gap(20.h),
                    widget.calledFrom == 'review'
                        ? GestureDetector(
                            onTap: () async {
                              final Map<String, String> rejectReasons = {};

                              objectionControllers.forEach((key, controller) {
                                final value = controller.text.trim();
                                if (value.isNotEmpty) {
                                  rejectReasons[key] = value;
                                }
                              });
                              if (rejectReasons.isEmpty) {
                                // context.read<ContributeEventCubit>().submitEventReview('Event', widget.eventId, "true");
                              } else {
                                print('Contain Data');
                                print('reject_reasons: $rejectReasons');
                                // context.read<ContributeEventCubit>().submitEventReview('Event', widget.eventId, "true", rejectReasons:rejectReasons);
                              }
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.sp, vertical: 5.sp),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    gradient: const LinearGradient(colors: [
                                      AppColor.gradientDarkColor,
                                      AppColor.appbarBgColor
                                    ])),
                                child: Text(StringConstant.submit,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: AppColor.whiteColor))))
                        : const SizedBox(),
                    Gap(20.h)
                  ],
                ),
              ))
            ],
          ),
        );
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    });
  }

  Widget commonTextSection(String title, String subtitle) {
    if (subtitle.isEmpty) {
      return const SizedBox.shrink();
    }

    showTextFields.putIfAbsent(title, () => false);
    objectionControllers.putIfAbsent(title, () => TextEditingController());

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.labelMedium),
              Gap(10.w),
              widget.calledFrom == 'review'
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          showTextFields[title] =
                              !(showTextFields[title] ?? false);
                        });
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 15.sp),
                          Text(StringConstant.objection,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: Colors.grey))
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          Gap(10.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
          ),
          (showTextFields[title] ?? false)
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: objectionControllers[title],
                    maxLines: 2,
                    decoration: InputDecoration(
                        hintText:
                            "${StringConstant.enterYourObjectionFor} $title",
                        border: const OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 8.sp)),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}

class BuildSection extends StatefulWidget {
  final GlobalKey keyWidget;
  final ContributionDevModel temple;
  final int value;
  final bool isDarkMode;
  final List<Widget> commonTextSection;
  final Widget whichMode;
  final String? calledFrom;
  final String sectionTitle;
  final bool hasReadMore;
  final String readMoreText;
  final bool hasGridView;
  final List<dynamic> gridViewItems;
  final Widget Function(BuildContext, int, dynamic)? gridViewItemBuilder;

  const BuildSection({
    required this.whichMode,
    required this.keyWidget,
    required this.temple,
    required this.value,
    required this.isDarkMode,
    required this.calledFrom,
    required this.commonTextSection,
    this.sectionTitle = 'Address',
    this.hasReadMore = false,
    this.readMoreText = "",
    this.hasGridView = false,
    this.gridViewItems = const [],
    this.gridViewItemBuilder,
    super.key,
  });

  @override
  State<BuildSection> createState() => _BuildSectionState();
}

class _BuildSectionState extends State<BuildSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.keyWidget,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.sectionTitle,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                        color: AppColor.blackColor)),
                widget.whichMode,
              ],
            ),
            Gap(10.h),
            if (widget.commonTextSection.isNotEmpty)
              ...widget.commonTextSection,
            if (widget.hasReadMore)
              ReadMoreTextWidget(title: widget.readMoreText),
            if (widget.hasGridView &&
                widget.gridViewItemBuilder != null &&
                (widget.sectionTitle.toLowerCase()) != "gallery")
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  widget.calledFrom != 'review'
                      ? IconButton(
                          onPressed: () {
                            AppRouter.push(
                                '/addDev/${widget.temple.id.toString()}/${'EditDev'}/${(widget.sectionTitle.toLowerCase()) == "banner" ? 1 : 3}');
                          },
                          icon: Icon(
                            Icons.edit,
                            color:
                                widget.isDarkMode ? AppColor.orangeColor : null,
                          ))
                      : const SizedBox.shrink(),
                ],
              ),
            if (widget.hasGridView && widget.gridViewItemBuilder != null)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.sp,
                  mainAxisSpacing: 10.sp,
                  mainAxisExtent: 50.h,
                ),
                itemCount: widget.gridViewItems.length,
                itemBuilder: (context, index) {
                  return widget.gridViewItemBuilder!(
                      context, index, widget.gridViewItems[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}
