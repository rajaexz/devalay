import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/dashboard/widget/item_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class EventRejected extends StatefulWidget {
  const EventRejected({super.key});

  @override
  State<EventRejected> createState() => _EventRejectedState();
}

class _EventRejectedState extends State<EventRejected> {
  late ContributeEventCubit contributeEventCubit;

  @override
  void initState() {
    super.initState();
    contributeEventCubit = context.read<ContributeEventCubit>();
    _fetchData();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     context.read<ContributeEventCubit>().applyFilter(
    //           newSectionIndex: 3,
    //           value: 'true',
    //         );
    //   }
    // });
  }

  void _fetchData() {
    contributeEventCubit.fetchContributeEventData(
      rejectVal: 'true',
      loadMoreData: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: contributeEventCubit,
      child: BlocBuilder<ContributeEventCubit, ContributeEventState>(
        builder: (context, state) {
          if (state is ContributeEventLoaded) {
            if (state.loadingState) {
              return const Center(child: CustomLottieLoader());
            }
            if (state.errorMessage.isNotEmpty) {
              return Center(child: Text(state.errorMessage));
            }
            if (state.eventList?.isEmpty ?? true) {
           
                
                  return RefreshIndicator(
              onRefresh: () async {
                   _fetchData();
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

            return RefreshIndicator(
              onRefresh: () async {
                _fetchData();
              },
              child: ListView.separated(
                itemCount: state.eventList?.length ?? 0,
                separatorBuilder: (context, index) => Gap(10.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final event = state.eventList?[index];
                  return ItemCart(
                    onTap: () {
                      AppRouter.push(
                        '/viewEvent/${event?.id.toString()}/${event?.devalay?.id.toString()}/draft',
                      );
                    },
                         whisType: WhichType.rejected,
                      isDraft: event?.draft == true,
                      title: event?.title ?? '',
                      imageUrl: event?.images?.banner?.isNotEmpty == true
                          ? event?.images!.banner![0].image ?? StringConstant.defaultImage
                          : StringConstant.defaultImage,
                      progress: 0.5,
                   
                     
                       lastEdited: 'Rejected on ${HelperClass().formatDate(event?.updatedAt ?? '')}',
                 
                     contributeCubit: contributeEventCubit,
                      type: ContributionType.event,
                      id: event?.id.toString() ?? '',
                      governedById: event?.devalay?.id.toString(),
                  );
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  void dispose() {
    contributeEventCubit.close();
    super.dispose();
  }
} 