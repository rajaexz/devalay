import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/assigned_view.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/cancelled_view.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/completed_view.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/confirmed_view.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/new_order_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AdminAssignViewStatus extends StatefulWidget {
  const AdminAssignViewStatus({super.key});

  @override
  State<AdminAssignViewStatus> createState() => _AdminAssignViewStatusState();
}

class _AdminAssignViewStatusState extends State<AdminAssignViewStatus>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;

  // State persistence key
  static const String _selectedJobChipKey = 'job_selected_chip';

  @override
  bool get wantKeepAlive =>
      true; // This prevents the widget from being disposed

  @override
  void initState() {
    super.initState();

    _loadSavedChipState();
  }

  Future<void> _loadSavedChipState() async {
    final savedChip = await PrefManager.getInt(_selectedJobChipKey);
    if (savedChip != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedIndex = savedChip;
        });
      });
    }
  }

  Future<void> _saveChipState() async {
    await PrefManager.setInt(_selectedJobChipKey, selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    Widget buildChipTab(String label, int index) {
      final bool isSelected = selectedIndex == index;
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ChoiceChip(
            label: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(),
            ),
            selected: isSelected,
            selectedColor: AppColor.appbarBgColor2,
            side: BorderSide(
              color: isSelected
                  ? AppColor.appbarBgColor2
                  : AppColor.blackColor.withOpacity(0.1),
            ),
            backgroundColor: isSelected
                ? AppColor.appbarBgColor2.withOpacity(0.1)
                : AppColor.whiteColor,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r)),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (_) {
              setState(() => selectedIndex = index);
              _saveChipState();
            },
          ));
    }

    // Top chip titles matching the design
    final List<String> tabTitle = [
      StringConstant.newOrder,
      StringConstant.assigned,
      StringConstant.confirmed,
      StringConstant.cancelled,
      StringConstant.completed,
    ];

    // Map selected index to the corresponding view
    Widget getSelectedWidget(int index) {
      switch (index) {
        case 0:
          return const NewOrderView();

        case 1:
          return const AssignedOrderView();

        case 2:
          return const ConfirmedView();

        case 3:
          return const CancelledView();

        case 4:
          return const CompletedOrderView();
        default:
          return const SizedBox();
      }
    }

    return Column(
      children: [
        Gap(10.h),
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            clipBehavior: Clip.antiAlias,
            scrollDirection: Axis.horizontal,
            itemCount: tabTitle.length,
            itemBuilder: (context, index) {
              return buildChipTab(tabTitle[index], index);
            },
          ),
        ),
        Expanded(child: getSelectedWidget(selectedIndex))
      ],
    );
  }
}

