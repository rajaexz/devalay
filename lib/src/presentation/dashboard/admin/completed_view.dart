import 'package:devalay_app/src/application/assign/assign_cubit.dart';
import 'package:devalay_app/src/application/assign/assign_state.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/widget /assigned_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CompletedOrderView extends StatefulWidget {
  const CompletedOrderView({super.key});

  @override
  State<CompletedOrderView> createState() => _CompletedOrderViewState();
}

class _CompletedOrderViewState extends State<CompletedOrderView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);

    // Fetch data on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndFetchData();
      }
    });
  }

  void _checkAndFetchData() {
    final cubit = context.read<AssignCubit>();
    final state = cubit.state;
    
    // Fetch data if not already loading and data is empty/null
    if (state is AssignLoadingState) {
      final orders = state.orderListAssigned;
      final isLoading = state.isLoading;
      
      // Only fetch if not currently loading and data is null or empty
      if (!isLoading && (orders == null || orders.isEmpty)) {
        cubit.fetchCompletedOrderData(loadMoreData: false);
      }
    } else {
      // If state is not AssignLoadingState, fetch data
      cubit.fetchCompletedOrderData(loadMoreData: false);
    }
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;

    final cubit = context.read<AssignCubit>();
    final state = cubit.state;

    if (state is AssignLoadingState && state.isLoading) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      cubit.fetchCompletedOrderData(loadMoreData: true);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return VisibilityDetector(
      key: const Key('completed_order_view'),
      onVisibilityChanged: (visibilityInfo) {
        // When widget becomes visible (more than 50% visible), fetch data if needed
        if (visibilityInfo.visibleFraction > 0.5) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _checkAndFetchData();
            }
          });
        }
      },
      child: BlocBuilder<AssignCubit, AssignState>(
      builder: (context, state) {
        if (state is! AssignLoadingState) {
          return const SizedBox();
        }

        // Initial loading
        if (state.isLoading && state.orderListAssigned == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (state.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AssignCubit>().fetchCompletedOrderData();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final orders = state.orderListAssigned ?? [];

        // Empty state
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No completed orders'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AssignCubit>().fetchCompletedOrderData();
                  },
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        // List view
        return RefreshIndicator(
          onRefresh: () async {
            context.read<AssignCubit>().fetchCompletedOrderData();
          },
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length + (state.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= orders.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return AssignedOrderCard(order: orders[index]);
            },
          ),
        );
      },
      ),
    );
  }
}

