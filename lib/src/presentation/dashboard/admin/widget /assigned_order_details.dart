// admin_order_details_screen.dart - Fixed version

import 'package:devalay_app/src/application/adminOrderDetail/admin_order_detail_cubit_cubit.dart';
import 'package:devalay_app/src/application/adminOrderDetail/admin_order_detail_cubit_state.dart';
import 'package:devalay_app/src/data/model/kirti/admin_order_detail_model.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/filter_job_assign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminOrderDetailCubit>().fetchOrderDetail(orderId: widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminOrderDetailCubit, AdminOrderDetailState>(
      builder: (context, state) {
        // Handle Initial and Loading states
        if (state is AdminOrderDetailInitial || 
            (state is AdminOrderDetailLoading && state.isLoading && state.order == null)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle Error state
        if (state is AdminOrderDetailError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Order Details'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Error: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminOrderDetailCubit>()
                          .refreshOrderDetail(widget.orderId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle Loaded state - THIS WAS THE MAIN ISSUE
        if (state is AdminOrderDetailLoaded) {
          return AdminOrderDetailsView(order: state.order);
        }

        // Handle Refreshing state
        if (state is AdminOrderDetailRefreshing) {
          return AdminOrderDetailsView(
            order: state.order,
            isRefreshing: true,
          );
        }

        // Fallback
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class AdminOrderDetailsView extends StatelessWidget {
  final AdminOrderDetailModel order;
  final bool isRefreshing;

  const AdminOrderDetailsView({
    super.key,
    required this.order,
    this.isRefreshing = false,
  });

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
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (isRefreshing)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID ORD${order.id}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              order.serviceSection?.name ?? 'N/A',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              order.plan?.type ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomCacheImage(
                          imageUrl: order.serviceSection?.images ?? '',
                          width: 120.w,
                          height: 90.h,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Order Summary
                  Text(
                    'Order summary',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  _buildSummaryRow(
                    '${order.plan?.type ?? 'Premium'} plan',
                    '₹${order.plan?.price?.toStringAsFixed(0) ?? '0'}',
                  ),
                  
                  if (order.addOns != null && order.addOns!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      'Add on',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...order.addOns!.map((addon) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _buildSummaryRow(
                        addon.name ?? 'N/A',
                        '₹${addon.price?.toStringAsFixed(0) ?? '0'}',
                      ),
                    )),
                  ],
                  
                  SizedBox(height: 12.h),
                  _buildSummaryRow(
                    'Taxes',
                    '₹${order.tax?.toStringAsFixed(0) ?? '0'}',
                  ),
                  
                  Divider(height: 24.h, thickness: 1),
                  
                  _buildSummaryRow(
                    'Total',
                    '₹${order.totalAmount?.toStringAsFixed(0) ?? '0'}',
                    isBold: true,
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // User Details
                  Text(
                    'User ID',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: order.user?.dp != null && 
                                order.user!.dp!.isNotEmpty
                            ? NetworkImage(order.user!.dp!)
                            : null,
                        child: order.user?.dp == null || 
                                order.user!.dp!.isEmpty
                            ? Icon(Icons.person, size: 30, color: Colors.grey[400])
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.user?.name ?? 'N/A',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${order.user?.city ?? 'N/A'}, ${order.user?.state ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${order.user?.totalFollowers ?? 0}K followers  ${order.user?.totalPosts ?? 0} posts',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Phone Number
                  Row(
                    children: [
                      Icon(Icons.phone, size: 20, color: Colors.grey[700]),
                      SizedBox(width: 8.w),
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    order.user?.phone ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 20, color: Colors.grey[700]),
                      SizedBox(width: 8.w),
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    order.address ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Date & Time
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.grey[700]),
                      SizedBox(width: 8.w),
                      Text(
                        'Date & Time',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDateTime(order.scheduledDatetime),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  // Requested Pandits Section
                  if (order.requestedPandits != null && order.requestedPandits!.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    Text(
                      'Requested Pandits',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...order.requestedPandits!.map((pandit) => Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pandit.name ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(pandit.status),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  pandit.status ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            pandit.phone ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (pandit.city != null || pandit.state != null)
                            Text(
                              '${pandit.city ?? 'N/A'}, ${pandit.state ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    )),
                  ],
                  
                  SizedBox(height: 24.h),
                  
                  // Assign Service Provider Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                       Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                       FilterJobAssign(
                                    order: order)));  
                                   
                         
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.grey, width: 1),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Assign Service Provider',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.grey[800],
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
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'pm' : 'am';
      
      return '${day}th $month $year & $hour:$minute $period';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

 
}