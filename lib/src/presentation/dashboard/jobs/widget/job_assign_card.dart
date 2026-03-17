import 'package:devalay_app/src/application/job/job_cubit.dart';
import 'package:devalay_app/src/data/model/job/job_model.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/job_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobAssignCard extends StatelessWidget {
  final JobModel? job;

  const JobAssignCard({
    super.key,
    this.job,
  });

  @override
  Widget build(BuildContext context) {
    if (job == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Job ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'JOB ID ${job!.displayJobId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  HelperClass.formatDate2(DateTime.tryParse(job!.createdAt ?? '') ?? DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                CustomCacheImage(
                  imageUrl: job!.displayImageUrl,
                  borderRadius: BorderRadius.circular(8.r),
                  width: 80.w,
                  height: 80.h,
                ),
                SizedBox(width: 12.w),
                
                // Job Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job!.displayTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        job!.displaySubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        job!.displayPrice,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Customer: ${job!.customerName ?? job!.user?.name ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status and Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Status
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pending_actions,
                            size: 12.sp,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Pending',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    // Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Assign Button
                        GestureDetector(
                          onTap: () => _showAssignDialog(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Assign',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        
                        // Details Button
                        GestureDetector(
                          onTap: () => _navigateToDetails(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Details',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    final TextEditingController assigneeController = TextEditingController();
    final List<String> availableAssignees = [
      'Pandit Ram Kumar',
      'Pandit Suresh Sharma',
      'Pandit Rajesh Gupta',
      'Pandit Amit Singh',
      'Pandit Vikash Kumar',
    ];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assign Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a pandit to assign this job:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Pandit',
                  border: OutlineInputBorder(),
                ),
                items: availableAssignees.map((String assignee) {
                  return DropdownMenuItem<String>(
                    value: assignee,
                    child: Text(assignee),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    assigneeController.text = newValue;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (assigneeController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  context.read<JobCubit>().assignJob(
                    job!.jobId ?? job!.id.toString(),
                    assigneeController.text.trim(),
                  );
                }
              },
              child: const Text('Assign'),
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
        builder: (context) => JobDetailsScreen(jobId: job!.jobId ?? job!.id.toString()),
      ),
    );
  }
}
