import 'package:devalay_app/src/application/contribution/contribution_festival/contribution_festival_state.dart';
import 'package:devalay_app/src/data/model/contribution/contribution_festival_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/explore/widget/read_more_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:devalay_app/src/presentation/core/widget/common_text_section.dart';

import '../../../../application/contribution/contribution_festival/contribution_festival_cubit.dart';
import '../../../../core/router/router.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';

class ViewFestivalScreen extends StatefulWidget {
  const ViewFestivalScreen(
      {super.key, required this.festivalId, this.calledFrom});
  final String festivalId;
  final String? calledFrom;
  @override
  State<ViewFestivalScreen> createState() => _ViewFestivalScreenState();
}

class _ViewFestivalScreenState extends State<ViewFestivalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  Map<String, bool> showTextFields = {};
  Map<String, TextEditingController> objectionControllers = {};
  final GlobalKey _essenceKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _whywecelebrateKey = GlobalKey();
  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _bannerKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final GlobalKey _devKey = GlobalKey();

  late List<GlobalKey> _sectionKeys;
  @override
  void initState() {
    super.initState();

    _sectionKeys = [
      _essenceKey,
      _aboutKey,
      _dateKey,
      _whywecelebrateKey,
      _bannerKey,
      _galleryKey,
      _devKey
    ];

    _tabController = TabController(
        length: _sectionKeys.length, vsync: this, initialIndex: 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    (widget.calledFrom == 'review')
        ? context
            .read<ContributeFestivalCubit>()
            .fetchSingleContributeFestivalData(widget.festivalId, value: 'true')
        : context
            .read<ContributeFestivalCubit>()
            .fetchSingleContributeFestivalData(widget.festivalId,
                value: 'false');
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<ContributeFestivalCubit, ContributeFestivalState>(
        builder: (context, state) {
      if (state is ContributeFestivalError && state.isPermissionDenied) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: const Color(0xffFF4C02),
                    size: 24.sp,
                  ),
                  Gap(8.w),
                  Text(
                    'Permission Denied',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              content: Text(
                '${StringConstant.youdonot}  ${StringConstant.festival}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: AppColor.appbarBgColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      }

      if (state is ContributeFestivalLoaded) {
        if (state.loadingState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state.errorMessage.isNotEmpty) {
          return Scaffold(
            backgroundColor:
                isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.whiteColor
                        : AppColor.blackColor),
                onPressed: () {
                  AppRouter.pop();
                },
              ),
              title: Text("${StringConstant.view} ${StringConstant.festival} "),
            ),
            body: Center(
              child: Text(state.errorMessage),
            ),
          );
        }
        final festival = state.singleFestival;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor:
              isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.whiteColor
                      : AppColor.blackColor),
              onPressed: () {
                AppRouter.pop();
              },
            ),
            elevation: 0,
            backgroundColor: AppColor.appbarBgColor,
            title: Text(
              festival?.title ?? '',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: AppColor.whiteColor),
            ),
          ),
          body: Column(
            children: [
              Container(
                color:
                    isDarkMode ? AppColor.blackColor : const Color(0xfffffbfb),
                child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    onTap: (index) {
                      _scrollToSection(index);
                    },
                    indicatorColor: AppColor.orangeColor,
                    tabs: [
                      Tab(text: StringConstant.tabEssence),
                      Tab(
                        text:
                            '${StringConstant.about} & ${StringConstant.original}',
                      ),
                      Tab(
                        text: StringConstant.weCelebrate,
                      ),
                      Text(StringConstant.tabBanner),
                      Text(StringConstant.gallery),
                      Text(StringConstant.date),

                      Text(StringConstant.dev),
                    ]),
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
                                    '/addFestival/${festival!.id.toString()}/${'EditFestival'}/${0}');
                              },
                              icon: Icon(
                                Icons.edit, 
                                color: isDarkMode ? AppColor.orangeColor : null,
                              ))
                          : const SizedBox.shrink(),
                      keyWidget: _essenceKey, // Using unique key
                      temple: festival ?? ContributionFestivalModel(),
                      value: 0,
                      sectionTitle: StringConstant.tabEssence,
                      commonTextSection: [
                        CommonTextSection(
                          title: 'Title',
                          subtitle: festival?.title ?? '',
                          isReviewMode: widget.calledFrom == 'review',
                          showTextFields: showTextFields,
                          objectionControllers: objectionControllers,
                          onObjectionSubmitted: _handleObjectionSubmitted,
                        ),
                        CommonTextSection(
                          title: 'Tagline',
                          subtitle: festival?.subtitle ?? '',
                          isReviewMode: widget.calledFrom == 'review',
                          showTextFields: showTextFields,
                          objectionControllers: objectionControllers,
                          onObjectionSubmitted: _handleObjectionSubmitted,
                        ),
                      ],
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                    ),
                    Gap(20.h),
                    BuildSection(
                      whichMode: widget.calledFrom != 'review'
                          ? IconButton(
                              onPressed: () {
                                AppRouter.push(
                                    '/addFestival/${festival?.id.toString()}/${'EditFestival'}/${4}');
                              },
                              icon: Icon(
                                Icons.edit,
                                color: isDarkMode ? AppColor.orangeColor : null,
                              ))
                          : const SizedBox.shrink(),
                      keyWidget: _aboutKey, // Using unique key
                      temple: festival?? ContributionFestivalModel(),
                      value: 1,
                      sectionTitle:
                          '${StringConstant.about} & ${StringConstant.original}',
                      commonTextSection: [
                        CommonTextSection(
                          title: 'About',
                          subtitle: festival?.description ?? '',
                          isReviewMode: widget.calledFrom == 'review',
                          showTextFields: showTextFields,
                          objectionControllers: objectionControllers,
                          onObjectionSubmitted: _handleObjectionSubmitted,
                        ),
                        CommonTextSection(
                          title: 'History',
                          subtitle: festival?.history ?? '',
                          isReviewMode: widget.calledFrom == 'review',
                          showTextFields: showTextFields,
                          objectionControllers: objectionControllers,
                          onObjectionSubmitted: _handleObjectionSubmitted,
                        ),
                      ],
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                    ),
                    Gap(20.h),
                    BuildSection(
                      whichMode: widget.calledFrom != 'review'
                          ? IconButton(
                              onPressed: () {
                                AppRouter.push(
                                    '/addFestival/${festival?.id.toString()}/${'EditFestival'}/${5}');
                              },
                              icon: Icon(
                                Icons.edit,
                                color: isDarkMode ? AppColor.orangeColor : null,
                              ))
                          : const SizedBox.shrink(),
                      keyWidget: _whywecelebrateKey, // Using unique key
                      temple: festival ?? ContributionFestivalModel(),
                      value: 2,
                      sectionTitle:
                          '${StringConstant.weCelebrate} & ${StringConstant.original}',
                      commonTextSection: [
                        CommonTextSection(
                          title: 'Why we celebrate',
                          subtitle: festival?.whyWeCelebrate ?? '',
                          isReviewMode: widget.calledFrom == 'review',
                          showTextFields: showTextFields,
                          objectionControllers: objectionControllers,
                          onObjectionSubmitted: _handleObjectionSubmitted,
                        ),
                        CommonTextSection(
                          title: "Do's",
                          subtitle: festival?.dos ?? '',
                          isReviewMode: widget.calledFrom == 'review',
                          showTextFields: showTextFields,
                          objectionControllers: objectionControllers,
                          onObjectionSubmitted: _handleObjectionSubmitted,
                        ),
                        CommonTextSection(
                          title: "Don'ts",
                          subtitle: festival?.donts ?? '',
                          isReviewMode: widget.calledFrom == 'review',
                          showTextFields: showTextFields,
                          objectionControllers: objectionControllers,
                          onObjectionSubmitted: _handleObjectionSubmitted,
                        ),
                      ],
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                    ),
                    Gap(20.h),
                    BuildSection(
                      whichMode: const SizedBox
                          .shrink(), // No edit button for banner section
                      keyWidget: _bannerKey, // Using unique key
                      temple: festival?? ContributionFestivalModel(),
                      value:
                          -1, // Not using value for navigation in banner section
                      sectionTitle: StringConstant.tabBanner,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: festival?.images?.banner ?? [],
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
                                                        ContributeFestivalCubit>()
                                                    .updateAcceptBanner(
                                                      'Devalay',
                                                      widget.festivalId,
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
                                                // await context
                                                //     .read<
                                                //         ContributeFestivalCubit>()
                                                //     .deleteImage(
                                                //       'Devalay',
                                                //       banner?.id
                                                //               .toString() ??
                                                //           '',
                                                //       widget.festivalId,
                                                //     );
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
                      whichMode: const SizedBox
                          .shrink(), // No edit button for gallery section
                      keyWidget: _galleryKey, // Using unique key
                      temple: festival?? ContributionFestivalModel(),
                      value:
                          -1, // Not using value for navigation in gallery section
                      sectionTitle: StringConstant.gallery,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: festival?.images?.gallery ?? [],
                      gridViewItemBuilder: (context, index, item) {
                        final gallery = item;
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
                                imageUrl: gallery?.image ?? '',
                                height: 30,
                                width: 30,
                              ),
                              Gap(5.w),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  HelperClass()
                                      .getImageName(gallery?.image ?? ''),
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
                                                        ContributeFestivalCubit>()
                                                    .updateAcceptBanner(
                                                      'Devalay',
                                                      widget.festivalId,
                                                      gallery?.id.toString() ??
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
                                                // await context
                                                //     .read<
                                                //         ContributeFestivalCubit>()
                                                //     .deleteImage(
                                                //       'Devalay',
                                                //       gallery?.id
                                                //               .toString() ??
                                                //           '',
                                                //       widget.festivalId,
                                                //     );
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
                        whichMode: widget.calledFrom != 'review'
                            ? IconButton(
                                onPressed: () {
                                  AppRouter.push(
                                      '/addFestival/${festival?.id.toString()}/${'EditFestival'}/${3}');
                                },
                                icon: const Icon(Icons.edit))
                            : const SizedBox.shrink(),
                        keyWidget: _dateKey,
                        temple: festival  ?? ContributionFestivalModel(),
                        value: 4,
                         key: widget.key,
                        sectionTitle: StringConstant.date,
                        isDarkMode: isDarkMode,
                        calledFrom: widget.calledFrom,
                        commonTextSection: [
                          CommonTextSection(
                            title: 'Start Date',
                            subtitle: (festival?.dates != null &&
                                    festival!.dates!.isNotEmpty)
                                ? HelperClass().formatDate(
                                    festival.dates![0].startDate)
                                : '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: 'Start Time',
                            subtitle: (festival?.dates != null &&
                                    festival!.dates!.isNotEmpty)
                                ? HelperClass.formatTime(
                                    festival.dates![0].startTime)
                                : '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: 'End Date',
                            subtitle: (festival?.dates != null &&
                                    festival!.dates!.isNotEmpty)
                                ? HelperClass().formatDate(
                                    festival.dates![0].endDate)
                                : '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                          CommonTextSection(
                            title: 'End Time',
                            subtitle: (festival?.dates != null &&
                                    festival!.dates!.isNotEmpty)
                                ? HelperClass.formatTime(
                                    festival.dates![0].endTime.toString())
                                : '',
                            isReviewMode: widget.calledFrom == 'review',
                            showTextFields: showTextFields,
                            objectionControllers: objectionControllers,
                            onObjectionSubmitted: _handleObjectionSubmitted,
                          ),
                        ]),
                    Gap(15.h),
                    BuildSection(
                      keyWidget: _devKey,
                      whichMode: const SizedBox.shrink(),
                      key: widget.key,
                      temple: festival?? ContributionFestivalModel(),
                      value: -1,
                      sectionTitle: StringConstant.dev,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: festival?.devs ?? [],
                      gridViewItemBuilder: (context, index, item) {
                        final dev = item;
                        return Container(
                            padding: EdgeInsets.all(5.sp),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                border:
                                    Border.all(color: const Color(0xffe7e7e7))),
                            child: Row(
                              children: [
                                // CustomCacheImage(
                                //     borderRadius: BorderRadius.circular(2.r),
                                //     imageUrl: dev. ?? '',
                                //     height: 30,
                                //     width: 30),
                                // Gap(5.w),
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
                                  widget.calledFrom == 'review'?
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Expanded(
                                            child: InkWell(
                                          onTap: () async {
                                            await context
                                                .read<ContributeFestivalCubit>()
                                                .updateAcceptBanner('Festival',
                                                widget.festivalId,
                                                dev.id.toString() , 'true');
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
                                                .read<ContributeFestivalCubit>()
                                                .updateAcceptBanner('Festival',
                                                widget.festivalId,
                                                dev.id.toString() , '');
                                              },
                                              child: Image.asset(
                                                  height: 20.h,
                                                  width: 20.h,
                                                  'assets/icon/cancel.png'),
                                            )),
                                      ],
                                    ))
                             : const SizedBox.shrink()  ],
                            ));
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

                              if (rejectReasons.isEmpty) {
                                print('No data');
                                context
                                    .read<ContributeFestivalCubit>()
                                    .submitFestivalReview(
                                        'Festival', widget.festivalId, "true");
                              } else {
                                print('Contain Data');
                                print('reject_reasons: $rejectReasons');
                                context
                                    .read<ContributeFestivalCubit>()
                                    .submitFestivalReview(
                                        'Festival', widget.festivalId, "false",
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

  Widget _buildAboutSection(
      GlobalKey key, ContributionFestivalModel festival, int value) {
    return Container(
      key: key,
      color: const Color(0xfffffbfb),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('About & Origin',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 20.sp)),
                widget.calledFrom != 'review'
                    ? IconButton(
                        onPressed: () {
                          AppRouter.push(
                              '/addFestival/${festival.id.toString()}/${'EditFestival'}/$value');
                        },
                        icon: const Icon(Icons.edit))
                    : const SizedBox.shrink()
              ],
            ),
            Gap(10.h),
            CommonTextSection(
              title: 'About',
              subtitle: festival.description ?? '',
              isReviewMode: widget.calledFrom == 'review',
              showTextFields: showTextFields,
              objectionControllers: objectionControllers,
              onObjectionSubmitted: _handleObjectionSubmitted,
            ),
            CommonTextSection(
              title: 'History',
              subtitle: festival.history ?? '',
              isReviewMode: widget.calledFrom == 'review',
              showTextFields: showTextFields,
              objectionControllers: objectionControllers,
              onObjectionSubmitted: _handleObjectionSubmitted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrateSection(
      GlobalKey key, ContributionFestivalModel festival, int value) {
    return Container(
      key: key,
      color: const Color(0xfffffbfb),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Why we celebrate',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 20.sp)),
                widget.calledFrom != 'review'
                    ? IconButton(
                        onPressed: () {
                          AppRouter.push(
                              '/addFestival/${festival.id.toString()}/${'EditFestival'}/$value');
                        },
                        icon: const Icon(Icons.edit))
                    : const SizedBox.shrink()
              ],
            ),
            Gap(10.h),
            CommonTextSection(
              title: 'Why we celebrate',
              subtitle: festival.whyWeCelebrate ?? '',
              isReviewMode: widget.calledFrom == 'review',
              showTextFields: showTextFields,
              objectionControllers: objectionControllers,
              onObjectionSubmitted: _handleObjectionSubmitted,
            ),
            CommonTextSection(
              title: "Do's",
              subtitle: festival.dos ?? '',
              isReviewMode: widget.calledFrom == 'review',
              showTextFields: showTextFields,
              objectionControllers: objectionControllers,
              onObjectionSubmitted: _handleObjectionSubmitted,
            ),
            CommonTextSection(
              title: "Don'ts",
              subtitle: festival.donts ?? '',
              isReviewMode: widget.calledFrom == 'review',
              showTextFields: showTextFields,
              objectionControllers: objectionControllers,
              onObjectionSubmitted: _handleObjectionSubmitted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGodsSection(
      GlobalKey key, ContributionFestivalModel festival, int value) {
    return Container(
      key: key,
      color: const Color(0xfffffbfb),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Why we celebrate',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 20.sp)),
                widget.calledFrom != 'review'
                    ? IconButton(
                        onPressed: () {
                          AppRouter.push(
                              '/addFestival/${festival.id.toString()}/${'EditFestival'}/$value');
                        },
                        icon: const Icon(Icons.edit))
                    : const SizedBox.shrink()
              ],
            ),
            Gap(10.h),
            CommonTextSection(
              title: 'Title',
              subtitle: festival.title ?? '',
              isReviewMode: widget.calledFrom == 'review',
              showTextFields: showTextFields,
              objectionControllers: objectionControllers,
              onObjectionSubmitted: _handleObjectionSubmitted,
            ),
            CommonTextSection(
              title: 'Tagline',
              subtitle: festival.subtitle ?? '',
              isReviewMode: widget.calledFrom == 'review',
              showTextFields: showTextFields,
              objectionControllers: objectionControllers,
              onObjectionSubmitted: _handleObjectionSubmitted,
            ),
            CommonTextSection(
              title: 'About',
              subtitle: festival.description ?? '',
              isReviewMode: widget.calledFrom == 'review',
              showTextFields: showTextFields,
              objectionControllers: objectionControllers,
              onObjectionSubmitted: _handleObjectionSubmitted,
            ),
          ],
        ),
      ),
    );
  }

  void _handleObjectionSubmitted(String title, String value) {
    // Implementation of _handleObjectionSubmitted method
  }
}

class BuildSection extends StatefulWidget {
  final GlobalKey keyWidget;
  final ContributionFestivalModel temple;
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
        decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColor.lightTextColor : AppColor.lightScaffoldColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: widget.isDarkMode
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ]
            : [
                BoxShadow(
                  color: AppColor.lightTextColor.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 10.sp),
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
                        color: widget.isDarkMode ? AppColor.whiteColor : null)),
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
                                '/addFestival/${widget.temple.id.toString()}/${'EditFestival'}/${(widget.sectionTitle.toLowerCase()) == "banner" ? 1 : 2}');
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
