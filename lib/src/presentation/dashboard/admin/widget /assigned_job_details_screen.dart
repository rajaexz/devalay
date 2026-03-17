import 'package:devalay_app/src/application/adminOrderDetail/admin_order_detail_cubit_cubit.dart';
import 'package:devalay_app/src/application/adminOrderDetail/admin_order_detail_cubit_state.dart';
import 'package:devalay_app/src/data/model/kirti/admin_order_detail_model.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AssignedJobDetailsScreen extends StatefulWidget {
  final String orderId;

  const AssignedJobDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AssignedJobDetailsScreen> createState() =>
      _AssignedJobDetailsScreenState();
}

class _AssignedJobDetailsScreenState extends State<AssignedJobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<AdminOrderDetailCubit>()
        .fetchOrderDetailAssigned(orderId: widget.orderId);
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
          'Assigned Job Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
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
                          .fetchOrderDetailAssigned(orderId: widget.orderId);
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header Card
          _buildOrderHeaderCard(order),
          Gap(12.h),

          // Order Summary Section
          _buildOrderSummary(order),
          Gap(23.h),

          // Pandit Assigned Section
          _buildPanditAssignedSection(order),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID ORD${order.id ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF555151).withOpacity(0.85),
                ),
              ),
            ],
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

  Widget _buildPanditAssignedSection(AdminOrderDetailModel order) {
    final pandits = order.requestedPandits ?? [];

    if (pandits.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Text(
            'No pandits assigned yet',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pandit Assigned',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black.withOpacity(0.9),
          ),
        ),
        Gap(18.h),
        ...pandits.map((pandit) => Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: _buildPanditCard(pandit, order),
            )),
      ],
    );
  }

  Widget _buildPanditCard(
      RequestedPanditModel pandit, AdminOrderDetailModel order) {
    final status = pandit.status ?? 'Pending';
    final statusLower = status.toLowerCase();
    final isAccepted = statusLower == 'accepted' || statusLower == 'confirmed';

    return Container(
      padding: EdgeInsets.only(left: 8.w, top: 15.h, right: 8.w, bottom: 15.h),
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
              // Avatar with orange border (2px, #fe9f1e)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFE9F1E), // Orange border
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28.5.r,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: pandit.paditDp != null && pandit.paditDp!.isNotEmpty
                      ? NetworkImage(pandit.paditDp!)
                      : null,
                  child: pandit.paditDp == null || pandit.paditDp!.isEmpty
                      ? (pandit.name != null && pandit.name!.isNotEmpty
                          ? Text(
                              pandit.name![0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.person, color: Colors.white))
                      : null,
                ),
              ),
              SizedBox(width: 13.w),
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
                    SizedBox(height: 2.h),
                    Text(
                      '${pandit.city ?? 'N/A'}, ${pandit.state ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0x66000000), // rgba(0,0,0,0.4)
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Contact No. ${pandit.phone ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0x66000000), // rgba(0,0,0,0.4)
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
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Ratings and Jobs Completed - Figma design
          Row(
            children: [
              // Ratings section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ratings',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF241601),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    // Star rating (5 stars as per Figma)
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
              SizedBox(width: 9.w),
              // Jobs completed section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jobs completed',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF241601),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      '7 Pooja', // Placeholder - update when API provides this data
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF241601),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 9.w),
              // Total no.of jobs completed section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total no.of jobs completed',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF241601),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    // Star rating (5 stars as per Figma)
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
          SizedBox(height: 14.h),
          // Status - Figma design
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF555151),
              ),
              children: [
                const TextSpan(text: 'Current Status- '),
                TextSpan(
                  text: isAccepted ? 'Accepted' : 'Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isAccepted
                        ? const Color(0xFF12B76A) // Green for Accepted
                        : Colors.red, // Red for Pending
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          // Action Buttons - Figma design
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isAccepted
                      ? null
                      : () {
                          _handleRejectPandit(pandit, order);
                        },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.red, width: 1),
                    padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0B0B0B),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                          _handleConfirmPandit(pandit, order);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12B76A), // Green
                    padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleRejectPandit(
      RequestedPanditModel pandit, AdminOrderDetailModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Pandit'),
        content: Text('Are you sure you want to reject ${pandit.name ?? 'this pandit'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement reject API call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pandit rejected')),
              );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleConfirmPandit(
      RequestedPanditModel pandit, AdminOrderDetailModel order) {

    context.read<AdminOrderDetailCubit>().confirmOrder(order.id.toString(),pandit.jobId ?? 0,context);


   
  }
}

