import 'package:devalay_app/src/data/model/job/job_model.dart';

abstract class JobState {}

class JobInitialState extends JobState {}

class JobLoadingState extends JobState {
  final List<JobModel>? jobList;
  final JobModel? singleJob;
  final bool isLoading;
  final String errorMessage;
  final String? helpContactEmail;
  final String? helpContactNumber;

  JobLoadingState({
    this.jobList,
    this.singleJob,
    this.isLoading = false,
    this.errorMessage = '',
    this.helpContactEmail,
    this.helpContactNumber,
  });
}
