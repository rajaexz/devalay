import 'package:devalay_app/src/application/adminOrderDetail/admin_order_detail_cubit_cubit.dart';
import 'package:devalay_app/src/application/adminOrderDetail/admin_order_detail_cubit_state.dart';
import 'package:devalay_app/src/data/model/kirti/admin_order_detail_model.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ConfirmedJobDetailsScreen extends StatefulWidget {
  final String orderId;

  const ConfirmedJobDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<ConfirmedJobDetailsScreen> createState() =>
      _ConfirmedJobDetailsScreenState();
}

class _ConfirmedJobDetailsScreenState
    extends State<ConfirmedJobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<AdminOrderDetailCubit>()
        .fetchOrderDetailConfirmed(orderId: widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Confirmed',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // TODO: Add menu options if needed
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminOrderDetailCubit, AdminOrderDetailState>(
        builder: (context, state) {
          if (state is AdminOrderDetailInitial ||
              (state is AdminOrderDetailLoading &&
                  state.isLoading &&
                  state.order == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminOrderDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  Gap(16.h),
                  Text('Error: ${state.errorMessage}'),
                  Gap(16.h),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<AdminOrderDetailCubit>()
                          .refreshOrderDetail(widget.orderId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminOrderDetailLoaded) {
            return _buildContent(state.order);
          }

          if (state is AdminOrderDetailRefreshing) {
            return _buildContent(state.order);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(AdminOrderDetailModel order) {
    final confirmedPandit = _getConfirmedPandit(order);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header Card
          _buildOrderHeaderCard(order),
          Gap(20.h),

          // Order Status Timeline
          _buildOrderStatusTimeline(order),
          Gap(24.h),

          // Order Summary Section
          _buildOrderSummary(order),
          Gap(18.h),

          // User ID Section
          _buildUserSection(order),
          Gap(18.h),

          // Pandit ID Section
          if (confirmedPandit != null) _buildPanditSection(order, confirmedPandit),
        ],
      ),
    );
  }

  Widget _buildOrderHeaderCard(AdminOrderDetailModel order) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: const Color(0x2E3C3C43), // rgba(60,60,67,0.18)
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          Text(
            'Order ID ORD${order.id ?? 'N/A'}',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF555151).withOpacity(0.85),
            ),
          ),
          Gap(6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceSection?.name ?? 'N/A',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF14191E),
                        letterSpacing: 1,
                      ),
                    ),
                    Gap(6.h),
                    Text(
                      order.plan?.type ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF555151).withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(12.w),
              // Service Image
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: CustomCacheImage(
                  imageUrl: order.serviceSection?.images ?? '',
                  width: 103.714.w,
                  height: 78.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusTimeline(AdminOrderDetailModel order) {
    // Get timeline data from confirmed pandit's job_timeline
    final confirmedPandit = _getConfirmedPandit(order);
    final timeline = confirmedPandit?.jobTimeline ?? [];
    
   
    // Find timeline entries for each status
    // "Requested" or "Job Placed" -> "Job Assigned"
    final assignedEntry = timeline.firstWhere(
      (e) => e.status?.toLowerCase() == 'requested' || 
             e.status?.toLowerCase() == 'job placed',
      orElse: () => JobTimelineModel(),
    );
    
    // "Job Confirmed" -> "Job Confirmed"
    final confirmedEntry = timeline.firstWhere(
      (e) => e.status?.toLowerCase() == 'job confirmed',
      orElse: () => JobTimelineModel(),
    );
     // "Job Completed" -> "Job Completed"
    final completedEntry = timeline.firstWhere(
      (e) => e.status?.toLowerCase() == 'job completed',
      orElse: () => JobTimelineModel(),
    );

    // Get dates from timeline entries or use fallback
    final String assignedDate = assignedEntry.date != null && assignedEntry.date!.isNotEmpty
        ? (_formatDateForTimeline(assignedEntry.date) ?? '20 dec 2025')
        : (_formatDateForTimeline(order.createdAt) ?? '20 dec 2025');
    
    final String confirmedDate = confirmedEntry.date != null && confirmedEntry.date!.isNotEmpty
        ? (_formatDateForTimeline(confirmedEntry.date) ?? '22 dec 2025')
        : '22 dec 2025';
    
    final String completedDate = completedEntry.date != null && completedEntry.date!.isNotEmpty
        ? (_formatDateForTimeline(completedEntry.date) ?? '28 dec 2025')
        : '28 dec 2025';

    // Determine which steps are active based on timeline data
    final isAssigned = assignedEntry.date != null && assignedEntry.date!.isNotEmpty;
    final isConfirmed = confirmedEntry.date != null && confirmedEntry.date!.isNotEmpty;
    final isCompleted = completedEntry.date != null && completedEntry.date!.isNotEmpty;
  print( " ${isConfirmed}  timeline length: ${timeline.length}");
  

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(
        
          child: Stack(
            children: [
              // Vertical line - positioned at left: 7px, starts from top: 14px
              Positioned(
                left: 7.w,
                top: 14.h,
                bottom: 0,
                child: Container(
                  width: 1.w,
                  color: const Color(0xFF979797),
                ),
              ),
              // Timeline items
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Assigned - with checkmark icon
                  _buildTimelineItem(
                    title: 'Job Assigned',
                    date: assignedDate,
                    isActive: isAssigned,
                    showCheckmark: isConfirmed,
                  ),
                  Gap(48.h),
                  // Job Confirmed - with filled circle
                  _buildTimelineItem(
                    title: 'Job Confirmed',
                    date: confirmedDate,
                    isActive: isConfirmed,
                    showCheckmark: isConfirmed,
                  ),
                  Gap(48.h),
                  // Job Completed - with empty circle
                  _buildTimelineItem(
                    title: 'Job Completed',
                    date: completedDate ,
                    isActive: isCompleted,
                    showCheckmark: isConfirmed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required bool isActive,
    required bool showCheckmark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon/Circle container
        SizedBox(
          width: 15.w,
          child: isActive && showCheckmark
              ? // Checkmark icon for "Job Assigned"
                Icon(
                    Icons.check_circle,
                    size: 15.sp,
                    color: const Color(0xFF14191E),
                  )
              : // Circle for "Job Confirmed" and "Job Completed"
                Container(
                    width: 15.w,
                    height: 15.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? const Color(0xFF14191E) : Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFF979797),
                        width: 1.5,
                      ),
                    ),
                  ),
        ),
        Gap(15.w),
        // Text content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF14191E),
              ),
            ),
            Gap(4.h),
            Text(
              date,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF979797),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _formatDateForTimeline(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return null;

    try {
      DateTime dateTime;
      
      // Check if it's already in "20 dec 2025" format
      if (dateTimeStr.contains('dec') || dateTimeStr.contains('jan') || 
          dateTimeStr.contains('feb') || dateTimeStr.contains('mar') ||
          dateTimeStr.contains('apr') || dateTimeStr.contains('may') ||
          dateTimeStr.contains('jun') || dateTimeStr.contains('jul') ||
          dateTimeStr.contains('aug') || dateTimeStr.contains('sep') ||
          dateTimeStr.contains('oct') || dateTimeStr.contains('nov')) {
        return dateTimeStr.toLowerCase();
      }
      
      // Check if it's in "DD-MM-YYYY" format (e.g., "29-12-2025")
      if (dateTimeStr.contains('-') && dateTimeStr.split('-').length == 3) {
        final parts = dateTimeStr.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          dateTime = DateTime(year, month, day);
        } else {
          dateTime = DateTime.parse(dateTimeStr);
        }
      } else if (dateTimeStr.contains('T') || dateTimeStr.contains(' ')) {
        // ISO format or standard date format
        dateTime = DateTime.parse(dateTimeStr);
      } else {
        // Try to parse as simple date
        dateTime = DateTime.parse(dateTimeStr);
      }
      
      final day = dateTime.day;
      final month = _getMonthName(dateTime.month).toLowerCase();
      final year = dateTime.year;

      return '$day $month $year';
    } catch (e) {
      // If parsing fails, return the string as is (might already be formatted)
      return dateTimeStr.toLowerCase();
    }
  }

  Widget _buildOrderSummary(AdminOrderDetailModel order) {
    // Calculate totals
    double planPrice = order.plan?.price ?? 0.0;
    double tax = order.tax ?? 0.0;
    double total = (order.totalAmount ?? 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order summary',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        Gap(15.h),
        // Plan Price
        _buildSummaryRow(
          '${order.plan?.type ?? 'Premium'} plan',
          '₹${planPrice.toStringAsFixed(0)}',
        ),
        Gap(15.h),
        // Add-ons Section
        if (order.addOns != null && order.addOns!.isNotEmpty) ...[
          Text(
            'Add on',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF555151),
            ),
          ),
          Gap(14.h),
          ...order.addOns!.map((addOn) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _buildSummaryRow(
                  addOn.name ?? 'N/A',
                  '₹${(addOn.price ?? 0.0).toStringAsFixed(0)}',
                ),
              )),
        ],
        Gap(14.h),
        // Taxes
        _buildSummaryRow(
          'Taxes',
          '₹${tax.toStringAsFixed(0)}',
        ),
        Gap(14.h),
        // Total
        _buildSummaryRow(
          'Total',
          '₹${total.toStringAsFixed(0)}',
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF555151),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildUserSection(AdminOrderDetailModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User ID',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.9),
          ),
        ),
        Gap(18.h),
        Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(
              color: const Color(0xFFDADADA),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: order.user?.dp != null &&
                            order.user!.dp!.isNotEmpty
                        ? NetworkImage(order.user!.dp!)
                        : null,
                    child: order.user?.dp == null ||
                            order.user!.dp!.isEmpty
                        ? Text(
                            (order.user?.name ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Gap(11.w),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.user?.name ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF262626),
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          '${order.user?.city ?? 'N/A'}, ${order.user?.state ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          '${_formatNumber(order.user?.totalFollowers ?? 0)}K followers  ${order.user?.totalPosts ?? 0} posts',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(12.h),
              // Phone Number
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Phone Number',
                value: order.user?.phone ?? 'N/A',
              ),
              Gap(12.h),
              // Location
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Location',
                value: order.address ?? 'N/A',
              ),
              Gap(12.h),
              // Date & Time
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Date & Time',
                value: _formatDateTime(order.scheduledDatetime),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPanditSection(
      AdminOrderDetailModel order, RequestedPanditModel pandit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pandit ID',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black.withOpacity(0.9),
          ),
        ),
        Gap(18.h),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(
              color: const Color(0xFFDADADA),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pandit Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with orange border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFE9F1E), // Orange border
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: pandit.paditDp != null && pandit.paditDp!.isNotEmpty
                          ? CustomCacheImage(
                              imageUrl: pandit.paditDp!,
                              width: 56.w,
                              height: 56.h,
                            )
                          : CircleAvatar(
                              radius: 28.r,
                              backgroundColor: Colors.grey[300],
                              child: pandit.name != null && pandit.name!.isNotEmpty
                                  ? Text(
                                      pandit.name![0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.person, color: Colors.white),
                            ),
                    ),
                  ),
                  Gap(11.w),
                  // Pandit Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pandit.name ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF262626),
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          '${pandit.city ?? 'N/A'}, ${pandit.state ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          '100K followers  660 posts', // Placeholder - get from API if available
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pandit Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB040), // Orange
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Pandit',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(14.h),
              // Ratings and Jobs Completed
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rating by Users',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF241601),
                          ),
                        ),
                        Gap(10.h),
                        // Star rating (placeholder - get from API)
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              size: 16.sp,
                              color: Colors.amber[600],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total no.of jobs completed',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF241601),
                          ),
                        ),
                        Gap(10.h),
                        Text(
                          '7 Pooja', // Placeholder
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF241601),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total no.of jobs completed',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF241601),
                          ),
                        ),
                        Gap(10.h),
                        // Star rating (placeholder)
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              size: 16.sp,
                              color: Colors.amber[600],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(20.h),
              // Phone Number
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Phone Number',
                value: pandit.phone ?? 'N/A',
              ),
              Gap(20.h),
              // Location
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Location',
                value: order.address ?? 'N/A',
              ),
              Gap(20.h),
              // Date & Time
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Date & Time',
                value: _formatDateTime(order.scheduledDatetime),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.sp, color: Colors.black.withOpacity(0.9)),
            Gap(6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 14.sp, color: Colors.grey[400]),
          ],
        ),
        Gap(4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final day = dateTime.day;
      final month = _getMonthName(dateTime.month);
      final year = dateTime.year;
      final hour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'pm' : 'am';

      return '${day}th $month $year & $hour:$minute $period';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return (number / 1000).toStringAsFixed(0);
    }
    return number.toString();
  }

  RequestedPanditModel? _getConfirmedPandit(AdminOrderDetailModel order) {
    // Get the first confirmed/accepted pandit
    final pandits = order.requestedPandits ?? [];
    if (pandits.isEmpty) return null;

    // Find confirmed/accepted pandit
    final confirmed = pandits.firstWhere(
      (p) =>
          p.status?.toLowerCase() == 'accepted' ||
          p.status?.toLowerCase() == 'confirmed',
      orElse: () => pandits.first,
    );

    return confirmed;
  }
}

