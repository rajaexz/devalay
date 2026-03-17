import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/dashboard/widget/item_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';



class ReviewTempleWidget extends StatefulWidget {
  const ReviewTempleWidget({super.key});

  @override
  State<ReviewTempleWidget> createState() => _ReviewTempleWidgetState();
}

class _ReviewTempleWidgetState extends State<ReviewTempleWidget> {
  late ContributeTempleCubit contributeTempleCubit;
  final scrollController = ScrollController();

  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    contributeTempleCubit = context.read<ContributeTempleCubit>();
   context.read<ContributeTempleCubit>().applyFilter(
          newSectionIndex: 4,
          value: 'true',
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
        value: 'true', // Keep the same filter
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
          debugPrint('Temple list length: ${state.templeList?.length}');
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
                        value: 'true',
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

          return 
           
          RefreshIndicator(
              onRefresh: () async {
                await contributeTempleCubit.applyFilter(
                  newSectionIndex: 4,
                  value: 'true',
                );
              },
            child: SingleChildScrollView(
              controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  ListView.separated(
                    itemCount: state.templeList?.length ?? 0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final templeItem = state.templeList?[index];
                      return 
                      
                       
                      GestureDetector(
                        onTap: () {
                          AppRouter.push(
                            '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/review',
                          );
                        },
                        child: 
                        
        ItemCart(
                    screen: 'Approved',
                    whisType: WhichType.approved,
                    isDraft: templeItem?.draft == true,
                    title: templeItem?.title ?? '',
                    imageUrl: templeItem?.images?.banner?.isNotEmpty == true
                        ? templeItem?.images!.banner![0].image ?? StringConstant.defaultImage
                        : StringConstant.defaultImage,
                    progress: 0.5,
                    lastEdited: 'Since  ${HelperClass().formatDate(templeItem?.updatedAt ?? '')}',
                    contributeCubit: contributeTempleCubit,
                    type: ContributionType.temple,
                    id: templeItem?.id.toString() ?? '',
                  )                 );
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
                        'No more temples to load',
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