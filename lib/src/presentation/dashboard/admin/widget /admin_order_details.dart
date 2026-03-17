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
  final String? status;

  const AdminOrderDetailsScreen({
    super.key,
    required this.orderId,
    this.status,
  });

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminOrderDetailCubit>().fetchOrderDetail(orderId: widget.orderId, status: widget.status);
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

        // Handle Error state - Show error but allow navigation to assign if orderId is available
        if (state is AdminOrderDetailError) {
          // Check if error message is "No order found" - this might be a parsing issue
          final isNoOrderFound = state.errorMessage.toLowerCase().contains('no order found');
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Order Details'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 100.h),
                    Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      isNoOrderFound 
                          ? 'Error: No order found' 
                          : 'Error: ${state.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    const SizedBox(height: 32),
                    // Retry button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AdminOrderDetailCubit>()
                              .fetchOrderDetail(orderId: widget.orderId, status: widget.status);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9F1E), // Orange button
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Allow navigation to assign even if order fetch fails
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilterJobAssign(
                                orderId: widget.orderId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0B0B0B),
                          side: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 3.h),
                          minimumSize: Size(double.infinity, 39.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Assign Service Provider',
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
              ),
            ),
          );
        }

        // Handle Loaded state - THIS WAS THE MAIN ISSUE
        if (state is AdminOrderDetailLoaded) {
          // Check if order is pending - show Figma design, otherwise show existing design
          final isPending = state.order.status?.toLowerCase() == 'pending';
          return AdminOrderDetailsView(
            order: state.order,
            isPendingOrder: isPending,
          );
        }

        // Handle Refreshing state
        if (state is AdminOrderDetailRefreshing) {
          // Check if order is pending - show Figma design, otherwise show existing design
          final isPending = state.order.status?.toLowerCase() == 'pending';
          return AdminOrderDetailsView(
            order: state.order,
            isRefreshing: true,
            isPendingOrder: isPending,
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
  final bool isPendingOrder;

  const AdminOrderDetailsView({
    super.key,
    required this.order,
    this.isRefreshing = false,
    this.isPendingOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    // If order is pending, show Figma design, otherwise show existing design
    if (isPendingOrder) {
      return _buildPendingOrderDesign(context);
    } else {
      return _buildAssignedOrderDesign(context);
    }
  }

  // Figma design for pending orders
  Widget _buildPendingOrderDesign(BuildContext context) {
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
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
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
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 29.h),
              
              // Order Info Card (116px height as per Figma)
              Container(
                height: 116.h,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x2E3C3C43)), // rgba(60,60,67,0.18)
                  borderRadius: BorderRadius.circular(5.r),
                ),
                padding: EdgeInsets.all(11.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID ORD${order.id}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xD9555151), // rgba(85,81,81,0.85)
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Flexible(
                            child: Text(
                              order.serviceSection?.name ?? 'N/A',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF14191E),
                                letterSpacing: 1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            order.plan?.type ?? 'N/A',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xD9555151), // rgba(85,81,81,0.85)
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
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
              ),
              
              SizedBox(height: 29.h),
              
              // Order Summary Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 9.h),
                  Text(
                    'Order summary',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                  
                  SizedBox(height: 15.h),
                  
                  _buildSummaryRow(
                    '${order.plan?.type ?? 'Premium'} plan',
                    '₹${order.plan?.price?.toStringAsFixed(0) ?? '0'}',
                  ),
                  
                  if (order.addOns != null && order.addOns!.isNotEmpty) ...[
                    SizedBox(height: 15.h),
                    Text(
                      'Add on',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF555151),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    ...order.addOns!.map((addon) => Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _buildSummaryRow(
                        addon.name ?? 'N/A',
                        '₹${addon.price?.toStringAsFixed(0) ?? '0'}',
                      ),
                    )),
                  ],
                  
                  SizedBox(height: 14.h),
                  _buildSummaryRow(
                    'Taxes',
                    '₹${order.tax?.toStringAsFixed(0) ?? '0'}',
                  ),
                  
                  SizedBox(height: 14.h),
                  _buildSummaryRow(
                    'Total',
                    '₹${order.totalAmount?.toStringAsFixed(0) ?? '0'}',
                    isBold: true,
                  ),
                ],
              ),
              
              SizedBox(height: 29.h),
              
              // User Details Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User ID',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                    ),
                  ),
                  
                  SizedBox(height: 18.h),
                  
                  // User Details Card (299px height as per Figma)
                  Container(
                    height: 299.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDADADA)),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    padding: EdgeInsets.only(left: 15.w, top: 7.h, right: 15.w, bottom: 7.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28.r,
                              backgroundImage: order.user?.dp != null && 
                                      order.user!.dp!.isNotEmpty
                                  ? NetworkImage(order.user!.dp!)
                                  : null,
                              child: order.user?.dp == null || 
                                      order.user!.dp!.isEmpty
                                  ? Icon(Icons.person, size: 28, color: Colors.grey[400])
                                  : null,
                            ),
                            SizedBox(width: 11.w),
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
                                  SizedBox(height: 2.h),
                                  Text(
                                    _formatLocation(order.user?.city, order.user?.state),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0x66000000), // rgba(0,0,0,0.4)
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '${_formatFollowers(order.user?.totalFollowers ?? 0)} followers  ${order.user?.totalPosts ?? 0} posts',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0x66000000), // rgba(0,0,0,0.4)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12.h),
                        
                        // Phone Number
                        Row(
                          children: [
                            Icon(Icons.phone, size: 20.sp, color: Colors.grey[700]),
                            SizedBox(width: 6.w),
                            Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Padding(
                          padding: EdgeInsets.only(left: 26.w),
                          child: Text(
                            _formatPhoneNumber(order.user?.phone),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xCC000000), // rgba(0,0,0,0.8)
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 12.h),
                        
                        // Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, size: 20.sp, color: Colors.grey[700]),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    order.address ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xCC000000), // rgba(0,0,0,0.8)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12.h),
                        
                        // Date & Time
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 20.sp, color: Colors.grey[700]),
                            SizedBox(width: 8.w),
                            Text(
                              'Date & Time',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Padding(
                          padding: EdgeInsets.only(left: 28.w),
                          child: Text(
                            _formatDateTime(order.scheduledDatetime),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xCC000000), // rgba(0,0,0,0.8)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 29.h),
              
              // Assign Service Provider Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilterJobAssign(order: order),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0B0B0B),
                    side: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 3.h),
                    minimumSize: Size(double.infinity, 39.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Assign Service Provider',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0B0B0B),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 40.h), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // Existing design for assigned/other orders
  Widget _buildAssignedOrderDesign(BuildContext context) {
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
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 29.h),
              
              // Order Info Card (116px height as per Figma)
              Container(
                height: 116.h,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x2E3C3C43)), // rgba(60,60,67,0.18)
                  borderRadius: BorderRadius.circular(5.r),
                ),
                padding: EdgeInsets.all(11.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID ORD${order.id}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xD9555151), // rgba(85,81,81,0.85)
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Flexible(
                            child: Text(
                              order.serviceSection?.name ?? 'N/A',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF14191E),
                                letterSpacing: 1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            order.plan?.type ?? 'N/A',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xD9555151), // rgba(85,81,81,0.85)
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
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
              ),
              
              SizedBox(height: 29.h),
              
              // Order Summary Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 9.h),
                  Text(
                    'Order summary',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                  
                  SizedBox(height: 15.h),
                  
                  _buildSummaryRow(
                    '${order.plan?.type ?? 'Premium'} plan',
                    '₹${order.plan?.price?.toStringAsFixed(0) ?? '0'}',
                  ),
                  
                  if (order.addOns != null && order.addOns!.isNotEmpty) ...[
                    SizedBox(height: 15.h),
                    Text(
                      'Add on',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF555151),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    ...order.addOns!.map((addon) => Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _buildSummaryRow(
                        addon.name ?? 'N/A',
                        '₹${addon.price?.toStringAsFixed(0) ?? '0'}',
                      ),
                    )),
                  ],
                  
                  SizedBox(height: 14.h),
                  _buildSummaryRow(
                    'Taxes',
                    '₹${order.tax?.toStringAsFixed(0) ?? '0'}',
                  ),
                  
                  SizedBox(height: 14.h),
                  _buildSummaryRow(
                    'Total',
                    '₹${order.totalAmount?.toStringAsFixed(0) ?? '0'}',
                    isBold: true,
                  ),
                ],
              ),
              
              SizedBox(height: 29.h),
              
              // User Details Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User ID',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                    ),
                  ),
                  
                  SizedBox(height: 18.h),
                  
                  // User Details Card (299px height as per Figma)
                  Container(
                    height: 299.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDADADA)),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    padding: EdgeInsets.only(left: 15.w, top: 7.h, right: 15.w, bottom: 7.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28.r,
                              backgroundImage: order.user?.dp != null && 
                                      order.user!.dp!.isNotEmpty
                                  ? NetworkImage(order.user!.dp!)
                                  : null,
                              child: order.user?.dp == null || 
                                      order.user!.dp!.isEmpty
                                  ? Icon(Icons.person, size: 28, color: Colors.grey[400])
                                  : null,
                            ),
                            SizedBox(width: 11.w),
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
                                  SizedBox(height: 2.h),
                                  Text(
                                    _formatLocation(order.user?.city, order.user?.state),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0x66000000), // rgba(0,0,0,0.4)
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '${_formatFollowers(order.user?.totalFollowers ?? 0)} followers  ${order.user?.totalPosts ?? 0} posts',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0x66000000), // rgba(0,0,0,0.4)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12.h),
                        
                        // Phone Number
                        Row(
                          children: [
                            Icon(Icons.phone, size: 20.sp, color: Colors.grey[700]),
                            SizedBox(width: 6.w),
                            Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Padding(
                          padding: EdgeInsets.only(left: 26.w),
                          child: Text(
                            _formatPhoneNumber(order.user?.phone),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xCC000000), // rgba(0,0,0,0.8)
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 12.h),
                        
                        // Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, size: 20.sp, color: Colors.grey[700]),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    order.address ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xCC000000), // rgba(0,0,0,0.8)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12.h),
                        
                        // Date & Time
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 20.sp, color: Colors.grey[700]),
                            SizedBox(width: 8.w),
                            Text(
                              'Date & Time',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xE6000000), // rgba(0,0,0,0.9)
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Padding(
                          padding: EdgeInsets.only(left: 28.w),
                          child: Text(
                            _formatDateTime(order.scheduledDatetime),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xCC000000), // rgba(0,0,0,0.8)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 29.h),
              
              // Assign Service Provider Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilterJobAssign(order: order),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0B0B0B),
                    side: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 3.h),
                    minimumSize: Size(double.infinity, 39.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Assign Service Provider',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0B0B0B),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 40.h), // Bottom padding
            ],
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
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: const Color(0xFF555151), // rgba(85,81,81,0.85) - matches Figma
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: Colors.black, // Black for values - matches Figma
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
      
      // Format: "28th Dec 2025 & 11:00 am"
      return '${day}th $month $year & $hour:$minute $period';
    } catch (e) {
      return dateTimeStr;
    }
  }
  
  String _formatFollowers(int followers) {
    if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(0)}K';
    }
    return followers.toString();
  }
  
  String _formatLocation(String? city, String? state) {
    final cityStr = city?.trim() ?? '';
    final stateStr = state?.trim() ?? '';
    
    if (cityStr.isEmpty && stateStr.isEmpty) {
      return 'N/A';
    } else if (cityStr.isEmpty) {
      return stateStr;
    } else if (stateStr.isEmpty) {
      return cityStr;
    } else {
      return '$cityStr, $stateStr';
    }
  }
  
  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return 'N/A';
    
    // Remove +91 or other country codes if present
    String cleaned = phone.replaceAll(RegExp(r'^\+91'), '').trim();
    
    // If phone starts with 0, remove it
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    
    return cleaned.isEmpty ? phone : cleaned;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}