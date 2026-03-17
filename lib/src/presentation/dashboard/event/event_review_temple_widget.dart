import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widget/item_cart.dart';

class EventReviewTempleWidget extends StatefulWidget {
  const EventReviewTempleWidget({super.key});

  @override
  State<EventReviewTempleWidget> createState() =>
      _EventReviewTempleWidgetState();
}

class _EventReviewTempleWidgetState extends State<EventReviewTempleWidget> {
  late ContributeEventCubit contributeEventCubit;

  @override
  void initState() {
    super.initState();
    contributeEventCubit = ContributeEventCubit();
    contributeEventCubit.fetchContributeEventData(
      value: "true",
      loadMoreData: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => contributeEventCubit,
      child: BlocBuilder<ContributeEventCubit, ContributeEventState>(
        builder: (context, state) {
          if (state is ContributeEventLoaded) {
           
            if (state.eventList?.isEmpty ?? true) {
           
                
                  return RefreshIndicator(
              onRefresh: () async {
                  contributeEventCubit.fetchContributeEventData(
      value: "true",
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


            return RefreshIndicator(
              onRefresh: () async {
                await contributeEventCubit.fetchContributeEventData(
                  value: "true",
                  loadMoreData: false,
                );
              },
              child: ListView.builder(
              itemCount: state.eventList?.length ?? 0,
              itemBuilder: (context, index) {
                final event = state.eventList?[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ItemCart(
                    onTap: () {
                      AppRouter.push(
                        '/viewEvent/${event?.id.toString()}/draft',
                      );
                    },
                    whisType: WhichType.review,
                    isDraft: event?.draft == true,
                    title: event?.title ?? '',
                    imageUrl: event?.images?.banner?.isNotEmpty == true
                        ? event?.images!.banner![0].image ??
                            StringConstant.defaultImage
                        : StringConstant.defaultImage,
                    progress: 0.5,
                    lastEdited:
                        'Since ${HelperClass().formatDate(event?.updatedAt ?? '')}',
                    contributeCubit: contributeEventCubit,
                    type: ContributionType.temple,
                    id: event?.id.toString() ?? '',
                  ),
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

  // @override
  // void dispose() {
  //   contributeEventCubit.close();
  //   super.dispose();
  // }
}
