import 'dart:convert';
import 'package:devalay_app/src/application/kirti/order/order_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_state.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/dashboard/order/widget/order_status_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:devalay_app/src/data/model/kirti/order_model.dart'; 

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().fetchSigleOrderData(id: widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoadingState && state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is OrderLoadingState && state.errorMessage.isNotEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Details')),
            body: Center(child: Text('Error: ${state.errorMessage}')),
          );
        }
        if (state is OrderLoadingState && state.sigleData == null) {
          return const Scaffold(
            body: Center(child: Text('No order found')),
          );
        }
        if (state is OrderLoadingState && state.sigleData != null) {
          return OrderDetailsView(order: state.sigleData as OrderModel);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class OrderDetailsView extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsView({super.key, required this.order});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();
  bool _showContactCard = false;

  @override
  void initState() {
    super.initState();
    // Fetch help contact information when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderCubit>().fetchHelpContact();
    });
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
  
  void _toggleContactCard() {
    setState(() {
      _showContactCard = !_showContactCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
    
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        ),
        leadingWidth: 35.w,
        titleSpacing: 8.w,
        title: Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: 56.h,
        actions: [
          // Contact info icon button
          IconButton(
            icon: Icon(
              _showContactCard ? Icons.close : Icons.question_mark_sharp,
              color: Colors.black,
              size: 22.sp,
            ),
            onPressed: _toggleContactCard,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 0, bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(20.h),
                // Header Card (Order ID, Title, Plan, Image)
                _buildOrderCard(context, order),
                Gap(23.h),
                
                // Order Status Timeline (always show)
                _buildOrderStatusTimeline(context, order),
                Gap(24.h),
                
                // Mark as Complete Button (for Execution state) - Before Order Summary
                if (_isExecutionState(order)) ...[
                  _buildMarkAsCompleteButton(context, order),
                  Gap(24.h),
                ],
                
                // Order Summary
                _buildOrderSummary(context, order),
                Gap(22.h),
                
                // Check if pandit_feedback is true - if yes, show only rating and comments
                // Otherwise, show normal feedback section
                if (order.hasPanditFeedback == true) ...[
                  // Show pandit feedback details (only rating and comments)
                  _buildPanditFeedbackSection(context, order),
                ] else ...[
                // Feedback Section (for Completed orders)
                // Show feedback form if order is completed AND feedback is not already submitted
                if ((_isCompletedState(order) || order.showFeedback) && 
                    (order.isFeedback != true)) ...[
                  _buildFeedbackSection(context),
                ],
                
                // Show submitted feedback if feedback is already submitted
                if (order.isFeedback == true && order.feedback != null) ...[
                  _buildSubmittedFeedbackSection(context, order),
                  ],
                ],
                
                // Extra space for floating contact card
                if (_isConfirmedState(order) && !_isCompletedState(order)) SizedBox(height: 150.h),
              ],
            ),
          ),
          
          // Floating Contact Info Card - Show when icon is clicked
          if (_showContactCard)
            Positioned(
              top:0.h, // Below AppBar
              right: 15.w,
              child: _buildContactInfoCard(context, widget.order),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID ORD${order.id ?? order.orderId}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF555151).withOpacity(0.85),
                  height: 1.4,
                ),
              ),
              Gap(6.h),
              Text(
                order.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF14191E),
                  letterSpacing: 1,
                  height: 1.4,
                ),
              ),
              Gap(6.h),
              Text(
                order.subtitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF555151).withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Gap(16.w),
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(3.r),
          child: CustomCacheImage(
            imageUrl: order.imageUrl,
            width: 103.714.w,
            height: 78.h,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusTimeline(BuildContext context, OrderModel order) {
    // Pass orderTracking directly - the widget will parse it internally
    return OrderStatusTimeline(
      orderTracking: order.orderTracking,
      createdAt: order.createdAt,
    );
  }
  
  
  bool _isExecutionState(OrderModel order) {
    return order.status == 'Order Confirmed';
  }
  
  bool _isConfirmedState(OrderModel order) {
    return order.status == 'Order Confirmed' || 
           order.status == 'Prepration Completed' ||
           order.status == 'Order in Execution';
  }
  
  bool _isCompletedState(OrderModel order) {
    // Check status field
    final isStatusCompleted = order.status == 'Order Completed' || 
                              order.status == 'Completed';
    
    // Also check orderTracking for completed status
    final hasCompletedTracking = order.orderTracking?.any((track) {
      final status = track.orderStatus?.toLowerCase().trim() ?? '';
      return status == 'completed' || status == 'order completed';
    }) ?? false;
    
    return isStatusCompleted || hasCompletedTracking;
  }
  
  Widget _buildMarkAsCompleteButton(BuildContext context, OrderModel order) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Mark order as complete
          context.read<OrderCubit>().markOrderAsComplete(orderId: order.id ?? 0);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9500).withOpacity(0.75),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 43.w, vertical: 2.h),
        ),
        child: Text(
          'Mark as Complete',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context, OrderModel order) {
    // Floating card positioned as per Figma design
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        String email = 'N/A';
        String contactNumber = 'N/A';
        
        if (state is OrderLoadingState) {
          email = state.helpContactEmail ?? 'N/A';
          contactNumber = state.helpContactNumber ?? 'N/A';
        }
        
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.all(21.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xFFD9D9D9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email ID
            _buildContactRow(
              icon: Icons.person_outline,
              label: 'Email Id',
                  value: email,
            ),
            Gap(10.h),
            // Contact Number
            _buildContactRow(
              icon: Icons.phone_outlined,
              label: 'Contact Number',
                  value: contactNumber,
            ),
          ],
        ),
      ),
        );
      },
    );
  }
  
  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: Colors.black.withOpacity(0.9),
            ),
            Gap(8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
          ],
        ),
        Gap(4.h),
        Padding(
          padding: EdgeInsets.only(left: 28.w),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context, OrderModel order) {
    final planPrice = order.plan?.price ?? 0.0;
    final addOnsTotal = order.addOns?.fold<double>(
      0.0,
      (sum, addon) => sum + (addon.price ?? 0.0),
    ) ?? 0.0;
    final taxAmount = order.tax ?? 0.0;
    final totalAmount = planPrice + addOnsTotal + taxAmount;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order summary',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18.sp,
            color: Colors.black,
            letterSpacing: 1,
            height: 1.4,
          ),
        ),
        Gap(10.h),
        
        // Plan (dynamic based on order)
        _buildSummaryRow(
          '${order.plan?.type ?? 'Premium'} plan',
          '₹${planPrice.toStringAsFixed(0)}',
          isBold: false,
        ),
        Gap(15.h),
        
        // Add on section (only show header if there are add-ons)
        if (order.addOns != null && order.addOns!.isNotEmpty) ...[
          Text(
            'Add on',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF555151),
            ),
          ),
          Gap(14.h),
          
          // Add-ons list
          ...order.addOns!.map((addon) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: _buildSummaryRow(
              addon.title ?? 'Add-on',
              '₹${(addon.price ?? 0.0).toStringAsFixed(0)}',
              isBold: false,
            ),
          )),
        ],
        
        // Taxes (show only if tax > 0)
        if (taxAmount > 0) ...[
          Gap(14.h),
          _buildSummaryRow('Taxes', '₹${taxAmount.toStringAsFixed(0)}', isBold: false),
        ],
        
        Gap(14.h),
        
        // Total
        _buildSummaryRow(
          'Total',
          '₹${totalAmount.toStringAsFixed(0)}',
          isBold: false,
        ),
        if (order.infoNote != null) ...[
          Gap(16.h),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Icon(
          //       Icons.info_outline,
          //       color: Colors.grey[600],
          //       size: 18,
          //     ),
          //     Gap(8.w),
          //     Expanded(
          //       child: Text(
          //         order.infoNote!,
          //         style: TextStyle(
          //           fontSize: 13.sp,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            fontSize: 14.sp,
            color: const Color(0xFF555151),
            height: 1.4,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: Colors.black,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback for Pandit',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18.sp,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        Gap(22.h),
        
        // Rate your experience
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(
          'Rate your experience',
          style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF555151),
          ),
        ),
            Gap(10.h),
        Row(
          children: List.generate(5, (index) => GestureDetector(
            onTap: () => setState(() => rating = index + 1),
            child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
              child: Icon(
                    rating > index ? Icons.star : Icons.star_border,
                    color: rating > index 
                        ? const Color(0xFFFF9500) 
                        : Colors.grey[400],
                    size: 19.sp,
              ),
            ),
          )),
        ),
          ],
        ),
        Gap(15.h),
        
        // Write your review
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(
          'Write your review',
          style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF555151),
          ),
        ),
            Gap(10.h),
            SizedBox(
              height: 82.h,
              child: TextField(
          controller: reviewController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                  borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.r),
                    borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            contentPadding: EdgeInsets.all(12.w),
                  hintText: '',
                ),
              ),
          ),
          ],
        ),
        Gap(22.h),
        
        // Submit button
        SizedBox(
          width: double.infinity,
          height: 35.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9500).withOpacity(0.75),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            onPressed: rating > 0 ? () async {
              final orderId = widget.order.id ?? 0;
              await context.read<OrderCubit>().submitFeedback(
                orderId: orderId,
                rating: rating,
                review: reviewController.text,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback submitted successfully')),
                );
                Navigator.pop(context);
              }
            } : null,
            child: Text(
              'Submit',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittedFeedbackSection(BuildContext context, OrderModel order) {
    // Parse feedback data
    Map<String, dynamic>? feedbackData;
    if (order.feedback is Map) {
      feedbackData = Map<String, dynamic>.from(order.feedback as Map);
    } else if (order.feedback is String) {
      try {
        feedbackData = Map<String, dynamic>.from(
          jsonDecode(order.feedback as String),
        );
      } catch (e) {
        feedbackData = null;
      }
    }
    
    if (feedbackData == null) return const SizedBox.shrink();
    
    final rating = feedbackData['rating'] as int? ?? 0;
    final comments = feedbackData['comments'] as String? ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback For Pandit',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18.sp,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        Gap(22.h),
        
        // Star Rating Display
        Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(
                rating > index ? Icons.star : Icons.star_border,
                color: rating > index 
                    ? const Color(0xFFFF9500) 
                    : Colors.grey[400],
                size: 19.sp,
              ),
            );
          }),
        ),
        Gap(10.h),
        
        // Comments/Review Text
        if (comments.isNotEmpty)
          Text(
            comments,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF555151),
              height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPanditFeedbackSection(BuildContext context, OrderModel order) {
    // Get pandit feedback details
    final rating = order.panditFeedbackRating ?? 0;
    final comments = order.panditFeedbackComments ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Star Rating Display
        Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(
                rating > index ? Icons.star : Icons.star_border,
                color: rating > index 
                    ? const Color(0xFFFF9500) 
                    : Colors.grey[400],
                size: 19.sp,
              ),
            );
          }),
        ),
        Gap(10.h),
        
        // Comments/Review Text
        if (comments.isNotEmpty)
          Text(
            comments,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF555151),
              height: 1.4,
          ),
        ),
      ],
    );
  }
}