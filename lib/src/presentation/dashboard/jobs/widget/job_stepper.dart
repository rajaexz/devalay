import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:devalay_app/src/data/model/job/job_model.dart';

/// Job Status Stepper - Figma Design
/// Shows timeline dynamically from jobTimeline array
class JobStepper extends StatelessWidget {
  final List<JobTimeline>? timelineEntries;
  final String? jobPlacedDate;
  final String? jobConfirmedDate;
  final String? jobCompletedDate;
  final bool isPlaced;
  final bool isConfirmed;
  final bool isCompleted;

  const JobStepper({
    super.key,
    this.timelineEntries,
    this.jobPlacedDate,
    this.jobConfirmedDate,
    this.jobCompletedDate,
    this.isPlaced = true,
    this.isConfirmed = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use timeline entries if available, otherwise fallback to individual dates
    final hasTimelineEntries = timelineEntries != null && timelineEntries!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Order Status',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF241601),
            letterSpacing: 1,
          ),
        ),
        Gap(24.h),
        
        // Dynamic Timeline from API
        if (hasTimelineEntries) ...[
          ...timelineEntries!.asMap().entries.map((entry) {
            final index = entry.key;
            final timeline = entry.value;
            final isLast = index == timelineEntries!.length - 1;
            final statusLower = timeline.status?.toLowerCase() ?? '';
            
            // Determine if this step is active based on status
            bool isActive = false;
            if (statusLower.contains('placed') || statusLower.contains('assigned')) {
              isActive = isPlaced;
            } else if (statusLower.contains('confirmed') || statusLower.contains('accepted')) {
              isActive = isConfirmed;
            } else if (statusLower.contains('completed')) {
              isActive = isCompleted;
            } else {
              // Default: mark as active if it exists in timeline
              isActive = true;
            }
            
            // Format date and time
            String? displayDate;
            if (timeline.date != null && timeline.time != null) {
              displayDate = '${timeline.date} ${timeline.time}';
            } else if (timeline.date != null) {
              displayDate = timeline.date;
            }
            
            return _buildTimelineItem(
              title: timeline.status ?? 'Status',
              date: displayDate,
              isActive: isActive,
              isFirst: index == 0,
              isLast: isLast,
              showLine: !isLast,
            );
          }),
        ] else ...[
          // Fallback to individual status items
          _buildTimelineItem(
            title: 'Job Placed',
            date: jobPlacedDate,
            isActive: isPlaced,
            isFirst: true,
            isLast: false,
            showLine: true,
          ),
          _buildTimelineItem(
            title: 'Job Confirmed',
            date: jobConfirmedDate,
            isActive: isConfirmed,
            isFirst: false,
            isLast: false,
            showLine: true,
          ),
          _buildTimelineItem(
            title: 'Job Completed',
            date: jobCompletedDate,
            isActive: isCompleted,
            isFirst: false,
            isLast: true,
            showLine: false,
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    String? date,
    required bool isActive,
    required bool isFirst,
    required bool isLast,
    required bool showLine,
  }) {
    // Orange color for active, grey for inactive
    final Color activeColor = const Color(0xFFFF9500);
    final Color inactiveColor = Colors.grey.shade300;
    final Color dotColor = isActive ? activeColor : inactiveColor;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator (dot + line)
        SizedBox(
          width: 15.w,
          child: Column(
            children: [
              // Dot
              Container(
                width: 15.w,
                height: 15.h,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              // Vertical line
              if (showLine)
                Container(
                  width: 2.w,
                  height: 60.h,
                  color: isActive ? activeColor : inactiveColor,
                ),
            ],
          ),
        ),
        Gap(15.w),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: isActive ? const Color(0xFF14191E) : Colors.grey.shade500,
                ),
              ),
              if (date != null && date.isNotEmpty) ...[
                Gap(4.h),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF979797),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (showLine) Gap(20.h),
            ],
          ),
        ),
      ],
    );
  }
}

