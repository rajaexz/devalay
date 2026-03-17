import 'package:devalay_app/src/application/assign/assign_cubit.dart';
import 'package:devalay_app/src/application/assign/assign_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/widget%20/admin_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewOrderView extends StatefulWidget {
  const NewOrderView({super.key});

  @override
  State<NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<NewOrderView> 
    with AutomaticKeepAliveClientMixin {
  final scrollController = ScrollController();
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        context.read<AssignCubit>().fetchNewOrderData(loadMoreData: false);
        _hasInitialized = true;
      }
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      context.read<AssignCubit>().fetchNewOrderData(loadMoreData: true);
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
    
    return BlocBuilder<AssignCubit, AssignState>(
      builder: (context, state) {
        // Loading state (initial load)
        if (state is AssignLoadingState && 
            state.isLoading && 
            (state.adminOrderList == null || state.adminOrderList!.isEmpty)) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (state is AssignLoadingState && state.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '${StringConstant.error}: ${state.errorMessage}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AssignCubit>().refreshOrderData();
                  },
                  child: Text(StringConstant.retry),
                ),
              ],
            ),
          );
        }


        final allOrders = state is AssignLoadingState 
            ? (state.adminOrderList ?? []) 
            : [];
        

        final pendingOrders = allOrders
            .where((order) => 
                order.status?.toLowerCase() == 'pending' || 
                order.status == 'Pending')
            .toList();
        
     
        // Empty state
        if (pendingOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pending_actions, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  StringConstant.noPendingOrders,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.read<AssignCubit>().refreshOrderData();
                  },
                  child: Text(StringConstant.refresh),
                ),
              ],
            ),
          );
        }

        // List view with data
        return RefreshIndicator(
          onRefresh: () async {
            context.read<AssignCubit>().refreshOrderData();
          },
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: pendingOrders.length + 
                (state is AssignLoadingState && state.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator at bottom
              if (index >= pendingOrders.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final order = pendingOrders[index];
              print('🎯 Showing order ${order.id} - ${order.status}');

              return AdminOrderCard(order: order);
            },
          ),
        );
      },
    );
  }
}