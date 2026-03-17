import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class MonitoTempleWidget extends StatefulWidget {
  const MonitoTempleWidget({super.key});

  @override
  State<MonitoTempleWidget> createState() => _MonitoTempleWidgetState();
}

class _MonitoTempleWidgetState extends State<MonitoTempleWidget> {
  late ContributeTempleCubit contributeTempleCubit;
  final scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    contributeTempleCubit = context.read<ContributeTempleCubit>();
    
    // Set section index
    contributeTempleCubit.sectionIndex = 1;
    
    // Initial data load for monitoring (value: 'false' for unmonitored temples)
    contributeTempleCubit.fetchContributeTempleData(
      value: 'false', // For monitoring temples that are not approved/monitored
      loadMoreData: false,
    );
    
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    // Check if we've reached the bottom and we're not already loading more data
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && 
        !isLoadingMore && 
        contributeTempleCubit.hasMoreData) {
      
      setState(() {
        isLoadingMore = true;
      });
      
      // Load more data with the same filter parameters
      contributeTempleCubit.fetchContributeTempleData(
        value: 'false', // Keep the same filter for monitoring
        loadMoreData: true,
      ).then((_) {
        if (mounted) {
          setState(() {
            isLoadingMore = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributeTempleCubit, ContributeTempleState>(
      listener: (context, state) {
        if (state is ContributeTempleLoaded) {
          debugPrint('Monitor temple list length: ${state.templeList?.length}');
          // Reset loading state when data is loaded
          if (mounted && isLoadingMore) {
            setState(() {
              isLoadingMore = false;
            });
          }
        }
      },
      builder: (context, state) {
        if (state is ContributeTempleLoaded) {
          // Show loading indicator only for initial load when list is empty
          if (state.loadingState && (state.templeList?.isEmpty ?? true)) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Show error message
          if (state.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      contributeTempleCubit.fetchContributeTempleData(
                        value: 'false',
                        loadMoreData: false,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show no data message
          if (state.templeList == null || state.templeList!.isEmpty) {
            return Center(child: Text(StringConstant.noDataAvailable));
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.sp),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  ListView.separated(
                    itemCount: state.templeList?.length ?? 0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final templeItem = state.templeList?[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff132c4a).withOpacity(0.04),
                              offset: const Offset(0, 7),
                              blurRadius: 5,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            AppRouter.push(
                              '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/monitor',
                            );
                          },
                          child: AspectRatio(
                            aspectRatio: 4 / 1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 4.sp / 3.sp,
                                  child: CustomCacheImage(
                                    imageUrl: templeItem?.images?.banner?.isNotEmpty == true
                                        ? templeItem?.images!.banner![0].image ?? ''
                                        : StringConstant.defaultImage,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: 5.sp,
                                      bottom: 5.sp,
                                      left: 5.sp,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          templeItem?.title ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        Text(
                                          "${templeItem?.city ?? ''}, ${templeItem?.state ?? ''}",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          'initiated ${HelperClass().formatDate(templeItem?.createdAt ?? '')}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Gap(10.h),
                  ),
                  
                  // Loading indicator for pagination
                  if (isLoadingMore || (state.loadingState && state.templeList?.isNotEmpty == true))
                    Padding(
                      padding: EdgeInsets.all(16.sp),
                      child: const CircularProgressIndicator(),
                    ),
                    
                  // End of data indicator
                  if (!contributeTempleCubit.hasMoreData && state.templeList?.isNotEmpty == true)
                    Padding(
                      padding: EdgeInsets.all(16.sp),
                      child: Text(
                        'No more temples to monitor',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          );
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}