import 'package:devalay_app/src/application/kirti/order/order_cancelled_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_cancelled_state.dart';
import 'package:devalay_app/src/core/network/network_error_handler.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderCancelledView extends StatefulWidget {
  const OrderCancelledView({super.key});

  @override
  State<OrderCancelledView> createState() => _OrderCancelledViewState();
}

class _OrderCancelledViewState extends State<OrderCancelledView>
    with AutomaticKeepAliveClientMixin {
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true; // This prevents the widget from being disposed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        context.read<OrderCancelledCubit>().fetchCancelledOrders();
        _hasInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return BlocConsumer<OrderCancelledCubit, OrderCancelledState>(
      listener: (context, state) {
        if (state is OrderCancelledLoadingState && state.errorMessage.isNotEmpty) {
          NetworkErrorHandler.showNetworkErrorToast(state.errorMessage);
        }
      },
      builder: (context, state) {
        if (state is OrderCancelledLoadingState) {
          if (state.isLoading) {
            return const Center(child: CustomLottieLoader());
          }

          if (state.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading orders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.errorMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  CustomButton(
                    onTap: () {
                      context.read<OrderCancelledCubit>().refreshCancelledOrders();
                    },
                    textButton: 'Retry',
                    buttonAssets: '',
                    fontSize: 16,
                    mypadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ],
              ),
            );
          }

          final orderList = state.orderList ?? [];

          if (orderList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'No Cancelled Orders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'You don\'t have any cancelled orders.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<OrderCancelledCubit>().refreshCancelledOrders();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];
                return CancelledOrderCard(
                  order: order,
                  onReorder: () => _reorderService(order.id!),
                );
              },
            ),
          );
        }

        return const Center(child: CustomLottieLoader());
      },
    );
  }

  void _reorderService(int orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder Service'),
        content: const Text('Would you like to reorder this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderCancelledCubit>().reorderFromCancelled(orderId);
              Fluttertoast.showToast(msg: 'Service reordered successfully');
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class CancelledOrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onReorder;

  const CancelledOrderCard({
    super.key,
    required this.order,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order.id}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    order.status?.toUpperCase() ?? 'CANCELLED',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Cancelled: ${order.updatedAt ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCacheImage(
                  imageUrl: order.serviceSection?.images ?? 'https://via.placeholder.com/150',
                  borderRadius: BorderRadius.circular(8.r),
                  width: 80.w,
                  height: 80.h,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.serviceSection?.name ?? 'Service',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        order.plan?.type ?? 'Plan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '₹${order.plan?.price ?? '0'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onTap: onReorder,
                    fontSize: 14,
                    buttonAssets: '',
                    mypadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    textButton: 'Reorder',
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    onTap: () {
                      // View order details
                    },
                    fontSize: 14,
                    buttonAssets: '',
                    mypadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    textButton: 'View Details',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 