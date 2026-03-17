import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class ShortListFilterWidget extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final Function(String?) onItemSelected;

  const ShortListFilterWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem == item;
        return InkWell(
          onTap: () => onItemSelected(isSelected ? null : item),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.done_all : Icons.done,
                color: isSelected ? accentColor : AppColor.lightTextColor,
                size: 18.sp,
              ),
              Gap(10.w),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => Gap(10.h),
    );
  }
}

class OrderListFilterWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String? selectedItem;
  final Function(String?) onItemSelected;

  const OrderListFilterWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isOrderBySelected = selectedItem == item;
              return InkWell(
                onTap: () {
                  print('Selected index order by: ${item['title']}');
                  onItemSelected(isOrderBySelected ? null : item['title']);
                },
                child: Row(
                  children: [
                    SvgPicture.network(item['icon'],
                        color: isOrderBySelected
                            ? accentColor
                            : AppColor.lightTextColor,
                        height: 16.h,
                        width: 16.w),
                    Gap(10.w),
                    Expanded(
                        child: Text(item['title'],
                            style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Gap(10.h);
            },
          )
        ],
      ),
    );
  }
}
