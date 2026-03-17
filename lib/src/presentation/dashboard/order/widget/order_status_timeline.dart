import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:devalay_app/src/data/model/kirti/order_model.dart';

/// Order Status Timeline - Figma Design
/// Shows timeline: Order Placed → Order Confirmed → Order Completed
class OrderStatusTimeline extends StatelessWidget {
  final String? orderPlacedDate;
  final String? orderConfirmedDate;
  final String? orderCompletedDate;
  final bool isPlaced;
  final bool isConfirmed;
  final bool isCompleted;
  final List<OrderTracking>? orderTracking;
  final String? createdAt; // Fallback for order placed date

  const OrderStatusTimeline({
    super.key,
    this.orderPlacedDate,
    this.orderConfirmedDate,
    this.orderCompletedDate,
    this.isPlaced = true,
    this.isConfirmed = false,
    this.isCompleted = false,
    this.orderTracking,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    // Parse tracking data if provided
    final trackingData = _parseTrackingData();
    
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
        
        // Timeline Container - Height adjusted to prevent overflow
        SizedBox(
           // Height to accommodate all timeline items
          child: Stack(
            children: [
              // Vertical line - positioned at left: 7px, starts at top: 14px
              Positioned(
                left: 7.w,
                top: 14.h,
                bottom: 0,
                child: Container(
                  width: 1.w,
                  decoration: BoxDecoration(
                    color: trackingData['isCompleted'] as bool
                        ? const Color(0xFFFF9500) 
                        : (trackingData['isConfirmed'] as bool
                            ? const Color(0xFFFF9500) 
                            : const Color(0xFF979797)),
                  ),
                ),
              ),
              
              // Timeline items
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Order Placed
                  _buildTimelineItem(
                    title: 'Order Placed',
                    date: trackingData['placedDate'] as String?,
                    isActive: trackingData['isPlaced'] as bool,
                    isCompleted: false,
                    isFirst: true,
                  ),
                  Gap(44.h), // Adjusted gap
                  
                  // Order Confirmed
                  _buildTimelineItem(
                    title: 'Order Confirmed',
                    date: trackingData['confirmedDate'] as String?,
                    isActive: trackingData['isConfirmed'] as bool,
                    isCompleted: trackingData['isCompleted'] as bool,
                    isFirst: false,
                  ),
                  Gap(44.h), // Adjusted gap
                  
                 
                  _buildTimelineItem(
                    title: 'Order Completed',
                    date: trackingData['completedDate'] as String?,
                    isActive: trackingData['isCompleted'] as bool,
                    isCompleted: trackingData['isCompleted'] as bool,
                    isFirst: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Parse orderTracking array to extract dates and determine states
  Map<String, dynamic> _parseTrackingData() {
    // Default values
    String? placedDate = orderPlacedDate;
    String? confirmedDate = orderConfirmedDate;
    String? completedDate = orderCompletedDate;
    bool placed = isPlaced;
    bool confirmed = isConfirmed;
    bool completed = isCompleted;

    // If orderTracking is provided, parse it
    if (orderTracking != null && orderTracking!.isNotEmpty) {
      // Sort tracking by date to get the latest entry for each status
      final sortedTracking = List<OrderTracking>.from(orderTracking!);
      sortedTracking.sort((a, b) {
        final dateA = a.createdAt != null ? DateTime.tryParse(a.createdAt!) : null;
        final dateB = b.createdAt != null ? DateTime.tryParse(b.createdAt!) : null;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

      // Parse each tracking entry
      for (var tracking in sortedTracking) {
        final status = tracking.orderStatus?.toLowerCase().trim() ?? '';
        
        if (status == 'order placed' || status == 'pending') {
          placedDate = _formatDateForTimeline(tracking.createdAt);
          placed = true;
        } else if (status == 'order confirmed') {
          confirmedDate = _formatDateForTimeline(tracking.createdAt);
          confirmed = true;
        } else if (status == 'completed' || status == 'order completed') {
          completedDate = _formatDateForTimeline(tracking.createdAt);
          completed = true;
          // If completed, confirmed should also be true
          if (!confirmed) {
            confirmed = true;
          }
        }
      }
    }

    // Fallback to createdAt if no tracking data for placed
    if (placedDate == null && createdAt != null) {
      placedDate = _formatDateForTimeline(createdAt);
      if (!placed) {
        placed = true;
      }
    }

    return {
      'placedDate': placedDate,
      'confirmedDate': confirmedDate,
      'completedDate': completedDate,
      'isPlaced': placed,
      'isConfirmed': confirmed,
      'isCompleted': completed,
    };
  }

  /// Format date string for timeline display (e.g., "30 dec 2025")
  String? _formatDateForTimeline(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return null;
    
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final day = dateTime.day;
      final month = _getMonthName(dateTime.month).toLowerCase();
      final year = dateTime.year;
      return '$day $month $year';
    } catch (e) {
      return null;
    }
  }

  /// Get month name abbreviation
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildTimelineItem({
    required String title,
    String? date,
    required bool isActive,
    required bool isCompleted,
    required bool isFirst,
  }) {
    // Show checkmark only for completed states
    final showCheckmark = isCompleted && isActive;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        SizedBox(
          width: 15.w,
          child: Column(
            children: [
              // Icon/Checkmark
              if (showCheckmark)
                Container(
                  width: 15.w,
                  height: 15.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9500), // Orange filled circle with checkmark
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 10.sp,
                    color: Colors.white,
                  ),
                )
              else if (isActive)
                Container(
                  width: 15.w,
                  height: 15.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9500), // Orange filled circle
                    shape: BoxShape.circle,
                  ),
                )
              else
                Container(
                  width: 15.w,
                  height: 15.h,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 218, 215, 215),
                    shape: BoxShape.circle,
                   
                  ),
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
                  color: isActive ? const Color(0xFF14191E) : const Color(0xFF979797),
                ),
              ),
              if (date != null && date.isNotEmpty) ...[
                Gap(2.h),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF979797),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

