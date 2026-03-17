import 'package:devalay_app/src/application/job/job_cubit.dart';
import 'package:devalay_app/src/application/job/job_state.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobNewView extends StatefulWidget {
  const JobNewView({super.key});

  @override
  State<JobNewView> createState() => _JobNewViewState();
}

class _JobNewViewState extends State<JobNewView> with AutomaticKeepAliveClientMixin {
  final scrollController = ScrollController();
  bool _hasInitialized = false;
  final String _selectedFilter = 'Requested';

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
    
    return Column(
      children: [
    
        // Job List
        Expanded(
          child: BlocBuilder<JobCubit, JobState>(
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
                        '${StringConstant.error}: ${state.errorMessage}',
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
                        child: Text(StringConstant.retry),
                      ),
                    ],
                  ),
                );
              }

              final jobList = state is JobLoadingState ? state.jobList : <dynamic>[];

              if (jobList == null || jobList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
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
                  itemCount: jobList.length + (state is JobLoadingState && state.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= jobList.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return JobCard(job: jobList[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}