import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_cubit.dart';
import 'package:devalay_app/src/application/contribution/contribution_temple/contribution_temple_state.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/dashboard/widget/item_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class Approved extends StatefulWidget {
  const Approved({super.key});

  @override
  State<Approved> createState() => _ApprovedState();
}

class _ApprovedState extends State<Approved> {
  late ContributeTempleCubit contributeTempleCubit;

  @override
  void initState() {
    super.initState();
    contributeTempleCubit = ContributeTempleCubit();
    _fetchData();
  }

  void _fetchData() {
    contributeTempleCubit.fetchContributeTempleData(
      approvedVal: 'true', 
      loadMoreData: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: contributeTempleCubit,
      child: BlocBuilder<ContributeTempleCubit, ContributeTempleState>(
        builder: (context, state) {
          if (state is ContributeTempleLoaded && state.loadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ContributeTempleError) {
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

          if (state is ContributeTempleLoaded) {
            if (state.templeList?.isEmpty ?? true) {
              return RefreshIndicator(
                onRefresh: () async {
                  _fetchData();
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
                _fetchData();
              },
              child: ListView.separated(
              itemCount: state.templeList?.length ?? 0,
              separatorBuilder: (context, index) => Gap(10.h),
                physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final temple = state.templeList?[index];
                return ItemCart(
                  onTap: () {
                    AppRouter.push("/singleDevalay/${temple?.id.toString()}");
                    // AppRouter.push(
                    //   '/viewTemple/${temple?.id.toString()}/${temple?.governedBy?.id.toString()}/draft',
                    // );
                  },
                    screen: 'Approved',
                    whisType: WhichType.approved,
                    isDraft: temple?.draft == true,
                    title: temple?.title ?? '',
                    imageUrl: temple?.images?.banner?.isNotEmpty == true
                        ? temple?.images!.banner![0].image ?? StringConstant.defaultImage
                        : StringConstant.defaultImage,
                    progress: 0.5,
                    lastEdited: 'Approved on ${HelperClass().formatDate(temple?.updatedAt ?? '')}',
                    contributeCubit: contributeTempleCubit,
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
    contributeTempleCubit.close();
    super.dispose();
  }
}
