import 'package:devalay_app/src/application/profile/profile_saved/profile_saved_cubit.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import '../../../../application/profile/profile_saved/profile_saved_state.dart';
import '../../../../core/router/router.dart';

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
    context.read<ProfileSavedCubit>().fetchProfileSavedPujaData();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context
          .read<ProfileSavedCubit>()
          .fetchProfileSavedPujaData(loadMoreData: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileSavedCubit, ProfileSavedState>(
        builder: (context, state) {
      if (state is ProfileSavedLoaded) {
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
        if (state.savePujaModel?.isEmpty ?? true) {
          return  Center(child: Text(StringConstant.noDataAvailable));
        }
        final templeItems = state.savePujaModel;
        return ListView(controller: scrollController, children: [
          GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                  childAspectRatio: 4 / 3),
              itemCount: templeItems?.length,
              itemBuilder: (context, index) {
                final item = templeItems![index];
                final hasImage = item.images?.banner != null &&
                    item.images!.banner!.isNotEmpty;
                final imageUrl =
                    hasImage ? item.images!.banner![0].image : null;

                return InkWell(
                  onTap: () {
                    AppRouter.push('/singlePuja/${templeItems[index].id}');
                  },
                  child: hasImage && imageUrl != null && imageUrl.isNotEmpty
                      ? CustomCacheImage(
                          borderRadius: BorderRadius.zero,
                          showBorder: true,
                          imageUrl: imageUrl,
                        )
                      : Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            item.title ?? StringConstant.noTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.w500),
                          ),
                        ),
                );
              }),
          if (state.loadingState) const Center(child: CustomLottieLoader())
        ]);
      }
      return const Center(
        child: CustomLottieLoader(),
      );
    });
  }
}
