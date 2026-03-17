import 'dart:convert';

import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_cubit.dart';
import 'package:devalay_app/src/application/profile/profile_liked/profile_liked_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/router/router.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widget/image_detail_helper.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileLikedTempleCubit>().fetchProfileLikedPostData();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context
          .read<ProfileLikedTempleCubit>()
          .fetchProfileLikedPostData(loadMoreData: true);
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
          return  Center(
              child: Text(state.errorMessage),
          );
        }
        if (state.feedList?.isEmpty ?? true) {
          return   Center(child: Text(StringConstant.noDataAvailable));
        }
        final templeItems = state.feedList;
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
                return InkWell(
                  onTap: () {
                    AppRouter.push(
                        '/mediaDetail/${templeItems?[index].id.toString()}');
                  },
                  child: templeItems?[index].media?.isNotEmpty == true
                      ? ImageHelpers.buildFullWidthMediaList(templeItems?[index].media ??[], context)
                      :  Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            (jsonDecode(templeItems?[index].textDelta.toString()?? "")["ops"][0]["insert"] ?? "") ?? StringConstant.noTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.w500),
                          ),
                        ),
                );
              }),
        ]);
      }
      return const Center(
        child: CustomLottieLoader(),
      );
    });
  }
}
