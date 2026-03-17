import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/explore/widget/read_more_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gap/gap.dart';
import 'package:html/parser.dart' as html_parser;

import '../../../../application/contribution/contribution_puja/contribution_puja_cubit.dart';
import '../../../../application/contribution/contribution_puja/contribution_puja_state.dart';
import '../../../../core/router/router.dart';
import '../../../../data/model/contribution/contribution_puja_model.dart';
import '../../../core/helper/helper_class.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widget/custom_cache_image.dart';

class ViewPujaScreen extends StatefulWidget {
  const ViewPujaScreen({super.key, required this.pujaId, this.calledFrom});
  final String pujaId;
  final String? calledFrom;

  @override
  State<ViewPujaScreen> createState() => _ViewPujaScreenState();
}

class _ViewPujaScreenState extends State<ViewPujaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  Map<String, bool> showTextFields = {};
  Map<String, TextEditingController> objectionControllers = {};

  final GlobalKey _essenceKey = GlobalKey();
  final GlobalKey _purposeKey = GlobalKey();

  final GlobalKey _bannerKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final GlobalKey _devKey = GlobalKey();

  late List<GlobalKey> _sectionKeys;
  @override
  void initState() {
    super.initState();

    _sectionKeys = [
      _essenceKey,
      _purposeKey,
      _bannerKey,
      _galleryKey,
      _devKey,
    ];
    _tabController = TabController(
        length: _sectionKeys.length, vsync: this, initialIndex: 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    String isReview = widget.calledFrom == 'review' ? "true" : "false";
    context
        .read<ContributePujaCubit>()
        .fetchSingleContributePujaData(widget.pujaId, value: isReview);
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

  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text.trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<ContributePujaCubit, ContributePujaState>(
        builder: (context, state) {
              if (state is ContributePujaError && state.isPermissionDenied) {
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
              '${StringConstant.youdonot}  ${StringConstant.pujas}.',
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
 
      if (state is ContributePujaLoaded) {
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
              title: Text("${StringConstant.view} ${StringConstant.pujas}"),
            ),
            body: Center(
              child: Text(state.errorMessage),
            ),
          );
        }
        final puja = state.singlePuja;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor:
              isDarkMode ? AppColor.blackColor : AppColor.whiteColor,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.whiteColor
                      : AppColor.blackColor),
              onPressed: () {
                AppRouter.pop();
              },
            ),
            backgroundColor: AppColor.appbarBgColor,
            title: Text(
              puja?.title ?? '',
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
                    padding: EdgeInsets.only(top: 30.h),
                    controller: _tabController,
                    onTap: (index) {
                      _scrollToSection(index);
                    },
                    unselectedLabelColor: isDarkMode ? Colors.grey : null,
                    indicatorColor: AppColor.orangeColor,
                    tabs: [
                      Text(StringConstant.tabEssence),
                      Text(StringConstant.purpose + StringConstant.procedure),
                      Text(StringConstant.tabBanner),
                      Text(StringConstant.gallery),
                      Text(StringConstant.dev),
                    ]),
              ),
              Expanded(
                  child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Gap(20.h),
                    // _buildEssenceSection(
                    //     _sectionKeys[0], puja ?? ContributionPujaModel(), 0),
                    // Essence section
                    BuildSection(
                      whichMode: widget.calledFrom != 'review'
                          ? IconButton(
                              onPressed: () {
                                AppRouter.push(
                                    '/addPuja/${puja!.id.toString()}/${'EditPuja'}/${0}');
                              },
                              icon: const Icon(Icons.edit))
                          : const SizedBox.shrink(),
                      keyWidget: _essenceKey, // Using unique key
                      temple: puja ?? ContributionPujaModel(),
                      value: 0,
                      sectionTitle: StringConstant.tabEssence,
                      commonTextSection: [
                        commonTextSection(
                            StringConstant.title, puja?.title ?? ''),
                        commonTextSection(
                            StringConstant.tagline, puja?.subtitle ?? ''),
                        commonTextSection(
                            StringConstant.about, puja?.description ?? ''),
                      ],
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                    ),

                    Gap(15.h),
                    BuildSection(
                      whichMode: widget.calledFrom != 'review'
                          ? IconButton(
                              onPressed: () {
                                AppRouter.push(
                                    '/addPuja/${puja?.id.toString()}/${'EditPuja'}/${3}');
                              },
                              icon: const Icon(Icons.edit))
                          : const SizedBox.shrink(),
                      keyWidget: _purposeKey, // Using unique key
                      temple: puja ?? ContributionPujaModel(),
                      value: 1,
                      sectionTitle:
                          StringConstant.purpose + StringConstant.procedure,
                      commonTextSection: [
                        commonTextSection(StringConstant.purpose,
                            parseHtmlString(puja?.purpose?.html ?? '')),
                        commonTextSection(StringConstant.procedure,
                            parseHtmlString(puja?.procedure?.html ?? '')),
                      ],
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                    ),

                    Gap(15.h),

                    BuildSection(
                      whichMode: const SizedBox
                          .shrink(), // No edit button for banner section
                      keyWidget: _bannerKey, // Using unique key
                      temple: puja ?? ContributionPujaModel(),
                      value:
                          -1, // Not using value for navigation in banner section
                      sectionTitle: StringConstant.tabBanner,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: puja?.images?.banner ?? [],
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
                                                    .read<ContributePujaCubit>()
                                                    .updateAcceptBanner(
                                                      'Puja',
                                                      widget.pujaId,
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
                                                    .read<ContributePujaCubit>()
                                                    .updateAcceptBanner(
                                                        'Puja',
                                                        widget.pujaId,
                                                        banner?.id.toString() ??
                                                            '',
                                                        '');
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
                      keyWidget: _galleryKey,
                      temple: puja ?? ContributionPujaModel(),
                      value: -1,
                      sectionTitle: StringConstant.gallery,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: puja?.images?.gallery ?? [],
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
                                                    .read<ContributePujaCubit>()
                                                    .updateAcceptBanner(
                                                      'Puja',
                                                      widget.pujaId,
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
                                                await context
                                                    .read<ContributePujaCubit>()
                                                    .updateAcceptBanner(
                                                      'Puja',
                                                      widget.pujaId,
                                                      gallery?.id.toString() ??
                                                          '',
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

                    Gap(15.h),

                    BuildSection(
                      whichMode: const SizedBox.shrink(),
                      keyWidget: _devKey,
                      temple: puja ?? ContributionPujaModel(),
                      value: -1,
                      sectionTitle: StringConstant.dev,
                      isDarkMode: isDarkMode,
                      calledFrom: widget.calledFrom,
                      hasGridView: true,
                      gridViewItems: puja?.devs ?? [],
                      gridViewItemBuilder: (context, index, item) {
                        final dev = item as Dev;
                        return Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: const Color(0xffe7e7e7)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: Text(
                                  dev.title ?? '',
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
                                                try {
                                                  if (dev.id != null) {
                                                    await context.read<ContributePujaCubit>().updateAcceptBanner(
                                                      'Puja',
                                                      widget.pujaId,
                                                      dev.id.toString(),
                                                      'true',
                                                    );
                                                  }
                                                } catch (e) {
                                                  debugPrint('Error accepting dev: $e');
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to accept: ${e.toString()}')),
                                                    );
                                                  }
                                                }
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
                                                try {
                                                  if (dev.id != null) {
                                                    await context.read<ContributePujaCubit>().updateAcceptBanner(
                                                      'Puja',
                                                      widget.pujaId,
                                                      dev.id.toString(),
                                                      '',
                                                    );
                                                  }
                                                } catch (e) {
                                                  debugPrint('Error rejecting dev: $e');
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to reject: ${e.toString()}')),
                                                    );
                                                  }
                                                }
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

                              if (rejectReasons.isEmpty) {
                                context
                                    .read<ContributePujaCubit>()
                                    .submitPujaReview(
                                        'Puja', widget.pujaId, "true");
                              } else {
                                context
                                    .read<ContributePujaCubit>()
                                    .submitPujaReview(
                                        'Puja', widget.pujaId, "false",
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
  final ContributionPujaModel temple;
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
      ),   margin: EdgeInsets.symmetric(horizontal: 10.sp),
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
                                '/addPuja/${widget.temple.id.toString()}/${'EditPuja'}/${(widget.sectionTitle.toLowerCase()) == "banner" ? 1 : 2}');

                            // AppRouter.push(
                            //     '/addTemple/${widget.temple!.id.toString()}/${widget.temple.governedBy?.id.toString()}/${'EditTemple'}/${(widget.sectionTitle.toLowerCase()) == "banner" ? 1 : 3}');
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
                  final item = widget.gridViewItems[index];

                  return KeyedSubtree(
                    key: ValueKey(item.hashCode), // or item.id if it's a model
                    child: widget.gridViewItemBuilder!(context, index, item),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
