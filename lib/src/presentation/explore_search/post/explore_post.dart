// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../../application/feed/feed_home/feed_home_cubit.dart';
// import '../../../application/feed/feed_home/feed_home_state.dart';
// import '../../core/constants/strings.dart';
// import '../../core/helper/loader.dart';
// import '../../core/widget/custom_cache_image.dart';
// import '../../profile/media/widget/media_list_scroller.dart';
//
// class ExplorePost extends StatefulWidget {
//   const ExplorePost({super.key});
//
//   @override
//   State<ExplorePost> createState() => _ExplorePostState();
// }
//
// class _ExplorePostState extends State<ExplorePost> {
//   final scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<FeedHomeCubit>().fetchFeedHomeData();
//     scrollController.addListener(scrollListener);
//   }
//
//   void scrollListener() {
//     if (scrollController.position.pixels ==
//         scrollController.position.maxScrollExtent) {
//       context.read<FeedHomeCubit>().fetchFeedHomeData(loadMoreData: true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<FeedHomeCubit, FeedHomeState>(builder: (context, state) {
//       if (state is FeedHomeLoaded) {
//         if (state.loadingState) {
//           return const Center(
//             child: CustomLottieLoader(),
//           );
//         }
//         if (state.errorMessage.isNotEmpty) {
//           return Center(
//             child: Text(state.errorMessage),
//           );
//         }
//         if (state.feedList?.isEmpty ?? true) {
//           return Center(child: Text(StringConstant.noDataAvailable));
//         }
//         final eventItems = state.feedList!
//             .where((item) =>
//                 item.media != null &&
//                 item.media!.isNotEmpty &&
//                 item.media!.first.file?.isNotEmpty == true)
//             .toList();
//
//         if (eventItems.isEmpty) {
//           return Center(child: Text(StringConstant.noDataAvailable));
//         }
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 2.sp, vertical: 24.sp),
//           child: ListView(controller: scrollController, children: [
//             GridView.builder(
//                 shrinkWrap: true,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 2.0,
//                     mainAxisSpacing: 2.0,
//                     childAspectRatio: 4 / 3),
//                 itemCount: eventItems.length,
//                 itemBuilder: (context, index) {
//                   return InkWell(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => MediaListScroller(
//                                     id: eventItems[index].id.toString(),
//                                   )));
//                       // AppRouter.push('/singlePuja/${eventItems?[index].id}');
//                     },
//                     child: CustomCacheImage(
//                       borderRadius: BorderRadius.zero,
//                       imageUrl: eventItems[index].media![0].file!,
//                     ),
//                   );
//                 }),
//             if (state.loadingState) const Center(child: CustomLottieLoader())
//           ]),
//         );
//       }
//       return const Center(
//         child: CustomLottieLoader(),
//       );
//     });
//   }
// }
