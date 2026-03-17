import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/contribute/widget/view_edit_bottomsheet.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

// class DraftTempleWidget extends StatefulWidget {
//   const DraftTempleWidget({super.key});

//   @override
//   State<DraftTempleWidget> createState() => _DraftTempleWidgetState();
// }

// class _DraftTempleWidgetState extends State<DraftTempleWidget> {
//   late ContributeTempleCubit contributeTempleCubit;

//   @override
//   void initState() {
//     super.initState();
//     context.read<ContributeTempleCubit>().sectionIndex = 0;
//     context.read<ContributeTempleCubit>().applyFilter(
//           newSectionIndex: 0,
//           value: null,
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
//       builder: (context, state) {
//         if (state is ContributeTempleLoaded) {
//           if (state.isPermissionDenied) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Row(
//                     children: [
//                       Icon(
//                         Icons.warning_amber_rounded,
//                         color: const Color(0xffFF4C02),
//                         size: 24.sp,
//                       ),
//                       Gap(8.w),
//                       Text(
//                         'Permission Denied',
//                         style:
//                             Theme.of(context).textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                       ),
//                     ],
//                   ),
//                   content: Text(
//                     '${StringConstant.youdonot} puja.',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(); // Close dialog
//                         Navigator.of(context).pop(); // Go back
//                         Navigator.of(context).pop(); // Go back again
//                         context.read<ContributeTempleCubit>().sectionIndex = 0;
//                         context.read<ContributeTempleCubit>().applyFilter(
//                               newSectionIndex: 0,
//                               value: null,
//                             );
//                       },
//                       child: const Text(
//                         'OK',
//                         style: TextStyle(
//                           color: AppColor.appbarBgColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             });
//           }
//               if (state.loadingState) {
//             return const Center(child: CustomLottieLoader());
//           }
//           if (state.templeId?.length == 0){
//             return const Center(child: CustomLottieLoader());
//           }
//           return state.templeList!.isNotEmpty
//               ? MediaQuery.removePadding(
//                   context: context,
//                   removeTop: true,
//                   child: ListView.separated(
//                     itemCount: state.templeList?.length ?? 0,
//                     shrinkWrap: true,
//                     itemBuilder: (context, index) {
//                       final templeItem = state.templeList?[index];
//                       return Container(
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).secondaryHeaderColor,
//                           borderRadius: BorderRadius.circular(10.r),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0xff132c4a).withOpacity(0.04),
//                               offset: const Offset(0, 7),
//                               blurRadius: 5,
//                               spreadRadius: -2,
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             templeItem?.draft == true
//                                 ? Container(
//                                     height: 30.h,
//                                     decoration: BoxDecoration(
//                                         color: Theme.of(context).brightness ==
//                                                 Brightness.dark
//                                             ? AppColor.lightTextColor
//                                             : const Color(0xffFFE8EB),
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(10.r),
//                                           topRight: Radius.circular(10.r),
//                                         )),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Padding(
//                                           padding: EdgeInsets.only(left: 10.sp),
//                                           child: const Icon(
//                                             Icons.warning_amber_rounded,
//                                             color: Color(0xffFF4C02),
//                                           ),
//                                         ),
//                                         Text(
//                                           StringConstant.pleaseCompleteAll,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium
//                                               ?.copyWith(
//                                                 color: const Color(0xffFF4C02),
//                                               ),
//                                         ),
//                                         InkWell(
//                                           onTap: () {
//                                             showModalBottomSheet(
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                           topLeft:
//                                                               Radius.circular(
//                                                                   20.r),
//                                                           topRight:
//                                                               Radius.circular(
//                                                                   20.r))),
//                                               context: context,
//                                               builder: (context) {
//                                                 return ViewEditBottomsheet(
//                                                   viewTap: () {
//                                                     Navigator.pop(context);
//                                                     AppRouter.push(
//                                                         '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/${'draft'}');
//                                                   },
//                                                   editTap: () {
//                                                     Navigator.pop(context);
//                                                     AppRouter.push(
//                                                         '/addTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/${'EditTemple'}/${0}');
//                                                   },
//                                                   deleteTap: () {
//                                                     Navigator.pop(context);
//                                                     showDialog(
//                                                         context: context,
//                                                         builder: (BuildContext
//                                                             context) {
//                                                           return AlertDialog(
//                                                             title: Text(
//                                                                 StringConstant
//                                                                     .delete),
//                                                             content: Text(
//                                                                 StringConstant
//                                                                     .areYouSureDelete),
//                                                             actions: [
//                                                               TextButton(
//                                                                 onPressed: () =>
//                                                                     Navigator.pop(
//                                                                         context),
//                                                                 child: Text(
//                                                                     StringConstant
//                                                                         .cancel),
//                                                               ),
//                                                               TextButton(
//                                                                 onPressed: () {
//                                                                   Navigator.pop(
//                                                                       context);
//                                                                   context
//                                                                       .read<
//                                                                           ContributeTempleCubit>()
//                                                                       .deleteItem(
//                                                                           'Devalay',
//                                                                           '${templeItem?.id.toString()}');
//                                                                   context
//                                                                       .read<
//                                                                           ContributeTempleCubit>()
//                                                                       .sectionIndex = 0;
//                                                                   context
//                                                                       .read<
//                                                                           ContributeTempleCubit>()
//                                                                       .applyFilter(
//                                                                         newSectionIndex:
//                                                                             0,
//                                                                         value:
//                                                                             null,
//                                                                       );
//                                                                 },
//                                                                 child: Text(
//                                                                     StringConstant
//                                                                         .ok),
//                                                               ),
//                                                             ],
//                                                           );
//                                                         });
//                                                   },
//                                                 );
//                                               },
//                                             );
//                                           },
//                                           child: const Icon(
//                                             Icons.more_vert,
//                                             color: Color(0xffFF4C02),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 : const SizedBox.shrink(),
//                             InkWell(
//                               onTap: () {
//                                 AppRouter.push(
//                                     '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/${'draft'}');
//                               },
//                               child: AspectRatio(
//                                 aspectRatio: 4 / 1,
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     AspectRatio(
//                                       aspectRatio: 4.sp / 3.sp,
//                                       child: CustomCacheImage(
//                                         imageUrl: templeItem?.images?.banner
//                                                     ?.isNotEmpty ==
//                                                 true
//                                             ? templeItem?.images!.banner![0]
//                                                     .image ??
//                                                 ''
//                                             : StringConstant.defaultImage,
//                                         borderRadius:
//                                             BorderRadius.circular(5.r),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Padding(
//                                         padding: EdgeInsets.only(
//                                             top: 5.sp,
//                                             bottom: 5.sp,
//                                             left: 5.sp),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceEvenly,
//                                           children: [
//                                             Text(
//                                               templeItem?.title ?? '',
//                                               style: Theme.of(context)
//                                                   .textTheme
//                                                   .bodyMedium
//                                                   ?.copyWith(),
//                                             ),
//                                             Text(
//                                               "${templeItem?.city ?? ''},${templeItem?.state ?? ''}",
//                                               style: Theme.of(context)
//                                                   .textTheme
//                                                   .bodySmall,
//                                             ),
//                                             Text(
//                                               'initiated ${HelperClass().formatDate(templeItem?.createdAt ?? '')}',
//                                               style: Theme.of(context)
//                                                   .textTheme
//                                                   .bodySmall,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     templeItem?.draft == false
//                                         ? Padding(
//                                             padding: EdgeInsets.only(top: 5.sp),
//                                             child: InkWell(
//                                               onTap: () {
//                                                 showModalBottomSheet(
//                                                   shape: RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.only(
//                                                               topLeft: Radius
//                                                                   .circular(
//                                                                       20.r),
//                                                               topRight: Radius
//                                                                   .circular(
//                                                                       20.r))),
//                                                   context: context,
//                                                   builder: (context) {
//                                                     return ViewEditBottomsheet(
//                                                       viewTap: () {
//                                                         Navigator.pop(context);
//                                                         AppRouter.push(
//                                                             '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/${'draft'}');
//                                                       },
//                                                       editTap: () {
//                                                         Navigator.pop(context);
//                                                         AppRouter.push(
//                                                             '/addTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/${'EditTemple'}/${0}');
//                                                       },
//                                                       deleteTap: () {
//                                                         Navigator.pop(context);
//                                                         showDialog(
//                                                             context: context,
//                                                             builder:
//                                                                 (BuildContext
//                                                                     context) {
//                                                               return AlertDialog(
//                                                                 title: Text(
//                                                                     StringConstant
//                                                                         .delete),
//                                                                 content: Text(
//                                                                     StringConstant
//                                                                         .areYouSureDelete),
//                                                                 actions: [
//                                                                   TextButton(
//                                                                     onPressed: () =>
//                                                                         Navigator.pop(
//                                                                             context),
//                                                                     child: Text(
//                                                                         StringConstant
//                                                                             .cancel),
//                                                                   ),
//                                                                   TextButton(
//                                                                     onPressed:
//                                                                         () {
//                                                                       Navigator.pop(
//                                                                           context);
//                                                                       context
//                                                                           .read<
//                                                                               ContributeTempleCubit>()
//                                                                           .deleteItem(
//                                                                               'Devalay',
//                                                                               '${templeItem?.id.toString()}');
//                                                                       context
//                                                                           .read<
//                                                                               ContributeTempleCubit>()
//                                                                           .sectionIndex = 0;
//                                                                       context
//                                                                           .read<
//                                                                               ContributeTempleCubit>()
//                                                                           .applyFilter(
//                                                                             newSectionIndex:
//                                                                                 0,
//                                                                             value:
//                                                                                 null,
//                                                                           );
//                                                                     },
//                                                                     child: Text(
//                                                                         StringConstant
//                                                                             .ok),
//                                                                   ),
//                                                                 ],
//                                                               );
//                                                             });
//                                                       },
//                                                     );
//                                                   },
//                                                 );
//                                               },
//                                               child:
//                                                   const Icon(Icons.more_vert),
//                                             ),
//                                           )
//                                         : const SizedBox.shrink(),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                     separatorBuilder: (context, index) {
//                       return Gap(10.h);
//                     },
//                   ),
//                 )
//               :Center(
//                   child: Text(
//                     StringConstant.noDataAvailable,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 );
//         }
//         return const Center(child: CustomLottieLoader());
//       },
//     );
//   }
// }
class DraftTempleWidget extends StatefulWidget {
  const DraftTempleWidget({super.key});

  @override
  State<DraftTempleWidget> createState() => _DraftTempleWidgetState();
}

class _DraftTempleWidgetState extends State<DraftTempleWidget> {
  late ContributeTempleCubit contributeTempleCubit;
  final scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    contributeTempleCubit = context.read<ContributeTempleCubit>();
    
       context.read<ContributeTempleCubit>().sectionIndex = 0;
    context.read<ContributeTempleCubit>().applyFilter(
          newSectionIndex: 0,
          value: null,
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
        draftVal: 'true', // Keep the same filter for draft temples
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

  void _refreshData() {
    contributeTempleCubit.sectionIndex = 0;
    contributeTempleCubit.fetchContributeTempleData(
      draftVal: 'true',
      loadMoreData: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributeTempleCubit, ContributeTempleState>(
      listener: (context, state) {
        if (state is ContributeTempleLoaded) {
          debugPrint('Draft temple list length: ${state.templeList?.length}');
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
          // Handle permission denied
          if (state.isPermissionDenied) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: const Color(0xffFF4C02),
                        size: 24.sp,
                      ),
                      Gap(8.w),
                      Text(
                        'Permission Denied',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    '${StringConstant.youdonot} puja.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Go back
                        Navigator.of(context).pop(); // Go back again
                        _refreshData();
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: AppColor.appbarBgColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          }

          // Show loading indicator only for initial load when list is empty
          if (state.loadingState && (state.templeList?.isEmpty ?? true)) {
            return const Center(child: CustomLottieLoader());
          }

          // Additional loading check for templeId
          if (state.templeId?.isEmpty ?? false) {
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
          if (state.templeList == null || state.templeList!.isEmpty) {
            return Center(
              child: Text(
                StringConstant.noDataAvailable,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          // Main content with infinite scroll
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              controller: scrollController,
              itemCount: state.templeList!.length + (isLoadingMore || (state.loadingState && state.templeList!.isNotEmpty) ? 1 : 0),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // Show loading indicator at the end
                if (index == state.templeList!.length) {
                  return Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final templeItem = state.templeList?[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff132c4a).withOpacity(0.04),
                        offset: const Offset(0, 7),
                        blurRadius: 5,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Draft warning banner
                      templeItem?.draft == true
                          ? Container(
                              height: 30.h,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColor.lightTextColor
                                    : const Color(0xffFFE8EB),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.r),
                                  topRight: Radius.circular(10.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.sp),
                                    child: const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xffFF4C02),
                                    ),
                                  ),
                                  Text(
                                    StringConstant.pleaseCompleteAll,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: const Color(0xffFF4C02),
                                        ),
                                  ),
                                  InkWell(
                                    onTap: () => _showOptionsBottomSheet(context, templeItem),
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: Color(0xffFF4C02),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      
                      // Main content
                      InkWell(
                        onTap: () {
                          AppRouter.push(
                            '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/draft',
                          );
                        },
                        child: AspectRatio(
                          aspectRatio: 4 / 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 4.sp / 3.sp,
                                child: CustomCacheImage(
                                  imageUrl: templeItem?.images?.banner?.isNotEmpty == true
                                      ? templeItem?.images!.banner![0].image ?? ''
                                      : StringConstant.defaultImage,
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 5.sp,
                                    bottom: 5.sp,
                                    left: 5.sp,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        templeItem?.title ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        "${templeItem?.city ?? ''},${templeItem?.state ?? ''}",
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        'initiated ${HelperClass().formatDate(templeItem?.createdAt ?? '')}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Options menu for non-draft items
                              templeItem?.draft == false
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 5.sp),
                                      child: InkWell(
                                        onTap: () => _showOptionsBottomSheet(context, templeItem),
                                        child: const Icon(Icons.more_vert),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                // Don't add separator for loading indicator
                if (index == state.templeList!.length - 1 && 
                    (isLoadingMore || (state.loadingState && state.templeList!.isNotEmpty))) {
                  return const SizedBox.shrink();
                }
                return Gap(10.h);
              },
            ),
          );
        }
        return const Center(child: CustomLottieLoader());
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext context, dynamic templeItem) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      context: context,
      builder: (context) {
        return ViewEditBottomsheet(
          viewTap: () {
            Navigator.pop(context);
            AppRouter.push(
              '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/draft',
            );
          },
          editTap: () {
            Navigator.pop(context);
            AppRouter.push(
              '/addTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/EditTemple/0',
            );
          },
          deleteTap: () {
            Navigator.pop(context);
            _showDeleteDialog(context, templeItem);
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic templeItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StringConstant.delete),
          content: Text(StringConstant.areYouSureDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(StringConstant.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                contributeTempleCubit.deleteItem(
                  'Devalay',
                  '${templeItem?.id.toString()}',
                );
                _refreshData();
              },
              child: Text(StringConstant.ok),
            ),
          ],
        );
      },
    );
  }
}