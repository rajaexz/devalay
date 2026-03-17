import 'package:devalay_app/src/application/job/job_cubit.dart';
import 'package:devalay_app/src/data/model/job/job_model.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/job_details_screen.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/job_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobCard extends StatelessWidget {
  final JobModel? job;

  const JobCard({
    super.key,
    this.job,
  });

  @override
  Widget build(BuildContext context) {
    if (job == null) {
      return const SizedBox.shrink();
    }

    // Check if job is already assigned
    // 1. Check timeline remarks for "This pooja has already been assigned to another pandit"
    // 2. Check status (Job Assigned, Job Placed, Job Confirmed)
    final statusLower = job!.status?.toLowerCase() ?? '';
    final String alreadyAssignedRemark = "This pooja has already been assigned to another pandit";
    
    // Check timeline for the specific remark
    bool hasAlreadyAssignedRemark = false;
    if (job!.jobTimeline != null && job!.jobTimeline!.isNotEmpty) {
      hasAlreadyAssignedRemark = job!.jobTimeline!.any((timeline) => 
        timeline.remarks?.toLowerCase().contains(alreadyAssignedRemark.toLowerCase()) ?? false
      );
    }
    
    // Combine checks: timeline remark OR status-based check
    final bool isAlreadyAssigned = hasAlreadyAssignedRemark || (
        statusLower == 'job placed' || 
        statusLower == 'job confirmed' ||
        (statusLower == 'assigned' && job!.assignedTo != null && job!.assignedTo!.isNotEmpty));

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
                    imageUrl: job!.displayImageUrl,
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

            // Error message if already assigned (Figma design)
            if (isAlreadyAssigned) ...[
              
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2EE),
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(
                    color: const Color(0xFFFFE0D4),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  StringConstant.alreadyAssignedMessage,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    height: 1.4,
                  ),
                ),
              ),
            ],

            // Action Buttons
            SizedBox(height: 12.h),
            _buildActionButtons(context, isAlreadyAssigned),
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

  Widget _buildActionButtons(BuildContext context, bool isDisabled) {
    if (isDisabled) {
      // Show disabled buttons
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Text(
                  StringConstant.accept,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Text(
                  StringConstant.rejected,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToDetails(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                ),
                child: Center(
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
            ),
          ),
        ],
      );
    }

    if (job!.canAccept && job!.canReject) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showAcceptDialog(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF12B76A), // Figma green
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Center(
                  child: Text(
                    StringConstant.accept,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _showRejectDialog(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Center(
                  child: Text(
                    StringConstant.reject,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToDetails(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                ),
                child: Center(
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
            ),
          ),
        ],
      );
    } else if (job!.canComplete) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showCompleteDialog(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    StringConstant.complete,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToDetails(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                ),
                child: Center(
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
            ),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: () => _navigateToDetails(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(color: const Color(0xFFD9D9D9)),
          ),
          child: Center(
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
      );
    }
  }

  void _showAcceptDialog(BuildContext context) async {
    // Show the new Figma-styled accept dialog
    final result = await showOrderAcceptedDialog(context);
    if (result == true) {
      // Accept the job
      context.read<JobCubit>().acceptJob(job!.jobId ?? job!.id.toString());
    }
  }

  void _showRejectDialog(BuildContext context) async {
    // Show the new Figma-styled reject dialog
    final result = await showOrderRejectedDialog(context);
    if (result == true) {
      // Reject the job
      context.read<JobCubit>().rejectJob(job!.jobId ?? job!.id.toString());
    }
  }


  void _showCompleteDialog(BuildContext context) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(StringConstant.completeJob),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(StringConstant.addCompletionNotes),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  hintText: StringConstant.enterCompletionNotes,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                StringConstant.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<JobCubit>().completeJob(
                      job!.jobId ?? job!.id.toString(),
                      notesController.text.trim(),
                    );
              },
              child: Text(StringConstant.complete),
            ),
          ],
        );
      },
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
