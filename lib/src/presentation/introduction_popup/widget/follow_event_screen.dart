import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart' show PrefManager;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../application/explore/explore_event/explore_event_cubit.dart';
import '../../../application/explore/explore_event/explore_event_state.dart';
import '../../core/constants/strings.dart';
import '../../core/helper/loader.dart';
import '../custom_widget/custom_intro_button.dart';
import 'shared/intro_content_card.dart';

class FollowEventScreen extends StatefulWidget {
  const FollowEventScreen({
    super.key, 
    required this.onNext, 
    required this.onBack,
    this.isProviderService = false,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isProviderService;

  @override
  State<FollowEventScreen> createState() => _FollowEventScreenState();
}

class _FollowEventScreenState extends State<FollowEventScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _fetchInitialData() {
    context.read<ExploreEventCubit>().fetchExploreEventData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ExploreEventCubit>().fetchExploreEventData(loadMoreData: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============ Helper Methods ============

  String _formatDateRange(dynamic item) {
    final startDate = _formatDate(item.dates?[0].startDate?.toString());
    final endDate = _formatDate(item.dates?[0].endDate?.toString());
    final city = item.city ?? '';
    
    if (startDate.isEmpty && endDate.isEmpty) {
      return city;
    }
    return "$startDate to $endDate, $city";
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM').format(date);
    } catch (e) {
      return '';
    }
  }

  void _handleNextTap() {
    if (widget.isProviderService) {
      widget.onNext();
      PrefManager.setIsPandit(widget.isProviderService);
    } else {
      AppRouter.push(RouterConstant.landingScreen);
    }
  }

  // ============ Build Methods ============

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreEventCubit, ExploreEventState>(
        builder: (context, state) {
      // Show loader for initial state
      if (state is ExploreEventInitial) {
        return const Center(child: CustomLottieLoader());
      }
      
      if (state is ExploreEventLoaded) {
        return _buildContent(state);
      }
      
      // Fallback loader
      return const Center(child: CustomLottieLoader());
      },
    );
  }

  Widget _buildContent(ExploreEventLoaded state) {
    // Show loader while loading and no data exists
    if (state.loadingState && (state.exploreEventList == null || state.exploreEventList!.isEmpty)) {
      return const Center(child: CustomLottieLoader());
    }

    // Show error message only if not loading and error exists
    if (!state.loadingState && state.errorMessage.isNotEmpty && (state.exploreEventList == null || state.exploreEventList!.isEmpty)) {
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

    // If we have data, show the list
    final events = state.exploreEventList;
    if (events == null || events.isEmpty) {
      // Still loading or waiting for data
      return const Center(child: CustomLottieLoader());
    }

    return Column(
      children: [
        Expanded(
          flex: 8,
          child: _buildEventList(events),
        ),
        Gap(25.h),
        Expanded(
          flex: 1,
          child: CustomIntroButton(
            onNextTap: _handleNextTap,
            onBackTap: widget.onBack,
          ),
        ),
        Gap(25.h),
      ],
    );
  }

  Widget _buildEventList(List events) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.sp),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: events.length,
        itemBuilder: (context, index) {
          final item = events[index];
          return _buildEventCard(item);
        },
      ),
    );
  }

  Widget _buildEventCard(dynamic item) {
    final imageUrl = (item.images?.banner != null && item.images!.banner!.isNotEmpty)
        ? item.images!.banner!.first.image
        : StringConstant.defaultImage;

    return IntroContentCard(
      imageUrl: imageUrl,
      title: item.title ?? '',
      subtitle: _formatDateRange(item),
      isLiked: item.liked ?? false,
      likeCount: item.likedCount ?? 0,
      onLikeTap: () => _handleLikeTap(item),
      isSaved: item.saved ?? false,
      saveCount: item.savedCount ?? 0,
      onSaveTap: () => _handleSaveTap(item),
    );
  }

  void _handleLikeTap(dynamic item) {
    context.read<ExploreEventCubit>().changeLikeStatus(
      item.id.toString(),
      (item.liked ?? false) ? 'false' : 'true',
    );
  }

  void _handleSaveTap(dynamic item) {
    context.read<ExploreEventCubit>().changeSavedStatus(
      item.id.toString(),
      (item.saved ?? false) ? 'false' : 'true',
    );
  }
}
