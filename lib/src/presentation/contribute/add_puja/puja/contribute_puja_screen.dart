import 'package:devalay_app/src/application/contribution/contribution_puja/contribution_puja_cubit.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/filter/contribute_puja_filter.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/puja/review_puja_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_puja/puja/under_review_puja_widget.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/shared_preference.dart';
import '../../../core/utils/colors.dart';
import 'add_puja_widget.dart';
import 'approved_puja_widget.dart';
import 'draft_puja_widget.dart';
import 'monitor_puja_widget.dart';

class ContributePujaScreen extends StatefulWidget {
  const ContributePujaScreen({super.key});

  @override
  State<ContributePujaScreen> createState() => _ContributePujaScreenState();
}

class _ContributePujaScreenState extends State<ContributePujaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late ContributePujaCubit contributePujaCubit;

  String? admin;
  bool isAdminLoaded = false;

  @override
  void initState() {
      contributePujaCubit = context.read<ContributePujaCubit>();
    super.initState();
    getAdmin();
  }

  Future<void> getAdmin() async {
    admin = await PrefManager.getAdmin();

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    setState(() {
      isAdminLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdminLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Scaffold(
       
        body: Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/background/explore_bg.jpg'),
                    fit: BoxFit.cover),
              ),
              child: SafeArea(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.sp, vertical: 20.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back,
                                color: AppColor.whiteColor)),
                        Row(
                          children: [
                      
                            Gap(16.w),
                            InkWell(
                                   onTap: () {
                                  _showFilterBottomSheet();
                                },
                                child: const Icon(Icons.tune,
                                    color: AppColor.whiteColor))
                          ],
                        )
                      ],
                    ),
                  ),
                  TabBar(
                      controller: _tabController,
                      dividerColor: const Color(0xff000000).withOpacity(0.11),
                      indicatorColor: AppColor.whiteColor,
                      indicator: UnderlineTabIndicator(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4.r),
                            topLeft: Radius.circular(4.r)),
                        borderSide: BorderSide(
                            width: 3.w, color: AppColor.whiteColor),
                        insets: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      labelStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColor.whiteColor),
                      unselectedLabelStyle:
                          Theme.of(context).textTheme.bodyMedium,
                      unselectedLabelColor: AppColor.whiteColor,
                      tabs: admin == 'true'
                          ?  [
                       Tab(text: StringConstant.tabAdd),
                         Tab(text: StringConstant.monitor),
                            Tab(text: StringConstant.tabReview),
                            ]
                          :  [
                              Tab(text: StringConstant.tabDraft),
                              Tab(text:StringConstant.tabUnderReview),
                              Tab(text:StringConstant.approved),
                            ]),
                ],
              )),
            ),
            Expanded(
              child: TabBarView(
                  controller: _tabController,
                  children: admin == 'true'
                      ? const [
                          AddPujaWidget(),
                          MonitorPujaWidget(),
                          ReviewPujaWidget()
                        ]
                      : const [
                          DraftPujaWidget(),
                          UnderReviewPujaWidget(),
                          ApprovedPujaWidget()
                        ]),
            )
          ],
        ),
      ),
    );
  }

    void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) => BlocProvider.value(
        value: contributePujaCubit,
        child: const ContributePujaFilterWidget(),
      ),
    );
  }

}
