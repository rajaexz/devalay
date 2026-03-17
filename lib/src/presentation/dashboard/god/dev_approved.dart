import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/dashboard/widget/item_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class DevApproved extends StatefulWidget {
  const DevApproved({super.key});

  @override
  State<DevApproved> createState() => _DevApprovedState();
}

class _DevApprovedState extends State<DevApproved> {
  late ContributeDevCubit contributeDevCubit;
  
  @override
  void initState() {
    super.initState();
    contributeDevCubit = ContributeDevCubit();
    _fetchData();
  }

  void _fetchData() {
    contributeDevCubit.fetchContributeDevData(
      approvedVal: 'true', 
      loadMoreData: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: contributeDevCubit,
      child: BlocBuilder<ContributeDevCubit, ContributeDevState>(
        builder: (context, state) {
          if (state is ContributeDevLoaded && state.loadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ContributeDevError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ContributeDevLoaded) {
            if (state.model?.isEmpty ?? true) {
              return RefreshIndicator(
                onRefresh: () async {
                  await contributeDevCubit.fetchContributeDevData(
                    approvedVal: 'true',
                    loadMoreData: false,
                  );
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                child: Text('No approved temples found'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await contributeDevCubit.fetchContributeDevData(
                  approvedVal: 'true',
                  loadMoreData: false,
                );
              },
              child: ListView.separated(
              itemCount: state.model?.length ?? 0,
              separatorBuilder: (context, index) => Gap(10.h),
                physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final temple = state.model?[index];
                return ItemCart(
                  onTap: () {
                    AppRouter.push("/singleGod/${temple?.id.toString()}");
                  },
                    isDraft: temple?.draft == true,
                    title: temple?.title ?? '',
                    imageUrl: temple?.images?.banner?.isNotEmpty == true
                        ? temple?.images!.banner![0].image ?? StringConstant.defaultImage
                        : StringConstant.defaultImage,
                    progress: 0.5,
                    lastEdited: 'initiated ${HelperClass().formatDate(temple?.createdAt ?? '')}',
                    contributeCubit: contributeDevCubit,
                    type: ContributionType.temple,
                    id: temple?.id.toString() ?? '',
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
    contributeDevCubit.close();
    super.dispose();
  }
}