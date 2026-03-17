import 'package:devalay_app/src/application/job/job_cubit.dart';
import 'package:devalay_app/src/application/job/job_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/processing_job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobPendingView extends StatefulWidget {
  const JobPendingView({super.key});

  @override
  State<JobPendingView> createState() => _JobPendingViewState();
}

class _JobPendingViewState extends State<JobPendingView>
    with AutomaticKeepAliveClientMixin {
  final scrollController = ScrollController();
  bool _hasInitialized = false;
  final String _selectedFilter = 'Accepted';

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

    return BlocBuilder<JobCubit, JobState>(
      builder: (context, state) {
        if (state is JobLoadingState &&
            state.isLoading &&
            state.jobList == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JobLoadingState && state.errorMessage.isNotEmpty) {
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
                    context.read<JobCubit>().fetchJobData(
                          loadMoreData: false,
                          statusFilter: _selectedFilter,
                        );
                  },
                  child: Text(StringConstant.retry),
                ),
              ],
            ),
          );
        }

        final jobs = (state is JobLoadingState) ? state.jobList ?? [] : [];

        if (jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pending_actions, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  StringConstant.noDataAvailable,
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
            itemCount: jobs.length + 1,
            itemBuilder: (context, index) {
              if (index == jobs.length) {
                if (state is JobLoadingState && state.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              return ProcessingJobCard(job: jobs[index]);
            },
          ),
        );
      },
    );
  }
}
