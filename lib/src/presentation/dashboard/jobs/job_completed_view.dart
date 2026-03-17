import 'package:devalay_app/src/application/job/job_cubit.dart';
import 'package:devalay_app/src/application/job/job_state.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobCompletedView extends StatefulWidget {
  const JobCompletedView({super.key});

  @override
  State<JobCompletedView> createState() => _JobCompletedViewState();
}

class _JobCompletedViewState extends State<JobCompletedView> with AutomaticKeepAliveClientMixin {
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
        context.read<JobCubit>().fetchJobData(loadMoreData: false);
        _hasInitialized = true;
      }
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      context.read<JobCubit>().fetchJobData(loadMoreData: true);
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
        if (state is JobLoadingState && state.isLoading && state.jobList == null) {
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
                  'Error: ${state.errorMessage}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<JobCubit>().refreshJobData();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final allJobs = state is JobLoadingState ? state.jobList : <dynamic>[];
        final completedJobs = allJobs?.where((job) => 
          job.status?.toLowerCase() == 'completed'
        ).toList() ?? [];

        if (completedJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No completed jobs',
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
            context.read<JobCubit>().refreshJobData();
          },
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: completedJobs.length + (state is JobLoadingState && state.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= completedJobs.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return JobCard(job: completedJobs[index]);
            },
          ),
        );
      },
    );
  }
}
