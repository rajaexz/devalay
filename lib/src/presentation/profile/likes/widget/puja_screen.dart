import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_state.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import '../../../../core/router/router.dart';
import '../../../core/constants/strings.dart';

class PujaScreen extends StatefulWidget {
  const PujaScreen({super.key});

  @override
  State<PujaScreen> createState() => _PujaScreenState();
}

class _PujaScreenState extends State<PujaScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileLikedTempleCubit>().fetchProfileLikedPujaData();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context
          .read<ProfileLikedTempleCubit>()
          .fetchProfileLikedPujaData(loadMoreData: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileLikedTempleCubit, ProfileLikedTempleState>(
        builder: (context, state) {
      if (state is ProfileLikedTempleLoaded) {
        if (state.loadingState) {
          return const Center(
            child: CustomLottieLoader(),
          );
        }
        if (state.errorMessage.isNotEmpty) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        if (state.likeEventModel?.isEmpty ?? true) {
          return  Center(child: Text(StringConstant.noDataAvailable));
        }
        final eventItems = state.likeEventModel;
        return ListView(controller: scrollController, children: [
          GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                  childAspectRatio: 4/3),
              itemCount: eventItems?.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    AppRouter.push('/singlePuja/${eventItems?[index].id}');
                  },
                  child: eventItems?[index].images?.banner?.isNotEmpty == true
                      ? CustomCacheImage(
                          borderRadius: BorderRadius.zero,
                          imageUrl:
                              eventItems?[index].images?.banner?[0].image ??
                                  StringConstant.defaultImage)
                      : const CustomCacheImage(
                          borderRadius: BorderRadius.zero,
                          imageUrl: StringConstant.defaultImage),
                );
              }),
          if (state.loadingState)
            const Center(child: CustomLottieLoader())
        ]);
      }
      return const Center(
        child: CustomLottieLoader(),
      );
    });
  }
}
