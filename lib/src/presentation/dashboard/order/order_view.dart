import 'package:devalay_app/src/application/kirti/order/order_cubit.dart';
import 'package:devalay_app/src/application/kirti/order/order_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/helper/loader.dart';
import 'package:devalay_app/src/presentation/dashboard/order/widget/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllOrder extends StatefulWidget {
  const AllOrder({super.key});

  @override
  State<AllOrder> createState() => _AllOrderState();
}

class _AllOrderState extends State<AllOrder> with AutomaticKeepAliveClientMixin {
  final scrollController = ScrollController();
  bool _hasInitialized = false;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        context.read<OrderCubit>().fetchOrderData(loadMoreData: false);
        _hasInitialized = true;
      }
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      
      // Prevent multiple simultaneous calls
      if (!_isLoadingMore) {
        _isLoadingMore = true;
        context.read<OrderCubit>().fetchOrderData(loadMoreData: true).then((_) {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        // Handle initial state
        if (state is OrderInitialState) {
          return const Center(child: CustomLottieLoader());
        }
        
        if (state is OrderLoadingState) {
          // Show loader only for initial loading when no data exists
          if (state.isLoading && (state.orderList == null || state.orderList!.isEmpty)) {
            return const Center(child: CustomLottieLoader());
          }
          
          // Show error message only if there's no data
          if (state.errorMessage.isNotEmpty && (state.orderList == null || state.orderList!.isEmpty)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<OrderCubit>().refreshOrderData(),
                    child: Text(StringConstant.retry),
                  ),
                ],
              ),
            );
          }
          
          // Show data if available
          if (state.orderList != null && state.orderList!.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<OrderCubit>().fetchOrderData(loadMoreData: false);
              },
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.orderList!.length + (state.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.orderList!.length) {
                    // Show loading at bottom while loading more
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final order = state.orderList![index];
                  return OrderCard(order: order);
                },
              ),
            );
          }
          
          // Show no data message
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(StringConstant.noDataAvailable),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<OrderCubit>().refreshOrderData(),
                  child: Text(StringConstant.refresh),
                ),
              ],
            ),
          );
        }
        
        return const Center(child: CustomLottieLoader());
      },
    );
  }
}