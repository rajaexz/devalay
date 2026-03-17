import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/dashboard/widget/item_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ManageTemple extends StatefulWidget {
  const ManageTemple({super.key});

  @override
  State<ManageTemple> createState() => _ManageTempleState();
}

class _ManageTempleState extends State<ManageTemple> {
  late ContributeTempleCubit contributeTempleCubit;
  final scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    contributeTempleCubit = context.read<ContributeTempleCubit>();
    contributeTempleCubit.sectionIndex = 5;
    contributeTempleCubit.applyFilter(
          newSectionIndex: 5,
          value: 'false',
        );
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    // Check if we've reached the bottom and we're not already loading more data
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && 
        !isLoadingMore && 
        contributeTempleCubit.hasMoreData &&
        !contributeTempleCubit.isClosed) {
      
      setState(() {
        isLoadingMore = true;
      });
      
      // Load more data with the same filter parameters
      if (!contributeTempleCubit.isClosed) {
        contributeTempleCubit.fetchContributeTempleData(
          value: 'false', // Keep the same filter for manage temples
          loadMoreData: true,
        ).then((_) {
          if (mounted && !contributeTempleCubit.isClosed) {
            setState(() {
              isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void _refreshData() {
    if (!contributeTempleCubit.isClosed) {
      contributeTempleCubit.sectionIndex = 5;
      contributeTempleCubit.fetchContributeTempleData(
        value: 'false',
        loadMoreData: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributeTempleCubit, ContributeTempleState>(
      listener: (context, state) {
        if (state is ContributeTempleLoaded && mounted) {
          debugPrint('Manage temple list length: ${state.templeList?.length}');
          // Reset loading state when data is loaded
          if (isLoadingMore) {
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
              if (mounted) {
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
                      '${StringConstant.youdonot} manage temples.',
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
              }
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
                'No temples to manage',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          // Main content with infinite scroll using ItemCart
          return ListView.separated(
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
              return ItemCart(
                onTap: () {
                  AppRouter.push(
                    '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/draft',
                  );
                },
                  whisType: WhichType.manage,
                  isDraft: templeItem?.draft == true,
                  title: templeItem?.title ?? '',
                  imageUrl: templeItem?.images?.banner?.isNotEmpty == true
                      ? templeItem?.images!.banner![0].image ??
                          StringConstant.defaultImage
                      : StringConstant.defaultImage,
                  progress: 0.5,
                  lastEdited:
                      'Initiated ${HelperClass().formatDate(templeItem?.createdAt ?? '')}',
                  contributeCubit: contributeTempleCubit,
                  type: ContributionType.temple,
                  id: templeItem?.id.toString() ?? '',
                  governedById: templeItem?.governedBy?.id.toString(),
                  onItemDeleted: () {
                    _refreshData();
                  },
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
          );
        }
        return const Center(child: CustomLottieLoader());
      },
    );
  }
}
