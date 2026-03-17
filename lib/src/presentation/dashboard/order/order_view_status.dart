
import 'package:devalay_app/src/application/contribution/contribution_dev/contribution_dev_cubit.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/dashboard/order/order_completed_view.dart';
import 'package:devalay_app/src/presentation/dashboard/order/order_processing_view.dart';
import 'package:devalay_app/src/presentation/dashboard/order/order_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';


class OrderViewStatus extends StatefulWidget {
  const OrderViewStatus({super.key});

  @override
  State<OrderViewStatus> createState() => _OrderViewStatusState();
}

class _OrderViewStatusState extends State<OrderViewStatus>
    with AutomaticKeepAliveClientMixin {
 
  int selectedIndex = 0;
  String? admin;
  late ContributeDevCubit contributeDevCubit;
  
  // State persistence key
  static const String _selectedOrderChipKey = 'order_selected_chip';

  @override
  bool get wantKeepAlive => true; // This prevents the widget from being disposed

  @override
  void initState() {
    super.initState();
    contributeDevCubit = ContributeDevCubit();
    _loadSavedChipState();
  }

  Future<void> _loadSavedChipState() async {
    final savedChip = await PrefManager.getInt(_selectedOrderChipKey);
    if (savedChip != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedIndex = savedChip;
        });
      });
    }
  }

  Future<void> _saveChipState() async {
    await PrefManager.setInt(_selectedOrderChipKey, selectedIndex);
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
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF241601),
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFFFFDED3), // Figma: #FFDED3
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFFFFDED3)
                  : const Color(0xFFDDDDDD), // Figma: #DDD
              width: 0.787,
            ),
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)), // Figma: 10px
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (_) {
              setState(() => selectedIndex = index);
              _saveChipState();
            },
          ));
    }

    List<String> tabTitle =  [
            StringConstant.tabAll,
            StringConstant.processing,
            StringConstant.completed,

          ];
       
    Widget getSelectedWidget(int index) {
      switch (index) {
        case 0:
          return  const AllOrder();
        case 1:
          return const OrderProcessingView();
        case 2:
          return const OrderCompletedView();
      
        default:
          return  SizedBox(child: Text(StringConstant.noDataAvailable),);
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



