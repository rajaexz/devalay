import 'package:devalay_app/src/application/assign/assign_cubit.dart';
import 'package:devalay_app/src/application/assign/assign_state.dart';
import 'package:devalay_app/src/presentation/dashboard/admin/widget /assigned_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmedView extends StatefulWidget {
  const ConfirmedView({super.key});

  @override
  State<ConfirmedView> createState() => _ConfirmedViewState();
}

class _ConfirmedViewState extends State<ConfirmedView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = ScrollController();
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        context.read<AssignCubit>().fetchConfirmedOrderData(loadMoreData: false);
        _hasInitialized = true;
      }
    });
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;

    final cubit = context.read<AssignCubit>();
    final state = cubit.state;

    if (state is AssignLoadingState && state.isLoading) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      cubit.fetchConfirmedOrderData(loadMoreData: true);
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

    return BlocBuilder<AssignCubit, AssignState>(
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
                    context.read<AssignCubit>().fetchConfirmedOrderData();
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
                const Text('No confirmed orders'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AssignCubit>().fetchConfirmedOrderData();
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
            context.read<AssignCubit>().fetchConfirmedOrderData();
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
    );
  }
}
