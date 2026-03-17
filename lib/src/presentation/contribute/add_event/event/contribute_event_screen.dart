import 'package:devalay_app/src/application/contribution/contribution_event/contribution_event_cubit.dart';
import 'package:devalay_app/src/presentation/contribute/add_event/event/review_event_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_event/filter/event_filter.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/shared_preference.dart';
import '../../../core/utils/colors.dart';
import 'add_event_widget.dart';
import 'monitor_event_widget.dart';

class ContributeEventScreen extends StatefulWidget {
  const ContributeEventScreen({super.key});

  @override
  State<ContributeEventScreen> createState() => _ContributeEventScreenState();
}

class _ContributeEventScreenState extends State<ContributeEventScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? admin;
  bool isAdminLoaded = false;
  late ContributeEventCubit contributeEventCubit;
  @override
  void initState() {
    contributeEventCubit = context.read<ContributeEventCubit>();
    super.initState();
    getAdmin();
  }

  Future<void> getAdmin() async {
    admin = await PrefManager.getAdmin();
    final isAdmin = admin == 'true';

    _tabController =
        TabController(length: isAdmin ? 3 : 2, vsync: this, initialIndex: 0);

    setState(() {
      isAdminLoaded = true;
    });
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
        value: contributeEventCubit,
        child: const ContributeEventFilterWidget(),
      ),
    );
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.sp, vertical: 20.sp),
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
                        borderSide:
                            BorderSide(width: 3.w, color: AppColor.whiteColor),
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
                          ? [
                              Tab(text: StringConstant.tabAdd),
                              Tab(text: StringConstant.monitor),
                              Tab(text: StringConstant.tabReview)
                            ]
                          : [
                              Tab(text: StringConstant.tabAdd),
                              Tab(text: StringConstant.monitor),
                            ]),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: admin == 'true'
                  ? [
                      const AddEventWidget(),
                      const MonitorEventWidget(),
                      const ReviewEventWidget(),
                    ]
                  : [
                      const AddEventWidget(),
                      const MonitorEventWidget(),
                    ],
            ),
          ),
        ],
      )),
    );
  }
}
