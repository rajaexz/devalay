import 'package:devalay_app/src/application/assign/assign_cubit.dart';
import 'package:devalay_app/src/application/assign/assign_state.dart';
import 'package:devalay_app/src/application/job/job_cubit.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CancelledView extends StatefulWidget {
  const CancelledView({super.key});

  @override
  State<CancelledView> createState() => _CancelledViewState();
}

class _CancelledViewState extends State<CancelledView> with AutomaticKeepAliveClientMixin {
  final scrollController = ScrollController();
  bool _hasInitialized = false;
  final String _selectedFilter = 'Cancelled';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        context.read<JobCubit>().fetchJobData(
          loadMoreData: false,
          statusFilter: _selectedFilter,
        );
        _hasInitialized = true;
      }
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      context.read<JobCubit>().fetchJobData(
        loadMoreData: true,
        statusFilter: _selectedFilter,
      );
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
        if (state is AssignLoadingState && state.isLoading && state.jobList == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AssignLoadingState && state.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.errorMessage}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<JobCubit>().fetchJobData(
                      loadMoreData: false,
                      statusFilter: _selectedFilter,
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final allJobs = state is AssignLoadingState ? state.jobList : <dynamic>[];
        final cancelledJobs = allJobs?.where((job) => 
          job.status?.toLowerCase() == 'cancelled' || 
          job.status?.toLowerCase() == 'canceled'
        ).toList() ?? [];

        if (cancelledJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No cancelled jobs',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<JobCubit>().fetchJobData(
              loadMoreData: false,
              statusFilter: _selectedFilter,
            );
          },
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: cancelledJobs.length + (state is AssignLoadingState && state.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= cancelledJobs.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return JobCard(job: cancelledJobs[index]);
            },
          ),
        );
      },
    );
  }
}
