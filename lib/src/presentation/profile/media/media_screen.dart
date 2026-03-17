import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/widget/No_data_found.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/profile/profile_profile/profile_profile_cubit.dart';
import '../../../application/profile/profile_profile/profile_profile_state.dart';
import '../../../core/shared_preference.dart';

class MediaScreen extends StatefulWidget {
  final int? id;
  
  const MediaScreen({super.key, this.id});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  late ProfileCubit profileCubit;
  String? userid;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    
    profileCubit = context.read<ProfileCubit>();
    
    // Only initialize with ID if it's not null
    if (widget.id != null) {
      profileCubit.init(widget.id.toString());
    } else {
      profileCubit.fetchProfileData();
    }
    
    _getUserData();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Implement infinite scrolling if your API supports it
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isFetchingMore) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (isFetchingMore) return;
    
    setState(() {
      isFetchingMore = true;
    });

    // If you have pagination in your ProfileCubit, call the load more method here
    // await profileCubit.loadMoreMedia();
    
    if (mounted) {
      setState(() {
        isFetchingMore = false;
      });
    }
  }

  Future<void> _getUserData() async {
    userid = await PrefManager.getUserDevalayId();
    if (mounted) {
      setState(() {});
    }
  }

  void _refreshData() {
    if (widget.id != null) {
      profileCubit.init(widget.id.toString());
    } else {
      profileCubit.fetchProfileData();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            final feedDataList = state.feedList;
            
            // Handle error message
            if (state.errorMessage.isNotEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        state.errorMessage,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }
            
            // Handle null or empty feed list
            if (feedDataList == null || feedDataList.isEmpty) {
              return NoMediaView(
                onRefresh: _refreshData,
                title: StringConstant.noMediaAvailable,
                subtitle:StringConstant.noMediaSubtitle,
                icon: Icons.video_library_outlined,
              );
            }
            
            // Filter items with non-empty media
            final mediaItems = feedDataList
                .where((item) => item.media != null && item.media!.isNotEmpty)
                .toList();
            
            // Check if we have media items after filtering
            if (mediaItems.isEmpty) {
              return NoMediaView(
                onRefresh: _refreshData,
                 title: StringConstant.noMediaAvailable,
                subtitle:StringConstant.noMediaSubtitle,          icon: Icons.video_library_outlined,
              );
            }
            
            // Display grid of media items
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GridView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                  childAspectRatio: 4 / 3,
                ),
                itemCount: mediaItems.length + (isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at the end
                  if (index >= mediaItems.length) {
                    return const Center(child: CustomLottieLoader());
                  }
                  
                  final mediaItem = mediaItems[index];
                  // Safe access to media file URL with fallback
                  final String imageUrl = mediaItem.media?.isNotEmpty == true && 
                                         mediaItem.media![0].file != null
                      ? mediaItem.media![0].file!
                      : StringConstant.defaultImage;
                  
                  return RepaintBoundary(
                    child: InkWell(
                      onTap: () {
                        if (mediaItem.id != null) {
                          AppRouter.push('/mediaDetail/${mediaItem.id.toString()}');
                        }
                      },
                      child: CustomCacheImage(
                        borderRadius: BorderRadius.zero,
                        imageUrl: imageUrl,
                      ),
                    ),
                  );
                },
              ),
            );
          }
          
          // Handle loading state
          return const Center(
            child: CustomLottieLoader(),
          );
        },
      ),
    );
  }
}