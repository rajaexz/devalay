import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../application/explore/explore_devalay/explore_devalay_cubit.dart';
import '../../../application/explore/explore_devalay/explore_devalay_state.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/loader.dart';
import '../custom_widget/custom_intro_button.dart';
import 'shared/intro_content_card.dart';

class FollowTempleScreen extends StatefulWidget {
  const FollowTempleScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<FollowTempleScreen> createState() => _FollowTempleScreenState();
}

class _FollowTempleScreenState extends State<FollowTempleScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _fetchInitialData() {
    context.read<ExploreDevalayCubit>().fetchExploreDevalayData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ExploreDevalayCubit>().fetchExploreDevalayData(loadMoreData: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreDevalayCubit, ExploreDevalayState>(
        builder: (context, state) {
      // Show loader for initial state
      if (state is ExploreDevalayInitial) {
        return const Center(child: CustomLottieLoader());
      }
      
      if (state is ExploreDevalayLoaded) {
        return _buildContent(state);
      }
      
      // Fallback loader
      return const Center(child: CustomLottieLoader());
      },
    );
  }

  Widget _buildContent(ExploreDevalayLoaded state) {
    // Show loader while loading and no data exists
    if (state.loadingState && (state.exploreDevalayList == null || state.exploreDevalayList!.isEmpty)) {
      return const Center(child: CustomLottieLoader());
    }

    // Show error message only if not loading and error exists
    if (!state.loadingState && state.errorMessage.isNotEmpty && (state.exploreDevalayList == null || state.exploreDevalayList!.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchInitialData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state only if not loading and no error
    final temples = state.exploreDevalayList;
    if (!state.loadingState && (temples == null || temples.isEmpty)) {
      return Center(
        child: Text(
          StringConstant.noDataAvailable,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    // If we have data, show the list
    if (temples == null || temples.isEmpty) {
      // Still loading or waiting for data
      return const Center(child: CustomLottieLoader());
    }

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: _buildTempleList(temples),
        ),
            Gap(25.h),
            Expanded(
              flex: 1,
              child: CustomIntroButton(
            onNextTap: widget.onNext,
            onBackTap: widget.onBack,
              ),
            ),
            Gap(25.h),
          ],
        );
      }

  Widget _buildTempleList(List temples) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.sp),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: temples.length,
        itemBuilder: (context, index) {
          final item = temples[index];
          return _buildTempleCard(item);
        },
      ),
    );
  }

  Widget _buildTempleCard(dynamic item) {
    final imageUrl = (item.images?.banner != null && item.images!.banner!.isNotEmpty)
        ? item.images!.banner!.first.image
        : StringConstant.defaultImage;

    return IntroContentCard(
      imageUrl: imageUrl,
      title: item.title ?? '',
      subtitle: item.city ?? '',
      isLiked: item.liked ?? false,
      likeCount: item.likedCount ?? 0,
      onLikeTap: () => _handleLikeTap(item),
      isSaved: item.saved ?? false,
      saveCount: item.savedCount ?? 0,
      onSaveTap: () => _handleSaveTap(item),
    );
  }

  void _handleLikeTap(dynamic item) {
    final isLiked = !(item.liked ?? false);
    context.read<ExploreDevalayCubit>().changeLikeStatus(
      item.id.toString(),
      isLiked.toString(),
    );
  }

  void _handleSaveTap(dynamic item) {
    context.read<ExploreDevalayCubit>().changeSavedStatus(
      item.id.toString(),
      (item.saved ?? false) ? 'false' : 'true',
    );
  }
}
