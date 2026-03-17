import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/dashboard/widget/item_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

 class EventDraft extends StatefulWidget {
   const  EventDraft({super.key});
 
   @override
   State<EventDraft> createState() => _EventDraftState();
 }
 
class _EventDraftState extends State<EventDraft> {
  late ContributeEventCubit contributeEventCubit;
  final scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    contributeEventCubit = context.read<ContributeEventCubit>();

    context.read<ContributeEventCubit>().sectionIndex = 0;
    context.read<ContributeEventCubit>().        fetchContributeEventData(
            
          
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "true",
            loadMoreData: false,
          );
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    // Check if we've reached the bottom and we're not already loading more data
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        contributeEventCubit.hasMoreData) {
      setState(() {
        isLoadingMore = true;
      });

      contributeEventCubit
          .fetchContributeEventData(
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
    contributeEventCubit.sectionIndex = 0;
    contributeEventCubit.fetchContributeEventData(
      draftVal: 'true',
      loadMoreData: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributeEventCubit, ContributeEventState>(
      listener: (context, state) {
        if (state is ContributeEventLoaded) {
          debugPrint('Draft temple list length: ${state.eventList?.length}');
          // Reset loading state when data is loaded
          if (mounted && isLoadingMore) {
            setState(() {
              isLoadingMore = false;
            });
          }
        }
      },
      builder: (context, state) {
        if (state is ContributeEventLoaded) {
   
          if (state.loadingState && (state.eventList?.isEmpty ?? true)) {
            return const Center(child: CustomLottieLoader());
          }

       
          if (state.eventId?.isEmpty ?? false) {
            return const Center(child: CustomLottieLoader());
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
          if (state.eventList == null || state.eventList!.isEmpty) {
              return RefreshIndicator(
              onRefresh: () async {
                await  contributeEventCubit.     fetchContributeEventData(
            
          
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "true",
            loadMoreData: false,
          );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Text(
                        StringConstant.noDataAvailable,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            );
         
          }

          // Main content with infinite scroll
          return RefreshIndicator(
            onRefresh: () async {
              await contributeEventCubit.     fetchContributeEventData(
            
          
            approvedVal: "false",
            rejectVal: "false",
            draftVal: "true",
            loadMoreData: false,
          );
            },
            child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.eventList!.length +
                  (isLoadingMore ||
                          (state.loadingState && state.eventList!.isNotEmpty)
                      ? 1
                      : 0),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // Show loading indicator at the end
                if (index == state.eventList!.length) {
                  return Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final eventItem = state.eventList![index];

                return 
                ItemCart(
                  onTap: () {
                    AppRouter.push(
                      '/viewEvent/${eventItem.id?.toString() ?? ''}/draft',
                    );
                  },
                    whisType: WhichType.draft,
                    isDraft: eventItem.draft == true,
                    title: eventItem.title ?? '',
                    imageUrl: eventItem.images?.banner?.isNotEmpty == true
                        ? eventItem.images!.banner![0].image ??
                            StringConstant.defaultImage
                        : StringConstant.defaultImage,
                    progress: 0.5,
                    lastEdited:
                        '${eventItem.steps} steps remaining ',
                    contributeCubit: contributeEventCubit,
                    type: ContributionType.event,
                    id: eventItem.id?.toString() ?? '',
                );
              },
              separatorBuilder: (context, index) {
                // Don't add separator for loading indicator
                if (index == state.eventList!.length - 1 &&
                    (isLoadingMore ||
                        (state.loadingState && state.eventList!.isNotEmpty))) {
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

