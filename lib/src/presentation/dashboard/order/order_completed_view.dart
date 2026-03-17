import 'package:devalay_app/src/application/kirti/order/order_completed_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_completed_state.dart';
import 'package:devalay_app/src/core/network/network_error_handler.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_button.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/dashboard/order/orderDetails/order_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:visibility_detector/visibility_detector.dart';

class OrderCompletedView extends StatefulWidget {
  const OrderCompletedView({super.key});

  @override
  State<OrderCompletedView> createState() => _OrderCompletedViewState();
}

class _OrderCompletedViewState extends State<OrderCompletedView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // This prevents the widget from being disposed

  @override
  void initState() {
    super.initState();
    // Fetch data on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndFetchData();
      }
    });
  }

  void _checkAndFetchData({bool forceRefresh = false}) {
    final cubit = context.read<OrderCompletedCubit>();
    final state = cubit.state;
    
    // If force refresh is requested (e.g., when tab becomes visible), always fetch
    if (forceRefresh) {
      cubit.fetchCompletedOrders(forceRefresh: true);
      return;
    }
    
    // Fetch data if not already loading and data is empty/null
    if (state is OrderCompletedLoadingState) {
      final orders = state.orderList;
      final isLoading = state.isLoading;
      
      // Only fetch if not currently loading and data is null or empty
      if (!isLoading && (orders == null || orders.isEmpty)) {
        cubit.fetchCompletedOrders();
      }
    } else {
      // If state is not OrderCompletedLoadingState, fetch data
      cubit.fetchCompletedOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return VisibilityDetector(
      key: const Key('order_completed_view'),
      onVisibilityChanged: (visibilityInfo) {
        // When widget becomes visible (more than 50% visible), always fetch fresh data
        if (visibilityInfo.visibleFraction > 0.5) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _checkAndFetchData(forceRefresh: true);
            }
          });
        }
      },
      child: BlocConsumer<OrderCompletedCubit, OrderCompletedState>(
      listener: (context, state) {
        if (state is OrderCompletedLoadingState && state.errorMessage.isNotEmpty) {
          NetworkErrorHandler.showNetworkErrorToast(state.errorMessage);
        }
      },
      builder: (context, state) {
        if (state is OrderCompletedLoadingState) {
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
                      context.read<OrderCompletedCubit>().refreshCompletedOrders();
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
                  Icon(Icons.check_circle_outline, size: 64.sp, color: Colors.green),
                  SizedBox(height: 16.h),
                  Text(
                    'No Completed Orders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'You don\'t have any completed orders yet.',
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
              await context.read<OrderCompletedCubit>().refreshCompletedOrders();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];
                return CompletedOrderCard(
                  order: order,
                  onReorder: () => _reorderService(order.id!),
                );
              },
            ),
          );
        }

        return const Center(child: CustomLottieLoader());
      },
      ),
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
              context.read<OrderCompletedCubit>().reorderService(orderId);
              Fluttertoast.showToast(msg: 'Service reordered successfully');
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class CompletedOrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onReorder;

  const CompletedOrderCard({
    super.key,
    required this.order,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF3C3C43).withOpacity(0.18),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID + Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${StringConstant.orderId} ORD${order.id ?? order.orderId ?? StringConstant.notAvailable}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF555151).withOpacity(0.85),
                ),
              ),
              Text(
                order.createdAt != null
                    ? HelperClass().formatDate(order.createdAt.toString())
                    : StringConstant.notAvailable,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF555151).withOpacity(0.85),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          
          // Image + Details Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: CustomCacheImage(
                  imageUrl: order.serviceSection?.images ?? '',
                  width: 103.714.w,
                  height: 78.h,
                ),
              ),
              SizedBox(width: 12.w),
              
              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name
                    Text(
                      order.serviceSection?.name ?? 'Satyanarayan Katha',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF14191E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    
                    // Plan Name
                    Text(
                      order.plan?.type ?? 'Basic',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF555151).withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 7.h),
                    
                    // Details Button + Completed Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Details Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsScreen(
                                  orderId: order.id?.toString() ?? order.orderId?.toString() ?? '',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 17.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE8E8E8),
                                width: 0.787,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              StringConstant.details,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF241601),
                              ),
                            ),
                          ),
                        ),
                        
                        // Completed Status with Tick Icon
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20.sp,
                              color: const Color(0xFF12B76A),
                            ),
                            SizedBox(width: 7.w),
                            Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF12B76A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 