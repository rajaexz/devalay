import 'package:devalay_app/src/application/kirti/order/order_processing_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_processing_state.dart';
import 'package:devalay_app/src/core/network/network_error_handler.dart';
import 'package:devalay_app/src/data/model/kirti/order_model.dart';
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

class OrderProcessingView extends StatefulWidget {
  const OrderProcessingView({super.key});

  @override
  State<OrderProcessingView> createState() => _OrderProcessingViewState();
}

class _OrderProcessingViewState extends State<OrderProcessingView>
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
    final cubit = context.read<OrderProcessingCubit>();
    final state = cubit.state;
    
    // If force refresh is requested (e.g., when tab becomes visible), always fetch
    if (forceRefresh) {
      cubit.fetchProcessingOrders(forceRefresh: true);
      return;
    }
    
    // Fetch data if not already loading and data is empty/null
    if (state is OrderProcessingLoadingState) {
      final orders = state.orderList;
      final isLoading = state.isLoading;
      
      // Only fetch if not currently loading and data is null or empty
      if (!isLoading && (orders == null || orders.isEmpty)) {
        cubit.fetchProcessingOrders();
      }
    } else {
      // If state is not OrderProcessingLoadingState, fetch data
      cubit.fetchProcessingOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return VisibilityDetector(
      key: const Key('order_processing_view'),
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
      child: BlocConsumer<OrderProcessingCubit, OrderProcessingState>(
      listener: (context, state) {
        if (state is OrderProcessingLoadingState && state.errorMessage.isNotEmpty) {
          NetworkErrorHandler.showNetworkErrorToast(state.errorMessage);
        }
      },
      builder: (context, state) {
        if (state is OrderProcessingLoadingState) {
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
                      context.read<OrderProcessingCubit>().refreshProcessingOrders();
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
                  Icon(Icons.hourglass_empty, size: 64.sp, color: Colors.orange),
                  SizedBox(height: 16.h),
                  Text(
                    'No Processing Orders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'You don\'t have any orders in processing at the moment.',
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
              await context.read<OrderProcessingCubit>().refreshProcessingOrders();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];
                return ProcessingOrderCard(
                  order: order,
                  onUpdateStatus: (newStatus) => _updateOrderStatus(order.id!, newStatus),
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

  void _updateOrderStatus(int orderId, String newStatus) {
    context.read<OrderProcessingCubit>().updateOrderStatus(orderId, newStatus);
    Fluttertoast.showToast(msg: 'Order status updated successfully');
  }
}

class ProcessingOrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(String) onUpdateStatus;

  const ProcessingOrderCard({
    super.key,
    required this.order,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF3C3C43).withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID + Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${StringConstant.orderId} ${order.orderId}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF555151).withOpacity(0.85),
                ),
              ),
              Text(
                HelperClass().formatDate(order.createdAt.toString()),
                style: TextStyle(
                  fontSize: 14.sp,
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
                  width: 103.w,
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
                    
                    // Plan Name (as per Figma for Processing view)
                    Text(
                      '${StringConstant.planName} ${order.plan?.type ?? 'Basic'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF555151).withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    
                    // Total Amount (as per Figma for Processing view)
                    Text(
                      '${StringConstant.totalAmount} ${order.plan?.price ?? '1500'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF555151).withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          
          // Status + Details Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status with Icon (showing actual status)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getStatusIcon(order.status),
                  SizedBox(width: 7.w),
                  Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: _getStatusData(order.status)["color"],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              
              // Details Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(
                          orderId: order.id.toString()),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 17.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFD9D9D9),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    StringConstant.details,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF0B0B0B),
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

  Map<String, dynamic> _getStatusData(String? status) {
    if (status == null) {
      return {
        'text': StringConstant.unknown,
        'color': Colors.grey,
      };
    }

    switch (status) {
      case 'Pending':
      case 'Order Placed':
      case 'Order Confirmed':
      case 'Prepration Completed':
      case 'Order in Execution':
        // All processing states - Orange (#FF9500)
        return {
          'text': StringConstant.processing,
          'color': const Color(0xFFFF9500),
        };
      case 'Order Completed':
        // Completed - Green (#12B76A)
        return {
          'text': StringConstant.completed,
          'color': const Color(0xFF12B76A),
        };
      case 'Cancelled by User':
      case 'Cancelled by Company':
      case 'Cancelled by Pandit':
        // Cancelled - Red (#FF4704)
        return {
          'text': StringConstant.cancelled,
          'color': const Color(0xFFFF4704),
        };
      default:
        return {
          'text': status,
          'color': Colors.grey,
        };
    }
  }

  String _getStatusText(String? status) {
    if (status == null) return StringConstant.unknown;

    switch (status) {
      case 'Pending':
        return StringConstant.pending;
      case 'Order Placed':
        return StringConstant.orderPlaced;
      case 'Order Confirmed':
        return StringConstant.confirmed;
      case 'Prepration Completed':
        return StringConstant.preparationDone;
      case 'Order in Execution':
        return StringConstant.processing;
      case 'Order Completed':
        return StringConstant.completed;
      case 'Cancelled by User':
      case 'Cancelled by Company':
      case 'Cancelled by Pandit':
        return StringConstant.cancelled;
      default:
        return status;
    }
  }

  Widget _getStatusIcon(String? status) {
    const double iconSize = 16.667;
    
    if (status == null) {
      return Icon(
        Icons.help_outline,
        color: Colors.grey,
        size: iconSize.sp,
      );
    }

    switch (status) {
      case 'Pending':
      case 'Order Placed':
      case 'Order Confirmed':
      case 'Prepration Completed':
      case 'Order in Execution':
        // Processing states - Clock icon (orange)
        return Icon(
          Icons.access_time,
          color: const Color(0xFFFF9500),
          size: iconSize.sp,
        );
      case 'Order Completed':
        // Completed - Checkmark (green)
        return Icon(
          Icons.check_circle,
          color: const Color(0xFF12B76A),
          size: iconSize.sp,
        );
      case 'Cancelled by User':
      case 'Cancelled by Company':
      case 'Cancelled by Pandit':
        // Cancelled - Cross (red)
        return Icon(
          Icons.close,
          color: const Color(0xFFFF4704),
          size: iconSize.sp,
        );
      default:
        return Icon(
          Icons.help_outline,
          color: Colors.grey,
          size: iconSize.sp,
        );
    }
  }
} 