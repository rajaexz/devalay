import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/dashboard/widget/item_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
class Submitted extends StatefulWidget {
  const Submitted({super.key});

  @override
  State<Submitted> createState() => _SubmittedState();
}

class _SubmittedState extends State<Submitted> {
  late ContributeTempleCubit contributeTempleCubit;

  @override
  void initState() {
    super.initState();
    contributeTempleCubit = context.read<ContributeTempleCubit>();
    context.read<ContributeTempleCubit>().sectionIndex = 1;
    context.read<ContributeTempleCubit>().applyFilter(
          newSectionIndex: 1,
          value: null,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
      builder: (context, state) {
        if (state is ContributeTempleLoaded) {
          if (state.loadingState) {
            return const Center(child: CustomLottieLoader());
          }

          // Handle no data case
          if (state.templeList == null || state.templeList!.isEmpty) {

                
                  return RefreshIndicator(
              onRefresh: () async {
        contributeTempleCubit.applyFilter(
      newSectionIndex: 1,
      value: null,
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
              await contributeTempleCubit.applyFilter(
                newSectionIndex: 1,
                value: null,
              );
            },
            child: ListView.separated(
              itemCount: state.templeList?.length ?? 0,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final templeItem = state.templeList?[index];
                return ItemCart(
                  onTap: () {
                    AppRouter.push(
                      '/viewTemple/${templeItem?.id.toString()}/${templeItem?.governedBy?.id.toString()}/draft',
                    );
                  },
                    whisType: WhichType.submitted,
                    isDraft: templeItem?.draft == true,
                    title: templeItem?.title ?? '',
                    imageUrl: templeItem?.images?.banner?.isNotEmpty == true
                        ? templeItem?.images!.banner![0].image ??
                            StringConstant.defaultImage
                        : StringConstant.defaultImage,
                    progress: 0.5,
                    lastEdited:
                        ' Submitted on ${HelperClass().formatDate(templeItem?.updatedAt ?? '')}',
                    contributeCubit: contributeTempleCubit,
                    type: ContributionType.temple,
                    id: templeItem?.id.toString() ?? '',
                );
              },
              separatorBuilder: (context, index) {
                return Gap(10.h);
              },
            ),
          );
        }
        return const Center(child: CustomLottieLoader());
      },
    );
  }
}