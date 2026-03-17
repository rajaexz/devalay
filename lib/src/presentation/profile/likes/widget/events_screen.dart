import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/strings.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileLikedTempleCubit>().fetchProfileLikedEventData();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      context.read<ProfileLikedTempleCubit>().fetchProfileLikedEventData(loadMoreData: true);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileLikedTempleCubit, ProfileLikedTempleState>(
      builder: (context, state) {
        if (state is ProfileLikedTempleLoaded) {
          if (state.loadingState) {
            return const Center(child: CustomLottieLoader());
          }
          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text(state.errorMessage));
          }
          if (state.likeEventModel?.isEmpty ?? true) {
            return Center(child: Text(StringConstant.noDataAvailable));
          }

          final eventItems = state.likeEventModel;
          return GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 4/3,
            ),
            itemCount: (eventItems?.length ?? 0) + (state.loadingState ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == eventItems!.length) {
                return const Center(child: CustomLottieLoader());
              }
              return InkWell(
                onTap: () {
                  AppRouter.push('/singleEvent/${eventItems[index].id}');
                },
                child: eventItems[index].images?.banner?.isNotEmpty == true
                  ? CustomCacheImage(
                      borderRadius: BorderRadius.zero,
                      imageUrl: eventItems[index].images?.banner?[0].image ?? StringConstant.defaultImage,
                    )
                  : const CustomCacheImage(
                      borderRadius: BorderRadius.zero,
                      imageUrl: StringConstant.defaultImage,
                    ),
              );
            },
          );
        }
        return const Center(child: CustomLottieLoader());
      },
    );
  }
}
