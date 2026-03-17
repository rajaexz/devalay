import 'package:devalay_app/src/application/job/job_cubit.dart';
import 'package:devalay_app/src/application/job/job_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/delivered_job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobDeliveredView extends StatefulWidget {
  const JobDeliveredView({super.key});

  @override
  State<JobDeliveredView> createState() => _JobDeliveredViewState();
}

class _JobDeliveredViewState extends State<JobDeliveredView>
    with AutomaticKeepAliveClientMixin {
  final scrollController = ScrollController();
  bool _hasInitialized = false;
  final String _selectedFilter = 'Completed';

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
                Text(
                  '${StringConstant.error}: ${state.errorMessage}',
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
                Icon(
                  Icons.local_shipping_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  StringConstant.noDataAvailable,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Reset page and clear existing data for fresh fetch
            await context.read<JobCubit>().fetchJobData(
                  loadMoreData: false,
                  statusFilter: _selectedFilter,
                );
          },
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when list is short
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length + (state is JobLoadingState && state.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= jobs.length) {
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
              return DeliveredJobCard(job: jobs[index]);
            },
          ),
        );
      },
    );
  }
}

