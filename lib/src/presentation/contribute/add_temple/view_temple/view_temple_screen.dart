import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/data/model/contribution/contribution_devalay_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/explore/widget/read_more_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gap/gap.dart';

class ViewTempleScreen extends StatefulWidget {
  const ViewTempleScreen(
      {super.key,
      required this.templeId,
      required this.governedId,
      this.calledFrom});
  final String templeId;
  final String governedId;
  final String? calledFrom;

  @override
  State<ViewTempleScreen> createState() => _ViewTempleScreenState();
}

class _ViewTempleScreenState extends State<ViewTempleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  Map<String, bool> showTextFields = {};
  Map<String, TextEditingController> objectionControllers = {};

  final GlobalKey _essenceKey = GlobalKey();
  final GlobalKey _addressKey = GlobalKey();
  final GlobalKey _legendKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();
  final GlobalKey _etymologyKey = GlobalKey();
  final GlobalKey _architectureKey = GlobalKey();
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
      _legendKey,
      _historyKey,
      _etymologyKey,
      _architectureKey,
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
            .read<ContributeTempleCubit>()
            .fetchSingleContributTempleData(widget.templeId )
        : context
            .read<ContributeTempleCubit>()
            .fetchSingleContributTempleData(widget.templeId);
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
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        if (state is ContributeTempleLoaded) {
          if (state.loadingState) {
            return Scaffold(
                backgroundColor:
                    isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
                body: Center(
                    child: CircularProgressIndicator(
                  color: isDarkMode
                      ? AppColor.orangeColor
                      : AppColor.gradientDarkColor,
                )));
          }
          if (state.errorMessage.isNotEmpty) {
            return Scaffold(

              backgroundColor:
                  isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
              appBar: AppBar(
                elevation: 0,
                leadingWidth: 35,
                leading: InkWell(onTap: (){
                  Navigator.pop(context);
                },
                  child: const Icon(Icons.arrow_back,color: AppColor.blackColor,),
                ),
                backgroundColor:
                    isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
                title: Text(
                  '${StringConstant.view.toUpperCase()} ${StringConstant.temples.toUpperCase()}',
                  style: const TextStyle(color: AppColor.blackColor),
                ),
              ),
              body: Center(
                child: Text(
                  state.errorMessage,
                  style: TextStyle(
                      color: isDarkMode
                          ? AppColor.whiteColor
                          : AppColor.lightTextColor),
                ),
              ),
            );
          }
          final temple = state.singleTemple;
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor:
                  isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
              appBar: AppBar(
                  elevation: 0,
                  leading: InkWell(
                    child: Icon(Icons.arrow_back,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColor.whiteColor
                            : AppColor.blackColor),
                    onTap: () {
                      AppRouter.pop();
                    },
                  ),
                  leadingWidth: 35,
                  backgroundColor:
                      isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
                  title: Text(temple?.title ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: AppColor.blackColor))),
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
                              Tab(text: StringConstant.tabAddress),
                              Tab(text: StringConstant.tabLegend),
                              Tab(text: StringConstant.tabHistory),
                              Tab(text: StringConstant.tabEtymology),
                              Tab(text: StringConstant.tabArchitecture),
                              Tab(text: StringConstant.tabBanner),
                              Tab(text: StringConstant.gallery),
                              Tab(text: StringConstant.dev)
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
                        // Essence section
                        BuildSection(
                          whichMode: widget.calledFrom != 'review'
                              ? IconButton(
                                  onPressed: () {
                                    AppRouter.push(
                                        '/addTemple/${temple!.id.toString()}/${temple.governedBy?.id.toString()}/${'EditTemple'}/${0}');
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: isDarkMode
                                        ? AppColor.orangeColor
                                        : null,
                                  ))
                              : const SizedBox.shrink(),
                          keyWidget: _essenceKey, // Using unique key
                          temple: temple ?? ContributionDevalayModel(),
                          value: 0,
                          sectionTitle: StringConstant.tabEssence,
                          commonTextSection: [
                            commonTextSection(
                                StringConstant.title, temple?.title ?? ''),
                            commonTextSection(StringConstant.subtitle,
                                temple?.subtitle ?? ''),
                            commonTextSection(StringConstant.aboutTab,
                                temple?.description ?? ''),
                            commonTextSection(
                              StringConstant.website,
                              temple?.website ?? '',
                            ),
                            commonTextSection(
                              StringConstant.website,
                              temple?.website ?? '',
                            ),
                          ],
                          isDarkMode: isDarkMode,
                          calledFrom: widget.calledFrom,
                        ),
                        Gap(15.h),

                        // Address section
                        BuildSection(
                          whichMode: widget.calledFrom != 'review'
                              ? IconButton(
                                  onPressed: () {
                                    AppRouter.push(
                                        '/addTemple/${temple?.id.toString()}/${temple?.governedBy?.id.toString()}/${'EditTemple'}/${2}');
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: isDarkMode
                                        ? AppColor.orangeColor
                                        : null,
                                  ))
                              : const SizedBox.shrink(),
                          keyWidget: _addressKey, // Using unique key
                          temple: temple ?? ContributionDevalayModel(),
                          value: 2,
                          sectionTitle: StringConstant.tabAddress,
                          commonTextSection: [
                            commonTextSection(
                                StringConstant.address, temple?.address ?? ''),
                            commonTextSection(
                                StringConstant.city, temple?.city ?? ''),
                            commonTextSection(
                                StringConstant.state, temple?.state ?? ''),
                            commonTextSection(
                                StringConstant.country, temple?.country ?? ''),
                            commonTextSection(StringConstant.pincode,
                                temple?.pincode ?? ''),
                            // commonTextSection(StringConstant.nearestRailway,
                            //     temple?.nearestRailway ?? ''),
                            // commonTextSection(StringConstant.landmark,
                            //     temple?.landmark ?? ''),
                            // commonTextSection(StringConstant.googleMapLink,
                            //     temple?.googleMapLink ?? ''),
                          ],
                          isDarkMode: isDarkMode,
                          calledFrom: widget.calledFrom,
                        ),
                        Gap(15.h),

                        // Legend section
                        BuildSection(
                          whichMode: widget.calledFrom != 'review'
                              ? IconButton(
                                  onPressed: () {
                                    AppRouter.push(
                                        '/addTemple/${temple?.id.toString()}/${temple?.governedBy?.id.toString()}/${'EditTemple'}/${5}');
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: isDarkMode
                                        ? AppColor.orangeColor
                                        : null,
                                  ))
                              : const SizedBox.shrink(),
                          keyWidget: _legendKey, // Using unique key
                          temple: temple ?? ContributionDevalayModel(),
                          value: 5,
                          sectionTitle: StringConstant.tabLegend,
                          isDarkMode: isDarkMode,
                          calledFrom: widget.calledFrom,
                          hasReadMore: true,
                          readMoreText: temple?.legend ?? "",
                          commonTextSection: const [],
                        ),
                        Gap(15.h),

                        // History section
                        BuildSection(
                          whichMode: widget.calledFrom != 'review'
                              ? IconButton(
                                  onPressed: () {
                                    AppRouter.push(
                                        '/addTemple/${temple!.id.toString()}/${temple.governedBy?.id.toString()}/${'EditTemple'}/${4}');
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: isDarkMode
                                        ? AppColor.orangeColor
                                        : null,
                                  ))
                              : const SizedBox.shrink(),
                          keyWidget: _historyKey, // Using unique key
                          temple: temple ?? ContributionDevalayModel(),
                          value: 4,
                          sectionTitle: StringConstant.tabHistory,
                          isDarkMode: isDarkMode,
                          calledFrom: widget.calledFrom,
                          hasReadMore: true,
                          readMoreText: temple?.templeHistory ?? "",
                          commonTextSection: const [],
                        ),
                        Gap(15.h),

                        // Etymology section
                        BuildSection(
                          whichMode: widget.calledFrom != 'review'
                              ? IconButton(
                                  onPressed: () {
                                    AppRouter.push(
                                        '/addTemple/${temple!.id.toString()}/${temple.governedBy?.id.toString()}/${'EditTemple'}/${6}');
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: isDarkMode
                                        ? AppColor.orangeColor
                                        : null,
                                  ))
                              : const SizedBox.shrink(),
                          keyWidget: _etymologyKey, // Using unique key
                          temple: temple ?? ContributionDevalayModel(),
                          value: 6,
                          sectionTitle: StringConstant.tabEtymology,
                          isDarkMode: isDarkMode,
                          calledFrom: widget.calledFrom,
                          hasReadMore: true,
                          readMoreText: temple?.etymology ?? "",
                          commonTextSection: const [],
                        ),
                        Gap(15.h),

                        // Architecture section
                        BuildSection(
                          whichMode: widget.calledFrom != 'review'
                              ? IconButton(
                                  onPressed: () {
                                    AppRouter.push(
                                        '/addTemple/${temple!.id.toString()}/${temple.governedBy?.id.toString()}/${'EditTemple'}/${7}');
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: isDarkMode
                                        ? AppColor.orangeColor
                                        : null,
                                  ))
                              : const SizedBox.shrink(),
                          keyWidget: _architectureKey, // Using unique key
                          temple: temple ?? ContributionDevalayModel(),
                          value: 7,
                          sectionTitle: StringConstant.tabArchitecture,
                          isDarkMode: isDarkMode,
                          calledFrom: widget.calledFrom,
                          hasReadMore: true,
                          readMoreText: temple?.architecture ?? "",
                          commonTextSection: const [],
                        ),
                        Gap(15.h),

                        // Banner section
                        BuildSection(
                          whichMode: const SizedBox
                              .shrink(), // No edit button for banner section
                          keyWidget: _bannerKey, // Using unique key
                          temple: temple ?? ContributionDevalayModel(),
                          value:
                              -1, // Not using value for navigation in banner section
                          sectionTitle: StringConstant.tabBanner,
                          isDarkMode: isDarkMode,
                          calledFrom: widget.calledFrom,
                          hasGridView: true,
                          gridViewItems: temple?.images?.banner ?? [],
                          gridViewItemBuilder: (context, index, item) {
                            final banner = item;
                            return Container(
                              padding: EdgeInsets.all(5.sp),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                border:
                                    Border.all(color: const Color(0xffe7e7e7)),
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
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                                                          'Devalay',
                                                          widget.templeId,
                                                          banner?.id
                                                                  .toString() ??
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
                                                          'Devalay',
                                                          banner?.id
                                                                  .toString() ??
                                                              '',
                                                          widget.templeId,
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

                        // Gallery section
                        BuildSection(
                          whichMode: const SizedBox
                              .shrink(), // No edit button for gallery section
                          keyWidget: _galleryKey, // Using unique key
                          temple: temple ?? ContributionDevalayModel(),
                          value:
                              -1, // Not using value for navigation in gallery section
                          sectionTitle: StringConstant.gallery,
                          isDarkMode: isDarkMode,
                          calledFrom: widget.calledFrom,
                          hasGridView: true,
                          gridViewItems: temple?.images?.gallery ?? [],
                          gridViewItemBuilder: (context, index, item) {
                            final gallery = item;
                            return Container(
                              padding: EdgeInsets.all(5.sp),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                border:
                                    Border.all(color: const Color(0xffe7e7e7)),
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
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                                                          'Devalay',
                                                          widget.templeId,
                                                          gallery?.id
                                                                  .toString() ??
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
                                                          'Devalay',
                                                          gallery?.id
                                                                  .toString() ??
                                                              '',
                                                          widget.templeId,
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

                        // Dev section
                        BuildSection(
                          whichMode: const SizedBox.shrink(),
                          keyWidget: _devKey,
                          temple: temple ?? ContributionDevalayModel(),
                          value: -1,
                          sectionTitle: StringConstant.dev,
                          isDarkMode: isDarkMode,
                          calledFrom: widget.calledFrom,
                          hasGridView: true,
                          gridViewItems: temple?.devs ?? [],
                          gridViewItemBuilder: (context, index, item) {
                            final dev = item;
                            return Container(
                              padding: EdgeInsets.all(5.sp),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                border:
                                    Border.all(color: const Color(0xffe7e7e7)),
                              ),
                              child: Row(
                                children: [
                                  CustomCacheImage(
                                    borderRadius: BorderRadius.circular(2.r),
                                    imageUrl: dev.image ??
                                        StringConstant.defaultImage,
                                    height: 30,
                                    width: 30,
                                  ),
                                  Gap(5.w),
                                  Expanded(
                                    flex: 7,
                                    child: Text(
                                      HelperClass().getImageName(
                                          dev.image ?? dev.dev!.title!),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                                                          widget.templeId,
                                                          dev.id.toString(),
                                                          'true',
                                                        );
                                                  },
                                                  child: Image.asset(
                                                      'assets/icon/right.png'),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    // await context
                                                    //     .read<ContributeTempleCubit>()
                                                    //     .deleteImage(dev.id.toString() ?? '',widget.templeId);
                                                  },
                                                  child: Image.asset(
                                                      'assets/icon/cancel.png'),
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

                        // Submit button for review
                        widget.calledFrom == 'review'
                            ? GestureDetector(
                                onTap: () async {
                                  final Map<String, String> rejectReasons = {};

                                  objectionControllers
                                      .forEach((key, controller) {
                                    final value = controller.text.trim();
                                    if (value.isNotEmpty) {
                                      rejectReasons[key] = value;
                                    }
                                  });

                                  if (rejectReasons.isEmpty) {
                                    context
                                        .read<ContributeTempleCubit>()
                                        .submitDevalayReview(
                                            'Devalay', widget.templeId, "true");
                                  } else {
                                    print('Contain Data');
                                    print('reject_reasons: $rejectReasons');
                                    context
                                        .read<ContributeTempleCubit>()
                                        .submitDevalayReview(
                                            'Devalay', widget.templeId, "false",
                                            rejectReasons: rejectReasons);
                                  }
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.sp, vertical: 5.sp),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.r),
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
              ));
        }

        return Scaffold(
          backgroundColor:
              isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
          body: Center(
            child: CircularProgressIndicator(
              color: isDarkMode
                  ? AppColor.orangeColor
                  : AppColor.gradientDarkColor,
            ),
          ),
        );
      },
    );
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
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              // Gap(10.w),
              // widget.calledFrom == 'review'
              //     ? GestureDetector(
              //         onTap: () {
              //           setState(() {
              //             showTextFields[title] =
              //                 !(showTextFields[title] ?? false);
              //           });
              //         },
              //         child: Row(
              //           children: [
              //             Icon(Icons.add, size: 15.sp),
              //             Text(StringConstant.objection,
              //                 style: Theme.of(context)
              //                     .textTheme
              //                     .titleSmall
              //                     ?.copyWith(color: Colors.grey))
              //           ],
              //         ),
              //       )
              //     : const SizedBox(),
            ],
          ),
          Gap(10.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
          ),
          widget.calledFrom == 'review' ? Column(
            children: [
              Gap(10.h),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showTextFields[title] =
                    !(showTextFields[title] ?? false);
                  });
                },
                child: Text(StringConstant.objection,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColor.orangeColor)),
              )
            ],
          ) : const SizedBox(),
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
  final ContributionDevalayModel temple;
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
                                '/addTemple/${widget.temple.id.toString()}/${widget.temple.governedBy?.id.toString()}/${'EditTemple'}/${(widget.sectionTitle.toLowerCase()) == "banner" ? 1 : 3}');
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
