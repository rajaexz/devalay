import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/dashboard/widget/item_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';


class DevSubmitted extends StatefulWidget {
  const DevSubmitted({super.key});

  @override
  State<DevSubmitted> createState() => _DevSubmittedState();
}

class _DevSubmittedState extends State<DevSubmitted> {
 late ContributeDevCubit contributeDevCubit;
  final scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    contributeDevCubit = context.read<ContributeDevCubit>();

    context.read<ContributeDevCubit>().sectionIndex = 0;
    context.read<ContributeDevCubit>().fetchContributeDevData(
          draftVal: "false",
          approvedVal:  "false",
          rejectVal:  "false",
       
        );
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    // Check if we've reached the bottom and we're not already loading more data
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        contributeDevCubit.hasMoreData) {
      setState(() {
        isLoadingMore = true;
      });

      // Load more data with the same filter parameters
      contributeDevCubit
          .fetchContributeDevData(
        draftVal: 'true', // Keep the same filter for draft temples
        loadMoreData: true,
      )
          .then((_) {
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

  void _refreshData() {
    contributeDevCubit.sectionIndex = 0;
    contributeDevCubit.fetchContributeDevData(
      draftVal: 'true',
      loadMoreData: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributeDevCubit, ContributeDevState>(
      listener: (context, state) {
        if (state is ContributeDevLoaded) {
          debugPrint('Draft temple list length: ${state.model?.length}');
          // Reset loading state when data is loaded
          if (mounted && isLoadingMore) {
            setState(() {
              isLoadingMore = false;
            });
          }
        }
      },
      builder: (context, state) {
        if (state is ContributeDevLoaded) {
          // Handle permission denied
      
          // Show loading indicator only for initial load when list is empty
          if (state.loadingState && (state.model?.isEmpty ?? true)) {
            return const Center(child: CustomLottieLoader());
          }

          // Additional loading check for templeId
           // Additional loading check for templeId
          if (state.model?.isEmpty ?? false) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(StringConstant.noDataAvailable),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child:  Text(StringConstant.retry),
                  ),
                ],
              ),
            );
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
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show no data message
          if (state.model == null || state.model!.isEmpty) {
            return Center(
              child: Text(
                StringConstant.noDataAvailable,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          // Main content with infinite scroll
          return RefreshIndicator(
            onRefresh: () async {
              await contributeDevCubit.fetchContributeDevData(
                draftVal: 'false',
                approvedVal: 'false',
                rejectVal: 'false',
                loadMoreData: false,
              );
            },
            child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.model!.length +
                  (isLoadingMore ||
                          (state.loadingState && state.model!.isNotEmpty)
                      ? 1
                      : 0),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // Show loading indicator at the end
                if (index == state.model!.length) {
                  return Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final templeItem = state.model?[index];

                return 
                ItemCart(
                  onTap: () {
                    AppRouter.push(
                      '/viewDev/${templeItem?.id.toString()}/draft',
                    );
                  },
                    isDraft: templeItem?.draft == true,
                    title: templeItem?.title ?? '',
                    imageUrl: templeItem?.images?.banner?.isNotEmpty == true
                        ? templeItem?.images!.banner![0].image ??
                            StringConstant.defaultImage
                        : StringConstant.defaultImage,
                    progress: 0.5,
                       lastEdited:
                        ' Submitted on ${HelperClass().formatDate(templeItem?.updatedAt ?? '')}',
          
                                  contributeCubit: contributeDevCubit,
                    type: ContributionType.temple,
                    id: templeItem?.id.toString() ?? '',
                );
              },
              separatorBuilder: (context, index) {
                // Don't add separator for loading indicator
                if (index == state.model!.length - 1 &&
                    (isLoadingMore ||
                        (state.loadingState && state.model!.isNotEmpty))) {
                  return const SizedBox.shrink();
                }
                return Gap(10.h);
              },
              ),
            ),
          );
        }
        return const Center(child: CustomLottieLoader());
      },
    );
  }

}