import 'package:devalay_app/src/data/model/kirti/order_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/widget /assigned_job_details_screen.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/widget /completed_job_details_screen.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/widget /confirmed_job_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssignedOrderCard extends StatelessWidget {
  final OrderModel? order;

  const AssignedOrderCard({
    super.key,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> statusData = _getStatusData(order?.status);

    // Calculate total amount from plan + add‑ons if available
    double planPrice = order?.plan?.price ?? 0.0;
    double addOnsTotal = 0.0;
    if (order?.addOns != null) {
      for (final addOn in order!.addOns!) {
        addOnsTotal += addOn.price ?? 0.0;
      }
    }
    final double totalAmount = planPrice + addOnsTotal;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      
   
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Order ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID ${order?.id ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColor.greyColor.withOpacity(.7),
                      ),
                ),
                Text(
                  order?.createdAt != null
                      ? HelperClass().formatDate(order!.createdAt.toString())
                      : 'N/A',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CustomCacheImage(
                        imageUrl: order?.serviceSection?.images ?? '',
                        width: 120.w,
                        height: 90.h,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Status row
                    Row(
                      children: [
                        Text(
                          'Status - ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColor.greyColor,
                                  ),
                        ),
                        Text(
                          statusData['text'] as String,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: statusData['color'] as Color,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order?.serviceSection?.name ?? '',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Plan Name: ${order?.plan?.type ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColor.greyColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Amount: ₹${totalAmount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColor.greyColor,
                            ),
                      ),
                      const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                        
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFD9D9D9),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: CustomButton(
                            btnColor: AppColor.whiteColor,
                            mypadding: const EdgeInsets.symmetric(
                                horizontal: 17, vertical: 3),
                            onTap: () {
                              if (order?.id != null) {
                                final status = order?.status?.toLowerCase() ?? '';
                                final isCompleted = status == 'completed' || 
                                                    status == 'order completed';
                                final isConfirmed = status == 'confirmed' || 
                                                    status == 'order confirmed';
                                
                                Widget screen;
                                if (isCompleted) {
                                  screen = CompletedJobDetailsScreen(
                                    orderId: order!.id.toString(),
                                  );
                                } else if (isConfirmed) {
                                  screen = ConfirmedJobDetailsScreen(
                                    orderId: order!.id.toString(),
                                  );
                                } else {
                                  screen = AssignedJobDetailsScreen(
                                    orderId: order!.id.toString(),
                                  );
                                }
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => screen),
                                );
                              }
                            },
                            buttonAssets: '',
                            textButton: StringConstant.viewDetails,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                      ],
                    )
                    ],
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
        'text': 'Unknown',
        'color': Colors.grey,
      };
    }

    switch (status.toLowerCase()) {
      case 'assigned':
        return {
          'text': StringConstant.assigned,
          'color': Colors.orange,
        };
      case 'order cancelled':
      case 'cancelled':
        return {
          'text': StringConstant.cancelled,
          'color': Colors.red,
        };
      case 'order processing':
      case 'processing':
        return {
          'text': StringConstant.processing,
          'color': Colors.blue,
        };
      case 'order completed':
      case 'completed':
        return {
          'text': StringConstant.completed,
          'color': const Color(0xFF12B76A), // Green from Figma
        };
      default:
        return {
          'text': status,
          'color': Colors.grey,
        };
    }
  }
}
