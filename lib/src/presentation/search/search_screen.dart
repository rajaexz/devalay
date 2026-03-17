import 'dart:async';

import 'package:devalay_app/src/application/globle_search/globle_search_cubit.dart';
import 'package:devalay_app/src/application/globle_search/globle_search_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/data/model/explore/globle_seach_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/image_Helper.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/No_data_found.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/search/filter/post_filter.dart' show PostFilterWidget;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import '../explore_search/filter/event_filter.dart';
import 'filter/dev_filter.dart' show DevFilterWidget;
import 'filter/festival_filter.dart' show FestivalFilterWidget;
import 'filter/temple_filter.dart';

class SearchScreen extends StatefulWidget {
final  String? type;
  const SearchScreen({this.type, super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late GobelSearchCubit globleSearchCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    globleSearchCubit = context.read<GobelSearchCubit>();
    globleSearchCubit.searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    
   
    if (widget.type != null && widget.type!.isNotEmpty) {
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    globleSearchCubit.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    const threshold = 200.0;
    if (position.maxScrollExtent - position.pixels <= threshold) {
      _loadMoreData();
    }
  }

 

  getOpenFilter({required String type}) {

    switch (type) {
      case "Posts":
        _showPostBottomSheet();
        break;
      case "Temple":
        _showDevalayBottomSheet();
        break;
      case "Event":
        _showEventBottomSheet();
        break;
      case "Dev":
        _showDevBottomSheet();
        break;
      case "People":
        _showPostBottomSheet();
        break;
      case "Festival":
        _showFestivalBottomSheet();
        break;
      default:
        _showPostBottomSheet();
    }
  }



  void _onSearchChanged() {
    if (globleSearchCubit.debounce?.isActive ?? false)
      globleSearchCubit.debounce!.cancel();

    globleSearchCubit.debounce = Timer(const Duration(milliseconds: 500), () {
      if (globleSearchCubit.searchController.text.trim().length >= 3) {
        setState(() {
          globleSearchCubit.showResults = true;
        });
        _applyFilter();
      } else if (globleSearchCubit.searchController.text.trim().isEmpty) {
        setState(() {
          globleSearchCubit.showResults = false;
        });
        _applyFilter();
      }
    });
  }

  void _loadInitialData() {
    globleSearchCubit.page = 1;
    globleSearchCubit.hasMoreData = true;
    globleSearchCubit.fetchGlobleSearchData(
      makeSearch: '',
      textType: widget.type ?? "",
      filterQuery: globleSearchCubit.currentFilterQuery,
      loadMoreData: false,
    );
  }

  void _applyFilter() {
    // Reset pagination when applying new filter or search
    globleSearchCubit.page = 1;
    globleSearchCubit.hasMoreData = true;
    
    // Only call API if there's search text
    if (globleSearchCubit.searchController.text.trim().isNotEmpty) {
      globleSearchCubit.fetchGlobleSearchData(
        makeSearch: globleSearchCubit.searchController.text,
        textType: widget.type ?? "",
        filterQuery: globleSearchCubit.currentFilterQuery,
        loadMoreData: false,
      );
    } else if (globleSearchCubit.searchController.text.trim().isEmpty) {
      _loadInitialData();
    }
  }

  void _loadMoreData() {
    // Prevent multiple simultaneous calls
    if (globleSearchCubit.isFetching) {
      return;
    }

    final state = globleSearchCubit.state;
    final searchText = globleSearchCubit.searchController.text.trim();
    
    // Allow loading more if search is empty (for initial load) or has valid search text
    final hasValidSearch = searchText.isEmpty || searchText.length >= 3;
    
    // Check if we should load more data
    if (!globleSearchCubit.hasMoreData || 
        (state is GlobleLoaded && state.loadingState) ||
        !hasValidSearch) {
      return;
    }

    // Increment page before making the request
    globleSearchCubit.page++;
    
    // Load more data with current filter query
    globleSearchCubit.fetchGlobleSearchData(
      makeSearch: searchText,
      textType: widget.type ?? "",
      filterQuery: globleSearchCubit.currentFilterQuery,
      loadMoreData: true,
    );
  }
  void getNavigator({required String id, required String type}) {

    switch (type) {
      case "Festival":
        AppRouter.push('/singleFestival/$id');
        break;
      case "Puja":
        AppRouter.push('/singlePuja/$id');
        break;
      case "Dev":
        AppRouter.push('/singleGod/$id');
        break;
      case "Temple":
        AppRouter.push('/singleDevalay/$id');
        break;
      case "Event":
        AppRouter.push('/singleEvent/$id');
        break;
      case "People":
        AppRouter.push('/profileMainScreen/$id/devotees');
        break;
      default:
        AppRouter.push('/singleEvent/$id');
    }
  }

  void _showDevalayBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) => const TempleFilterWidget(),
    );
  }

  void _showEventBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) => const EventFilterWidget(),
    );
  }

  void _showPostBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) => const PostFilterWidget(),
    );
  }

  void _showFestivalBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) => const FestivalFilterWidget(),
    );
  }

  void _showDevBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) => const DevFilterWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.0.sp),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      AppRouter.pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: globleSearchCubit.focusNode,
                      controller: globleSearchCubit.searchController,
                      decoration: InputDecoration(
                        hintText: StringConstant.search,
                      
                        filled: true,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.sp, vertical: 10.sp),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            globleSearchCubit.showResults = true;
                          });
                          _applyFilter();
                        }
                      },
                    ),
                  ),
                  Gap(8.w),
                  InkWell(
                    onTap: () {
                      getOpenFilter(type: widget.type ?? "Post");
                    },
                    child: SvgPicture.asset(
                        height: 30.h,
                        width: 30.h,
                        "assets/icon/search_filter.svg"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: 
                  _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<GobelSearchCubit, GlobleState>(
      builder: (context, state) {
        if (state is GlobleInitial) {
          return const Center(child: Text("Search for items"));
        }

        if (state is GlobleLoaded) {
          if (state.loadingState &&
              (state.data == null || state.data!.isEmpty)) {
            return const Center(child: CustomLottieLoader());
          }

          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text(state.errorMessage));
          }

          final searchResults = state.data;
          if (searchResults == null || searchResults.isEmpty) {
            return NoMediaView(
              title: StringConstant.noDataAvailable,
              subtitle: StringConstant.noDataMessage,
              icon: Icons.search,
              onRefresh: () {
                _applyFilter();
              },
            );
          }

          final isLoadingMore = globleSearchCubit.isFetching &&
              globleSearchCubit.hasMoreData &&
              searchResults.isNotEmpty;
          
          return ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: searchResults.length + (isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              // Show loading indicator at the end when loading more
              // Don't call _loadMoreData() here - the scroll listener handles it
              if (index == searchResults.length) {
                return Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final item = searchResults[index];
              final isUser = widget.type == "People";

              String? imageUrl;
              if (isUser) {
                imageUrl = _sanitizeImageUrl(item.dp) ??
                    _extractImageUrl(item.image) ??
                    _sanitizeImageUrl(item.thumbnailUrl);
              } else {
                imageUrl = _extractImageUrl(item.image) ??
                    _sanitizeImageUrl(item.thumbnailUrl);
              }

              imageUrl = imageUrl ?? StringConstant.defaultImage;
              
              final displayTitle = _resolveDisplayTitle(item, isUser);

              return GestureDetector(
                onTap: () => getNavigator(
                  id: item.id.toString(),
                  type:widget.type.toString(),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        ImageHelper.showImagePreview(
                            context, imageUrl.toString());
                      },
                      child: CustomCacheImage(
                        borderRadius: BorderRadius.circular(8),
                        imageUrl: imageUrl.toString(),
                        height: 60.h,
                        width: 60.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.type ?? "Unknown",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            displayTitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return const Center(child: CustomLottieLoader());
      },
    );
  }

  String _resolveDisplayTitle(Result item, bool isUser) {
    final primary = isUser ? item.name : item.title;
    final fallback = isUser ? item.title : item.name;

    if (primary != null && primary.trim().isNotEmpty) {
      return primary.trim();
    }

    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback.trim();
    }

    return StringConstant.noTitle;
  }

  String? _sanitizeImageUrl(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.toLowerCase() == "null") return null;
    return trimmed;
  }

  String? _extractImageUrl(dynamic imageData) {
    if (imageData == null) return null;

    if (imageData is String) {
      final trimmed = imageData.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (imageData is List) {
      for (final entry in imageData) {
        final url = _extractImageUrl(entry);
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
      return null;
    }

    if (imageData is Map) {
      final directImage = imageData["image"];
      if (directImage is String && directImage.trim().isNotEmpty) {
        return directImage.trim();
      }

      final dynamic imagesObj = imageData["images"] ?? imageData;

      if (imagesObj is Map) {
        final gallery = imagesObj["Gallery"];
        if (gallery is List && gallery.isNotEmpty) {
          final galleryImage = _extractImageUrl(gallery.first);
          if (galleryImage != null && galleryImage.isNotEmpty) {
            return galleryImage;
          }
        }

        final banner = imagesObj["Banner"];
        if (banner is List && banner.isNotEmpty) {
          final bannerImage = _extractImageUrl(banner.first);
          if (bannerImage != null && bannerImage.isNotEmpty) {
            return bannerImage;
          }
        }
      }
    }

    return null;
  }
}
