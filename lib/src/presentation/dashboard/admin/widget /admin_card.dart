// admin_card.dart - Updated with navigation

import 'package:devalay_app/src/data/model/kirti/admin_card_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/widget%20/admin_order_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AdminOrderCard extends StatelessWidget {
  final AdminOrderResponseModel? order;

  const AdminOrderCard({
    super.key,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(order?.status);
    
    // Format date: "26 jun 2025"
    String formattedDate = 'N/A';
    if (order?.createdAt != null) {
      try {
        final date = DateTime.parse(order!.createdAt!);
        final months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 
                       'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
        formattedDate = '${date.day} ${months[date.month - 1]} ${date.year}';
      } catch (e) {
        formattedDate = HelperClass().formatDate(order!.createdAt.toString());
      }
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x2E3C3C43)), // rgba(60,60,67,0.18)
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID ORD${order?.id ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xD9555151), // rgba(85,81,81,0.85)
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xD9555151), // rgba(85,81,81,0.85)
                  ),
                ),
              ],
            ),
            Gap(10.h),
            // Image and Service Details Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.r),
                  child: CustomCacheImage(
                    imageUrl: order?.serviceSection?.images ?? '',
                    width: 103.714.w,
                    height: 78.h,
                  ),
                ),
                Gap(12.w),
                // Service Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order?.serviceSection?.name ?? StringConstant.notAvailable,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF14191E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(6.h),
                      Text(
                        'Plan Name: ${order?.plan?.type ?? StringConstant.notAvailable}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xD9555151), // rgba(85,81,81,0.85)
                        ),
                      ),
                      Gap(6.h),
                      Text(
                        'Total Amount: ${order?.totalAmount?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xD9555151), // rgba(85,81,81,0.85)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(10.h),
            // Status and View Details Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF555151),
                    ),
                    children: [
                      const TextSpan(text: 'Status- '),
                      TextSpan(
                        text: statusData["text"] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: statusData["color"] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
                // View Details Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (order != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminOrderDetailsScreen(
                              orderId: order!.id.toString(),
                              status: order!.status ?? 'Pending',
                            ),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 3.h),
                      minimumSize: Size(106.w, 35.h),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF0B0B0B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusData(String? status) {
    if (status == null) {
      return {
        'text': StringConstant.unknown,
        'color': Colors.grey,
      };
    }

    switch (status) {
      case 'Pending':
        return {
          'text': StringConstant.pending,
          'color': Colors.orange,
        };
      case 'Order Placed':
        return {
          'text': StringConstant.orderPlaced,
          'color': Colors.blue,
        };
      case 'Order Confirmed':
        return {
          'text': StringConstant.confirmed,
          'color': Colors.blue,
        };
      case 'Prepration Completed':
        return {
          'text': StringConstant.preparationDone,
          'color': Colors.purple,
        };
      case 'Order in Execution':
        return {
          'text': StringConstant.processing,
          'color': Colors.indigo,
        };
      case 'Order Completed':
        return {
          'text': StringConstant.completed,
          'color': Colors.green,
        };
      case 'Cancelled by User':
      case 'Cancelled by Company':
      case 'Cancelled by Pandit':
        return {
          'text': StringConstant.cancelled,
          'color': Colors.red,
        };
      default:
        return {
          'text': status,
          'color': Colors.grey,
        };
    }
  }
}