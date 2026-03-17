import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/explore/widget/read_more_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../application/contribution/contribution_temple/contribution_temple_cubit.dart';
import '../../../../core/router/router.dart';
import '../../../../data/model/contribution/contribution_event_model.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/widget/custom_cache_image.dart';
import '../../../core/widget/common_text_section.dart';

class ViewEventScreen extends StatefulWidget {
  const ViewEventScreen({super.key, required this.eventId, this.calledFrom});
  final String eventId;
  final String? calledFrom;

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  Map<String, bool> showTextFields = {};
  Map<String, TextEditingController> objectionControllers = {};

  final List<GlobalKey> sectionKeys = List.generate(6, (_) => GlobalKey());

  final GlobalKey _essenceKey = GlobalKey();
  final GlobalKey _addressDKey = GlobalKey();
  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _addressKey = GlobalKey();
  final GlobalKey _bannerKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final GlobalKey _devKey = GlobalKey();
  late List<GlobalKey> _sectionKeys;
  @override
  void initState() {
    super.initState();
    _sectionKeys = [
      _essenceKey,
      _addressKey,
      _addressDKey,
      _dateKey,
      _bannerKey,
      _galleryKey,
      _devKey,
    ];

    _tabController = _tabController = TabController(
        length: _sectionKeys.length, vsync: this, initialIndex: 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    (widget.calledFrom == 'review')
        ? context
            .read<ContributeEventCubit>()
            .fetchSingleContributeEventData(widget.eventId, value: 'true')
        : context
            .read<ContributeEventCubit>()
            .fetchSingleContributeEventData(widget.eventId, value: 'false');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    // Dispose all text controllers
    for (var controller in objectionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    for (int i = 0; i < _sectionKeys.length; i++) {
      final keyContext = _sectionKeys[i].currentContext;
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
      _sectionKeys[index].currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleObjectionSubmitted(String title, String value) {
    if (value.isNotEmpty) {
      objectionControllers[title]?.text = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<ContributeEventCubit, ContributeEventState>(
        builder: (context, state) {
      if (state is ContributeEventLoaded) {
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
              title: Text("${StringConstant.view} ${StringConstant.events}"),
            ),
            body: Center(
              child: Text(state.errorMessage),
            ),
          );
        }
        final event = state.singleEvent;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0,
            leadingWidth: 35,
            leading: InkWell(
              child: Icon(Icons.arrow_back,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.whiteColor
                      : AppColor.blackColor),
              onTap: () {
                AppRouter.pop();
              },
            ),
            backgroundColor:
                isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
            title: Text(
              event?.title ?? '',
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
                        tabs: [
                          Tab(text: StringConstant.tabEssence),
                          Tab(text: StringConstant.additionalDetails),
                          Tab(text: StringConstant.tabAddress),
                          Tab(text: StringConstant.date),
                          Tab(text: StringConstant.tabBanner),
                          Tab(text: StringConstant.gallery),
                          Tab(
                              text:
                                  "${StringConstant.gods}/${StringConstant.goddesses}"),
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
                    _buildEssenceSection(event ?? ContributionEventModel()),
                    Gap(15.h),
                    BuildSection(
                        whichMode: widget.calledFrom != 'review'
                            ? IconButton(
                                onPressed: () {
                                  AppRouter.push(
                                      '/addEvent/${event?.id.toString()}/${'EditEvent'}/${5}');
                                },
                                icon: const Icon(Icons.edit))
                            : const SizedBox.shrink(),
                        keyWidget: _addressDKey,
                        temple: event ?? ContributionEventModel(),
                        value: 1,
                        sectionTitle: StringConstant.additionalDetails,
                        isDarkMode: isDarkMode,
                        calledFrom: widget.calledFrom,
                        commonTextSection: [
                          CommonTextSection(
                            title: StringConstant.howToCelebrate,
                            subtitle: event?.howToCelebrate ?? '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: StringConstant.dos,
                            subtitle: event?.dos ?? '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: StringConstant.donts,
                            subtitle: event?.donts ?? '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                        ]),

                    Gap(15.h),

                    BuildSection(
                        whichMode: widget.calledFrom != 'review'
                            ? IconButton(
                                onPressed: () {
                                  AppRouter.push(
                                      '/addEvent/${event?.id.toString()}/${'EditEvent'}/${2}');
                                },
                                icon: const Icon(Icons.edit))
                            : const SizedBox.shrink(),
                        keyWidget: _addressKey,
                        temple: event ?? ContributionEventModel(),
                        value: 2,
                        sectionTitle: StringConstant.address,
                        isDarkMode: isDarkMode,
                        calledFrom: widget.calledFrom,
                        commonTextSection: [
                          CommonTextSection(
                            title: StringConstant.address,
                            subtitle: event?.address ?? '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: StringConstant.city,
                            subtitle: event?.city ?? '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: StringConstant.state,
                            subtitle: event?.state ?? '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: StringConstant.country,
                            subtitle: event?.country ?? '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          // CommonTextSection(
                          //   title: StringConstant.landmark,
                          //   subtitle: event?.landmark ?? '',
                          //   isReviewMode: widget.calledFrom == 'review',
                          //   showTextFields: showTextFields,
                          //   objectionControllers: objectionControllers,
                          //   onObjectionSubmitted: _handleObjectionSubmitted,
                          // ),
                          // CommonTextSection(
                          //   title: StringConstant.nearestAirport,
                          //   subtitle: event?.nearestAirport ?? '',
                          //   isReviewMode: widget.calledFrom == 'review',
                          //   showTextFields: showTextFields,
                          //   objectionControllers: objectionControllers,
                          //   onObjectionSubmitted: _handleObjectionSubmitted,
                          // ),
                          // CommonTextSection(
                          //   title: StringConstant.nearestRailway,
                          //   subtitle: event?.nearestRailway ?? '',
                          //   isReviewMode: widget.calledFrom == 'review',
                          //   showTextFields: showTextFields,
                          //   objectionControllers: objectionControllers,
                          //   onObjectionSubmitted: _handleObjectionSubmitted,
                          // ),
                          // CommonTextSection(
                          //   title: 'Google Link',
                          //   subtitle: event?.googleMapLink ?? '',
                          //   isReviewMode: widget.calledFrom == 'review',
                          //   showTextFields: showTextFields,
                          //   objectionControllers: objectionControllers,
                          //   onObjectionSubmitted: _handleObjectionSubmitted,
                          // ),
                        ]),
                    Gap(15.h),

                    BuildSection(
                        whichMode: widget.calledFrom != 'review'
                            ? IconButton(
                                onPressed: () {
                                  AppRouter.push(
                                      '/addEvent/${event?.id.toString()}/${'EditEvent'}/${4}');
                                },
                                icon: const Icon(Icons.edit))
                            : const SizedBox.shrink(),
                        keyWidget: _dateKey,
                        temple: event ?? ContributionEventModel(),
                        value: 4,
                        sectionTitle: StringConstant.date,
                        isDarkMode: isDarkMode,
                        calledFrom: widget.calledFrom,
                        commonTextSection: [
                          CommonTextSection(
                            title: StringConstant.startDate,
                            subtitle: (event?.dates != null &&
                                    event!.dates!.isNotEmpty)
                                ? HelperClass.formatDate2(
                                    event.dates![0].startDate)
                                : '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: StringConstant.startTime,
                            subtitle: (event?.dates != null &&
                                    event!.dates!.isNotEmpty)
                                ? HelperClass.formatTime(
                                    event.dates![0].startTime)
                                : '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: StringConstant.endDate,
                            subtitle: (event?.dates != null &&
                                    event!.dates!.isNotEmpty)
                                ? HelperClass.formatDate2(
                                    event.dates![0].endDate)
                                : '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: StringConstant.endTime,
                            subtitle: (event?.dates != null &&
                                    event!.dates!.isNotEmpty)
                                ? HelperClass.formatTime(
                                    event.dates![0].endTime?.toString() ?? '')
                                : '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                        ]),

                    Gap(15.h),
                    // Banner section
                    BuildSection(
                      whichMode: const SizedBox.shrink(),
                      keyWidget: _bannerKey,
                      temple: event ?? ContributionEventModel(),
                      value: -1,
                      sectionTitle: StringConstant.tabBanner,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: event?.images?.banner ?? [],
                      gridViewItemBuilder: (context, index, item) {
                        final banner = item;
                        return Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: const Color(0xffe7e7e7)),
                          ),
                          child: Row(
                            children: [
                              CustomCacheImage(
                                borderRadius: BorderRadius.circular(2.r),
                                imageUrl: banner?.image ?? '',
                                height: 30,
                                width: 30,
                              ),
                              Gap(5.w),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  HelperClass()
                                      .getImageName(banner?.image ?? ''),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              widget.calledFrom == 'review'
                                  ? Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                await context
                                                    .read<
                                                        ContributeTempleCubit>()
                                                    .updateAcceptBanner(
                                                      'Event',
                                                      widget.eventId,
                                                      banner?.id.toString() ??
                                                          '',
                                                      'true',
                                                    );
                                              },
                                              child: Image.asset(
                                                height: 20.h,
                                                width: 20.h,
                                                'assets/icon/right.png',
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                await context
                                                    .read<
                                                        ContributeTempleCubit>()
                                                    .deleteImage(
                                                      'Event',
                                                      banner?.id.toString() ??
                                                          '',
                                                      widget.eventId,
                                                    );
                                              },
                                              child: Image.asset(
                                                height: 20.h,
                                                width: 20.h,
                                                'assets/icon/cancel.png',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        );
                      },
                      commonTextSection: const [],
                    ),

                    Gap(15.h),
                    BuildSection(
                      whichMode: const SizedBox.shrink(),
                      keyWidget: _galleryKey, // Using unique key
                      temple: event ?? ContributionEventModel(),
                      value: -1,
                      sectionTitle: StringConstant.gallery,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: event?.images?.gallery ?? [],
                      gridViewItemBuilder: (context, index, item) {
                        final dev = event!.devs![index];
                        return Container(
                            padding: EdgeInsets.all(5.sp),
                            decoration: BoxDecoration(
                                color: AppColor.whiteColor,
                                borderRadius: BorderRadius.circular(4.r),
                                border:
                                    Border.all(color: const Color(0xffe7e7e7))),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Text(
                                      HelperClass()
                                          .getImageName(dev.title ?? ''),
                                      overflow: TextOverflow.ellipsis,
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
                                            await context
                                                .read<ContributeTempleCubit>()
                                                .updateAcceptDevs(
                                                    widget.eventId,
                                                    dev.id.toString(),
                                                    'true');
                                          },
                                          child: Image.asset(
                                              height: 20.h,
                                              width: 20.h,
                                              'assets/icon/right.png'),
                                        )),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await context
                                                  .read<ContributeTempleCubit>()
                                                  .updateAcceptDevs(
                                                      widget.eventId,
                                                      dev.id.toString(),
                                                      '');
                                            },
                                            child: Image.asset(
                                                height: 20.h,
                                                width: 20.h,
                                                'assets/icon/cancel.png'),
                                          ),
                                        ),
                                      ],
                                    ))
                              ],
                            ));
                      },
                      commonTextSection: const [],
                    ),

                    Gap(15.h),
                    // _buildDevSection(
                    //     sectionKeys[5], event ?? ContributionEventModel()),

                    BuildSection(
                      whichMode: const SizedBox.shrink(),
                      keyWidget: _devKey,
                      temple: event ?? ContributionEventModel(),
                      value: -1,
                      sectionTitle: StringConstant.dev,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: event?.devs ?? [],
                      gridViewItemBuilder: (context, index, item) {
                        final dev = item;
                        return Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: const Color(0xffe7e7e7)),
                          ),
                          child: Row(
                            children: [
                              CustomCacheImage(
                                borderRadius: BorderRadius.circular(2.r),
                                imageUrl: (dev.images?.banner != null &&
                                        dev.images!.banner!.isNotEmpty)
                                    ? dev.images!.banner!.first.image ??
                                        StringConstant.defaultImage
                                    : StringConstant.defaultImage,
                                height: 30,
                                width: 30,
                              ),
                              Gap(5.w),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  HelperClass().getImageName(
                                    (dev.images?.banner != null &&
                                            dev.images!.banner!.isNotEmpty)
                                        ? dev.images!.banner!.first.image ??
                                            dev.title ??
                                            ''
                                        : dev.title ?? '',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              widget.calledFrom == 'review'
                                  ? Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                await context
                                                    .read<
                                                        ContributeTempleCubit>()
                                                    .updateAcceptDevs(
                                                      widget.eventId,
                                                      dev.id.toString(),
                                                      'true',
                                                    );
                                              },
                                              child: Image.asset(
                                                  height: 20.h,
                                                  width: 20.h,
                                                  'assets/icon/right.png'),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                await context
                                                    .read<
                                                        ContributeTempleCubit>()
                                                    .updateAcceptDevs(
                                                      widget.eventId,
                                                      dev.id.toString(),
                                                      '',
                                                    );
                                              },
                                              child: Image.asset(
                                                height: 20.h,
                                                width: 20.h,
                                                'assets/icon/cancel.png',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        );
                      },
                      commonTextSection: const [],
                    ),

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
                              // print('this is the submit button');
                              if (rejectReasons.isEmpty) {
                                print(StringConstant.noDataAvailable);
                                context
                                    .read<ContributeEventCubit>()
                                    .submitEventReview(
                                        'Event', widget.eventId, "true");
                              } else {
                                print('Contain Data');
                                print('reject_reasons: $rejectReasons');
                                context
                                    .read<ContributeEventCubit>()
                                    .submitEventReview(
                                        'Event', widget.eventId, "true",
                                        rejectReasons: rejectReasons);
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

  Widget _buildEssenceSection(ContributionEventModel event) {
    return BuildSection(
      whichMode: widget.calledFrom != 'review'
          ? IconButton(
              onPressed: () {
                AppRouter.push(
                    '/addEvent/${event.id.toString()}/${'EditEvent'}/${0}');
              },
              icon: const Icon(Icons.edit))
          : const SizedBox.shrink(),
      keyWidget: _essenceKey,
      temple: event,
      value: 0,
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      calledFrom: widget.calledFrom,
      sectionTitle: StringConstant.tabEssence,
      commonTextSection: [
        CommonTextSection(
          title: StringConstant.title,
          subtitle: event.title ?? '',
          isReviewMode: widget.calledFrom == 'review',
          showTextFields: showTextFields,
          objectionControllers: objectionControllers,
          onObjectionSubmitted: _handleObjectionSubmitted,
        ),
        CommonTextSection(
          title: StringConstant.subtitle,
          subtitle: event.subtitle ?? '',
          isReviewMode: widget.calledFrom == 'review',
          showTextFields: showTextFields,
          objectionControllers: objectionControllers,
          onObjectionSubmitted: _handleObjectionSubmitted,
        ),
        CommonTextSection(
          title: StringConstant.aboutTab,
          subtitle: event.description ?? '',
          isReviewMode: widget.calledFrom == 'review',
          showTextFields: showTextFields,
          objectionControllers: objectionControllers,
          onObjectionSubmitted: _handleObjectionSubmitted,
        ),
      ],
    );
  }
}

class BuildSection extends StatefulWidget {
  final GlobalKey keyWidget;
  final ContributionEventModel temple;
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
    this.sectionTitle = '',
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
      // decoration: BoxDecoration(
      //   color: widget.isDarkMode
      //       ? AppColor.lightTextColor
      //       : AppColor.lightScaffoldColor,
      //   borderRadius: BorderRadius.circular(10.r),
      //   boxShadow: widget.isDarkMode
      //       ? [
      //           BoxShadow(
      //             color: Colors.black.withOpacity(0.2),
      //             blurRadius: 5,
      //             offset: const Offset(0, 2),
      //           )
      //         ]
      //       : [
      //           BoxShadow(
      //             color: AppColor.lightTextColor.withOpacity(0.2),
      //             blurRadius: 5,
      //             offset: const Offset(0, 2),
      //           )
      //         ],
      // ),
      // margin: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.sectionTitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                                '/addEvent/${widget.temple.id.toString()}/${'EditEvent'}/${(widget.sectionTitle.toLowerCase()) == "banner" ? 1 : 3}');
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
