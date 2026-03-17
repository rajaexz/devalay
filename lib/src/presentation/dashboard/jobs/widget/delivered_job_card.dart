import 'package:devalay_app/src/data/model/job/job_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/job_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Delivered Job Card - Figma Design
/// Shows completed checkmark + "Delivered" status with Details button
class DeliveredJobCard extends StatelessWidget {
  final JobModel? job;

  const DeliveredJobCard({
    super.key,
    this.job,
  });

  @override
  Widget build(BuildContext context) {
    if (job == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: const Color(0x2E3C3C43), // rgba(60,60,67,0.18)
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Order ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${StringConstant.orderId} ${job!.displayJobId}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  HelperClass.formatDate2(
                      DateTime.tryParse(job!.createdAt ?? '') ??
                          DateTime.now()),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Job Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CustomCacheImage(
                    imageUrl: job!.orderImages,
                    borderRadius: BorderRadius.circular(8.r),
                    width: 90.w,
                    height: 90.h,
                  ),
                ),
                SizedBox(width: 12.w),

                // Job Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job!.displayTitle,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      _buildInfoRow(
                        '${StringConstant.planName}:',
                        job!.planType ?? 'Basic',
                      ),
                      SizedBox(height: 4.h),
                      _buildInfoRow(
                        '${StringConstant.totalAmount}:',
                        job!.displayPrice,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            
            // Delivered status and Details button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delivered status with checkmark icon
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16.sp,
                      color: const Color(0xFF12B76A), // Green
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      StringConstant.delivered,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF12B76A),
                      ),
                    ),
                  ],
                ),
                
                // Details button
                GestureDetector(
                  onTap: () => _navigateToDetails(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(color: const Color(0xFFD9D9D9)),
                    ),
                    child: Text(
                      StringConstant.details,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            JobDetailsScreen(jobId: job!.jobId ?? job!.id.toString()),
      ),
    );
  }
}

