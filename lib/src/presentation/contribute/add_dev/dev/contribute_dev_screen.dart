import 'package:devalay_app/src/presentation/contribute/add_dev/dev/review_dev_widget.dart';
import 'package:devalay_app/src/presentation/contribute/add_dev/dev/under_review_dev_widget.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/shared_preference.dart';
import '../../../core/utils/colors.dart';
import 'add_dev_widget.dart';
import 'approved_dev_widget.dart';
import 'draft_dev_widget.dart';
import 'monitor_dev_widge.dart';

class ContributeDevScreen extends StatefulWidget {
  const ContributeDevScreen({super.key});

  @override
  State<ContributeDevScreen> createState() => _ContributeDevScreenState();
}

class _ContributeDevScreenState extends State<ContributeDevScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? admin;
  bool isAdminLoaded = false;

  @override
  void initState() {
    super.initState();
    getAdmin();
  }

  Future<void> getAdmin() async {
    admin = await PrefManager.getAdmin();
    final isAdmin = admin == 'true';
    _tabController =
        TabController(length: isAdmin ? 3 : 3, vsync: this, initialIndex: 0);

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
                              Tab(text: StringConstant.tabReview),
                            ]
                          : [
                              Tab(text: StringConstant.tabDraft),
                              Tab(text: StringConstant.tabUnderReview),
                              Tab(text: StringConstant.approved),
                            ]),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                children: admin == 'true'
                    ? const [
                        AddDevWidget(),
                        MonitorDevWidge(),
                        ReviewDevWidget()
                      ]
                    : const [
                        DraftDevWidget(),
                        UnderReviewDevWidget(),
                        ApprovedDevWidget()
                      ]),
          )
        ],
      )),
    );
  }
}
