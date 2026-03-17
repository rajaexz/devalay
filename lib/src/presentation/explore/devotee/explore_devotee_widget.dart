import 'package:devalay_app/src/application/explore/explore_devalay/explore_devalay_cubit.dart';
import 'package:devalay_app/src/application/explore/explore_devalay/explore_devalay_state.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/explore/explore_devotees_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/image_Helper.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/No_data_found.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/profile/profile_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';

class ExploreDevoteeWidget extends StatefulWidget {
  const ExploreDevoteeWidget({super.key});

  @override
  State<ExploreDevoteeWidget> createState() => _ExploreDevoteeWidgetState();
}

class _ExploreDevoteeWidgetState extends State<ExploreDevoteeWidget> {
  late ExploreDevalayCubit exploreDevalayCubit;
  final ScrollController _scrollController = ScrollController();
  String? userid;

  @override
  void initState() {
    exploreDevalayCubit = context.read<ExploreDevalayCubit>();
    exploreDevalayCubit.fetchGetAllExploreDevoteesData();
    _scrollController.addListener(_scrollListener);
    getUserData();
    super.initState();
  }

  void _scrollListener() {
    final state = exploreDevalayCubit.state;
    if (state is ExploreDevalayLoaded &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.loadingState) {
      exploreDevalayCubit.fetchGetAllExploreDevoteesData(loadMoreData: true);
    }
  }

  getUserData() async {
    userid = await PrefManager.getUserDevalayId();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.appbarBgColor,
          onRefresh: () async {
            await exploreDevalayCubit.fetchGetAllExploreDevoteesData();
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildSearchField(context),
              ),
              Expanded(
                child: BlocBuilder<ExploreDevalayCubit, ExploreDevalayState>(
                  builder: (context, state) {
                    if (state is ExploreDevalayLoaded) {
                      if (state.exploreDevotees == null ||
                          state.exploreDevotees!.isEmpty) {
                        return Center(
                          child: NoMediaView(
                            onRefresh: () {
                              exploreDevalayCubit
                                  .fetchGetAllExploreDevoteesData(
                                      loadMoreData: true);
                            },
                            title: StringConstant.noDataAvailable,
                            subtitle: StringConstant.noDataMessage,
                            icon: Icons.refresh,
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.exploreDevotees!.length + 1,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        itemBuilder: (context, index) {
                          if (index < state.exploreDevotees!.length) {
                            final devotee = state.exploreDevotees![index];
                            return buildDevoteeCard(devotee, context);
                          } else {
                            return state.loadingState
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: const Center(
                                        child: CustomLottieLoader()),
                                  )
                                : const SizedBox();
                          }
                        },
                      );
                    }

                    return const Center(child: CustomLottieLoader());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: exploreDevalayCubit.scerchProfileController,
        style: TextStyle(
          fontSize: 15.sp,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
          hintText: StringConstant.search,
          hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 15.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
            size: 22.sp,
          ),
          suffixIcon: exploreDevalayCubit
                  .scerchProfileController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    exploreDevalayCubit.scerchProfileController.clear();
                    exploreDevalayCubit.fetchGetAllExploreDevoteesData();
                  },
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                    size: 20.sp,
                  ),
                )
              : null,
          border: InputBorder.none,
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            exploreDevalayCubit.postSearch(makeSearch: value);
          }
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }
}


  Widget buildDevoteeCard(ExploreUser devotee, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileMainScreen(
                  id: int.parse(devotee.id.toString()),
                  profileType: "Devotee",
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              children: [
                Hero(
                  tag: 'devotee_${devotee.id}',
                  child: GestureDetector(
                    onTap: () {
                      if (devotee.dp != null) {
                        ImageHelper.showImagePreview(
                            context, devotee.dp.toString());
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.appbarBgColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CustomCacheImage(
                        imageUrl: devotee.dp ?? StringConstant.defaultImage,
                        height: 60.sp,
                        width: 60.sp,
                        borderRadius: BorderRadius.circular(30.sp),
                      ),
                    ),
                  ),
                ),
                Gap(16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        devotee.name ?? StringConstant.noName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                      ),
                      if (devotee.email != null &&
                          devotee.email!.isNotEmpty) ...[
                        Gap(4.h),
                        Text(
                          devotee.email!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.7),
                                    fontSize: 13.sp,
                                  ),
                        ),
                      ],
                      if (devotee.city != null && devotee.city!.isNotEmpty) ...[
                        Gap(4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14.sp,
                              color: AppColor.appbarBgColor.withOpacity(0.7),
                            ),
                            Gap(4.w),
                            Text(
                              devotee.city!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.6),
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            
              ],
            ),
          ),
        ),
      ),
    );
  }
