import 'package:devalay_app/src/data/model/kirti/order_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/dashboard/order/orderDetails/order_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderCard extends StatelessWidget {
  final OrderModel? order;

  const OrderCard({
    super.key,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(order?.status);
    final isCancelled = order?.status?.contains('Cancelled') ?? false;
    
    // Calculate total amount
    final planPrice = order?.plan?.price ?? 0.0;
    final addOnsTotal = order?.addOns?.fold<double>(
      0.0,
      (sum, addon) => sum + (addon.price ?? 0.0),
    ) ?? 0.0;
    final taxAmount = order?.tax ?? 0.0;
    final totalAmount = planPrice + addOnsTotal + taxAmount;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 7.h, bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF3C3C43).withOpacity(0.18),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID + Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID ORD${order?.id ?? order?.orderId ?? StringConstant.notAvailable}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF555151).withOpacity(0.85),
                  height: 1.4,
                ),
              ),
              Text(
                order?.createdAt != null
                    ? HelperClass().formatDate(order!.createdAt.toString())
                    : StringConstant.notAvailable,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF555151).withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          
          // Image + Details Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: CustomCacheImage(
                  imageUrl: order?.serviceSection?.images ?? order?.imageUrl ?? '',
                  width: 103.714.w,
                  height: 78.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              
              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name
                    Text(
                      order?.serviceSection?.name ?? order?.title ?? 'Satyanarayan Katha',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF14191E),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    
                    // Plan Name
                    Text(
                      'Plan Name: ${order?.plan?.type ?? 'Basic'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF555151).withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    
                    // Total Amount
                    Text(
                      'Total Amount: ${totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF555151).withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          
          // Status + Details Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status with Icon (matching Figma design)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getStatusIcon(order?.status),
                  SizedBox(width: 7.w),
                  Text(
                    _getStatusText(order?.status),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: statusData["color"],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              
              // Details / Re-order Button
              GestureDetector(
                onTap: () {
                  if (isCancelled) {
                    // Re-order logic
                    // TODO: Implement re-order functionality
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(
                            orderId: order!.id.toString()),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 17.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFD9D9D9),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    isCancelled ? StringConstant.reorder : StringConstant.details,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0B0B0B),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
    case 'Order Placed':
    case 'Order Confirmed':
    case 'Prepration Completed':
    case 'Order in Execution':
      // All processing states - Orange (#FF9500)
      return {
        'text': StringConstant.processing,
        'color': const Color(0xFFFF9500),
      };
    case 'Order Completed':
      // Completed - Green (#12B76A)
      return {
        'text': StringConstant.completed,
        'color': const Color(0xFF12B76A),
      };
    case 'Cancelled by User':
    case 'Cancelled by Company':
    case 'Cancelled by Pandit':
      // Cancelled - Red (#FF4704)
      return {
        'text': StringConstant.cancelled,
        'color': const Color(0xFFFF4704),
      };
    default:
      return {
        'text': status,
        'color': Colors.grey,
      };
  }
}

String _getStatusText(String? status) {
  if (status == null) return StringConstant.unknown;

  switch (status) {
    case 'Pending':
      return StringConstant.pending;
    case 'Order Placed':
      return StringConstant.orderPlaced;
    case 'Order Confirmed':
      return StringConstant.confirmed;
    case 'Prepration Completed':
      return StringConstant.preparationDone;
    case 'Order in Execution':
      return StringConstant.processing;
    case 'Order Completed':
      return StringConstant.completed;
    case 'Cancelled by User':
    case 'Cancelled by Company':
    case 'Cancelled by Pandit':
      return StringConstant.cancelled;
    default:
      return status;
  }
}

Widget _getStatusIcon(String? status) {
  const double iconSize = 16.667;
  
  if (status == null) {
    return Icon(
      Icons.help_outline,
      color: Colors.grey,
      size: iconSize.sp,
    );
  }

  switch (status) {
    case 'Pending':
    case 'Order Placed':
    case 'Order Confirmed':
    case 'Prepration Completed':
    case 'Order in Execution':
      // Processing states - Clock icon (orange)
      return Icon(
        Icons.access_time,
        color: const Color(0xFFFF9500),
        size: iconSize.sp,
      );
    case 'Order Completed':
      // Completed - Checkmark (green)
      return Icon(
        Icons.check_circle,
        color: const Color(0xFF12B76A),
        size: iconSize.sp,
      );
    case 'Cancelled by User':
    case 'Cancelled by Company':
    case 'Cancelled by Pandit':
      // Cancelled - Cross (red)
      return Icon(
        Icons.close,
        color: const Color(0xFFFF4704),
        size: iconSize.sp,
      );
    default:
      return Icon(
        Icons.help_outline,
        color: Colors.grey,
        size: iconSize.sp,
      );
  }
}}

