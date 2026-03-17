import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/job_new_view.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/job_delivered_view.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/job_pending_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class JobViewStatus extends StatefulWidget {
  const JobViewStatus({super.key});

  @override
  State<JobViewStatus> createState() => _JobViewStatusState();
}

class _JobViewStatusState extends State<JobViewStatus>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;
  
  // State persistence key
  static const String _selectedJobChipKey = 'job_selected_chip';

  // Figma design colors
  static const Color _selectedChipBgColor = Color(0xFFFEE8E0);
  static const Color _selectedChipBorderColor = Color(0xFFDDDDDD);
  static const Color _unselectedChipBorderColor = Color(0xFFDDDDDD);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSavedChipState();
  }

  Future<void> _loadSavedChipState() async {
    final savedChip = await PrefManager.getInt(_selectedJobChipKey);
    if (savedChip != null && savedChip < 3) {
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
    super.build(context);

    // Figma design: New, Processing, Delivered (3 chips)
    final List<String> tabTitles = [
            StringConstant.tabNew,
              StringConstant.processing,
      StringConstant.delivered,
    ];

    return Column(
      children: [
        Gap(10.h),
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            clipBehavior: Clip.antiAlias,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            itemCount: tabTitles.length,
            itemBuilder: (context, index) {
              return _buildChipTab(tabTitles[index], index);
            },
          ),
        ),
        Expanded(child: _getSelectedWidget(selectedIndex)),
      ],
    );
  }

  Widget _buildChipTab(String label, int index) {
    final bool isSelected = selectedIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: GestureDetector(
        onTap: () {
          setState(() => selectedIndex = index);
          _saveChipState();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isSelected ? _selectedChipBgColor : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected
                  ? _selectedChipBorderColor
                  : _unselectedChipBorderColor,
              width: 0.787,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFF241601),
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return const JobNewView();
      case 1:
        return const JobPendingView();
      case 2:
        return const JobDeliveredView();
      default:
        return Center(child: Text(StringConstant.noDataAvailable));
    }
  }
}
