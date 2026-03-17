import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/job/job_state.dart';
import 'package:devalay_app/src/data/model/job/job_model.dart';
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobCubit extends Cubit<JobState> {
  JobCubit()
      : _kirtiRepo = getIt<KirtiRepo>(),
        super(JobInitialState());
  
  final KirtiRepo _kirtiRepo;
  int page = 1;
  bool hasMoreData = true;
  List<JobModel>? allData = [];
  JobModel? singleJob;
  String? _currentStatusFilter; // Store current status filter for refresh

  // Map UI status labels to API status values
  String? _mapStatusToApiValue(String? statusFilter) {
    if (statusFilter == null) return null;
    
    switch (statusFilter.toLowerCase()) {
      case 'new':
      case 'requested':
        return 'Requested'; // New jobs are those with status "Requested"
      case 'processing':
      case 'accepted':
        return 'Accepted'; // Processing jobs are those with status "Accepted"
      case 'delivered':
      case 'completed':
        return 'completed'; // Delivered jobs are those with status "completed" (lowercase)
      default:
        return statusFilter; // Use as-is if already in API format
    }
  }

  Future<void> fetchJobData({
    String? value,
    String filterQuery = '',
    String? statusFilter,
    String? jobId,
    bool loadMoreData = false,
  }) async {
    if (!hasMoreData && loadMoreData) return;

    setJobState(isLoading: true, jobList: allData);

    if (loadMoreData) {
      page++;
    } else {
      page = 1;
      allData!.clear();
    }

    // Store the current status filter for refresh
    _currentStatusFilter = statusFilter;
    
    // Map the UI status to API status value
    final apiStatus = _mapStatusToApiValue(statusFilter);

    final result = await _kirtiRepo.fetchPanditJobs(
      page: page,
      jobId: jobId,
      status: apiStatus,
    );

    result.fold(
      (failure) {
        hasMoreData = false;
        setJobState(
          isLoading: false,
          jobList: allData,
          errorMessage: failure.toString(),
        );
      },
      (customResponse) {
        final responseData = customResponse.response?.data;
        List<JobModel> data = [];
        bool nextPageAvailable = false;

        if (responseData is Map<String, dynamic>) {
          final results = responseData['results'];
          final next = responseData['next'];

          if (results is List) {
            data = results
                .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          nextPageAvailable = next != null && next.toString().isNotEmpty;
        } else if (responseData is List) {
          data = responseData
              .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
              .toList();
          nextPageAvailable = data.length >= 10;
            setJobState(
            isLoading: false,
            jobList: allData,
            errorMessage: 'Successful',
          );
        } else {
          setJobState(
            isLoading: false,
            jobList: allData,
            errorMessage: 'Unexpected response format',
          );
          hasMoreData = false;
          return;
        }

        if (loadMoreData) {
          allData!.addAll(data);
        } else {
          allData = data;
        }

        hasMoreData = nextPageAvailable;

        setJobState(
          isLoading: false,
          jobList: allData,
        );
      },
    );
  }

  Future<void> fetchSingleJobData({
    required String jobId,
    String? status, // Optional status parameter
  }) async {
    setJobState(isLoading: true, singleJob: singleJob);

    // Try fetching with status if provided, otherwise try multiple statuses
    // Try: completed, Accepted, Requested, and without status
    List<String?> statusesToTry = status != null 
        ? [status] 
        : ['completed', 'Accepted', 'Requested', null];
    
    JobModel? foundJob;
    String? lastError;
    
    for (final tryStatus in statusesToTry) {
      final result = await _kirtiRepo.fetchPanditJobs(
        page: 1,
        jobId: jobId,
        status: tryStatus,
      );

      final jobResult = result.fold(
        (failure) {
          lastError = failure.toString();
          return null;
        },
        (customResponse) {
          final responseData = customResponse.response?.data;

          if (responseData is Map<String, dynamic>) {
            final results = responseData['results'];
            
            if (results is List && results.isNotEmpty) {
              // Find the job matching the jobId
              for (var item in results) {
                final jobData = item as Map<String, dynamic>;
                final fetchedJob = JobModel.fromJson(jobData);
                
                // Match by jobId, id, or orderId
                if (fetchedJob.jobId == jobId || 
                    fetchedJob.id.toString() == jobId ||
                    fetchedJob.orderId.toString() == jobId) {
                  return fetchedJob;
                }
              }
            } else if (results is Map<String, dynamic>) {
              // Single job object returned
              return JobModel.fromJson(results);
            }
          } else if (responseData is List && responseData.isNotEmpty) {
            // Direct list response
            for (var item in responseData) {
              final jobData = item as Map<String, dynamic>;
              final fetchedJob = JobModel.fromJson(jobData);
              
              if (fetchedJob.jobId == jobId || 
                  fetchedJob.id.toString() == jobId ||
                  fetchedJob.orderId.toString() == jobId) {
                return fetchedJob;
              }
            }
          } else if (responseData is Map<String, dynamic>) {
            // Single job object
            return JobModel.fromJson(responseData);
          }
          
          return null;
        },
      );

      if (jobResult != null) {
        foundJob = jobResult;
        break; // Found the job, exit loop
      }
    }

    if (foundJob != null) {
      singleJob = foundJob;
      setJobState(isLoading: false, singleJob: foundJob);
    } else {
      // If not found in API, try to find in cached data
      final cachedJob = allData?.firstWhere(
        (j) => j.jobId == jobId || j.id.toString() == jobId || j.orderId.toString() == jobId,
        orElse: () => JobModel(),
      );
      
      if (cachedJob != null && cachedJob.id != null) {
        singleJob = cachedJob;
        setJobState(isLoading: false, singleJob: cachedJob);
      } else {
        setJobState(
          isLoading: false,
          singleJob: null,
          errorMessage: lastError ?? 'Job not found',
        );
      }
    }
  }

  Future<void> acceptJob(String jobId) async {
    setJobState(isLoading: true, jobList: allData, singleJob: singleJob);

    // Get the orderId from the job
    final orderId = _getOrderIdFromJobId(jobId);
    
    if (orderId == null) {
      setJobState(
        isLoading: false,
        jobList: allData,
        singleJob: singleJob,
        errorMessage: 'Invalid job ID',
      );
      return;
    }

    // Call the real API
    final result = await _kirtiRepo.panditRespondToJob(   
      orderId: int.tryParse(orderId) ?? 0,
      response: 'accept',
    );

    result.fold(
      (failure) {
        setJobState(
          isLoading: false,
          jobList: allData,
          singleJob: singleJob,
          errorMessage: failure.errorMessage,
        );
      },
      (response) {
        // Update job status in local data
        if (allData != null) {
          for (int i = 0; i < allData!.length; i++) {
            if (allData![i].jobId == jobId || allData![i].id.toString() == jobId || allData![i].orderId.toString() == jobId) {
              allData![i] = allData![i].copyWith(
                status: 'Accepted',
                isAccepted: true,
                isRejected: false,
              );
              break;
            }
          }
        }

        if (singleJob != null && (singleJob!.jobId == jobId || singleJob!.id.toString() == jobId || singleJob!.orderId.toString() == jobId)) {
          singleJob = singleJob!.copyWith(
            status: 'Accepted',
            isAccepted: true,
            isRejected: false,
          );
        }

        setJobState(isLoading: false, jobList: allData, singleJob: singleJob);
        
        // Refresh job list to get updated data
        refreshJobData();
      },
    );
  }

  Future<void> rejectJob(String jobId) async {
    setJobState(isLoading: true, jobList: allData, singleJob: singleJob);

    // Get the orderId from the job
    final orderId = _getOrderIdFromJobId(jobId);
    
    if (orderId == null) {
      setJobState(
        isLoading: false,
        jobList: allData,
        singleJob: singleJob,
        errorMessage: 'Invalid job ID',
      );
      return;
    }

    // Call the real API
    final result = await _kirtiRepo.panditRespondToJob(
      orderId: int.tryParse(orderId) ?? 0,
      response: 'reject',
    );

    result.fold(
      (failure) {
        setJobState(
          isLoading: false,
          jobList: allData,
          singleJob: singleJob,
          errorMessage: failure.errorMessage,
        );
      },
      (response) {
        // Update job status in local data
        if (allData != null) {
          for (int i = 0; i < allData!.length; i++) {
            if (allData![i].jobId == jobId || allData![i].id.toString() == jobId || allData![i].orderId.toString() == jobId) {
              allData![i] = allData![i].copyWith(
                status: 'Rejected',
                isAccepted: false,
                isRejected: true,
              );
              break;
            }
          }
        }

        if (singleJob != null && (singleJob!.jobId == jobId || singleJob!.id.toString() == jobId || singleJob!.orderId.toString() == jobId)) {
          singleJob = singleJob!.copyWith(
            status: 'Rejected',
            isAccepted: false,
            isRejected: true,
          );
        }

        setJobState(isLoading: false, jobList: allData, singleJob: singleJob);
        
        // Refresh job list to get updated data
        refreshJobData();
      },
    );
  }

  /// Helper to extract orderId from jobId
  String? _getOrderIdFromJobId(String jobId) {
    // Try to find the job in allData first
    if (allData != null) {
      for (var job in allData!) {
        if (job.jobId == jobId || job.id.toString() == jobId) {
          return  job.jobId ;
        }
      }
    }
    
    // Try from singleJob
    if (singleJob != null && (singleJob!.jobId == jobId || singleJob!.id.toString() == jobId)) {
      return singleJob!.jobId ?? singleJob!.id.toString();
    }
    
    // Try to parse directly if it's a number (assuming jobId might be orderId)
    return int.tryParse(jobId.replaceAll('JOB', '').replaceAll('ORD', ''))?.toString();
  }

  Future<void> assignJob(String jobId, String assignedTo) async {
    setJobState(isLoading: true, jobList: allData, singleJob: singleJob);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Update job status in local data
    if (allData != null) {
      for (int i = 0; i < allData!.length; i++) {
        if (allData![i].jobId == jobId || allData![i].id.toString() == jobId) {
          allData![i] = allData![i].copyWith(
            status: 'Assigned',
            assignedTo: assignedTo,
          );
          break;
        }
      }
    }

    if (singleJob != null && (singleJob!.jobId == jobId || singleJob!.id.toString() == jobId)) {
      singleJob = singleJob!.copyWith(
        status: 'Assigned',
        assignedTo: assignedTo,
      );
    }

    setJobState(isLoading: false, jobList: allData, singleJob: singleJob);
  }

  Future<void> completeJob(
    String jobId,
    String completionNotes, {
    int? rating,
  }) async {
    setJobState(isLoading: true, jobList: allData, singleJob: singleJob);

    // Get the orderId from the job
    final orderId = _getOrderIdFromJobId(jobId);
    
    if (orderId == null) {
      setJobState(
        isLoading: false,
        jobList: allData,
        singleJob: singleJob,
        errorMessage: 'Invalid job ID',
      );
      return;
    }

    // Submit feedback if rating is provided
    if (rating != null && rating > 0) {
      final feedbackResult = await _kirtiRepo.submitPanditFeedback(
        orderId: int.tryParse(orderId) ?? 0,
        rating: rating,
        comments: completionNotes.isNotEmpty ? completionNotes : null,
      );

      feedbackResult.fold(
        (failure) {
          setJobState(
            isLoading: false,
            jobList: allData,
            singleJob: singleJob,
            errorMessage: failure.toString(),
          );
          return;
        },
        (response) {
          // Feedback submitted successfully, continue with job completion
        },
      );
    }

    // Update job status in local data
    if (allData != null) {
      for (int i = 0; i < allData!.length; i++) {
        if (allData![i].jobId == jobId || allData![i].id.toString() == jobId) {
          allData![i] = allData![i].copyWith(
            status: 'Completed',
            completionNotes: completionNotes,
          );
          break;
        }
      }
    }

    if (singleJob != null && (singleJob!.jobId == jobId || singleJob!.id.toString() == jobId)) {
      singleJob = singleJob!.copyWith(
        status: 'Completed',
        completionNotes: completionNotes,
      );
    }

    setJobState(isLoading: false, jobList: allData, singleJob: singleJob);
    
    // Refresh job data to get updated information
    await fetchSingleJobData(jobId: jobId);
  }

  void setJobState({
    List<JobModel>? jobList,
    JobModel? singleJob,
    bool isLoading = false,
    String errorMessage = '',
    String? helpContactEmail,
    String? helpContactNumber,
  }) {
    final currentState = state;
    final existingEmail = currentState is JobLoadingState ? currentState.helpContactEmail : null;
    final existingNumber = currentState is JobLoadingState ? currentState.helpContactNumber : null;
    
    emit(JobLoadingState(
      jobList: jobList,
      singleJob: singleJob,
      isLoading: isLoading,
      errorMessage: errorMessage,
      helpContactEmail: helpContactEmail ?? existingEmail,
      helpContactNumber: helpContactNumber ?? existingNumber,
    ));
  }

  Future<void> fetchHelpContact() async {
    try {
      final result = await _kirtiRepo.fetchHelpContact();
      
      result.fold(
        (failure) {
          // On error, keep existing state
          print('Error fetching help contact: ${failure.toString()}');
        },
        (response) {
          try {
            final responseData = response.response?.data;
            String? email;
            String? contactNumber;
            
            if (responseData is Map<String, dynamic>) {
              email = responseData['email']?.toString();
              contactNumber = responseData['contact_number']?.toString() ?? 
                             responseData['contactNumber']?.toString() ??
                             responseData['phone']?.toString() ??
                             responseData['mobile_number']?.toString();
            } else if (responseData is List && responseData.isNotEmpty) {
              // If it's a list, take the first item
              final firstItem = responseData[0];
              if (firstItem is Map<String, dynamic>) {
                email = firstItem['email']?.toString();
                contactNumber = firstItem['contact_number']?.toString() ?? 
                               firstItem['contactNumber']?.toString() ??
                               firstItem['phone']?.toString() ??
                               firstItem['mobile_number']?.toString();
              }
            }
            
            // Update state with help contact info
            setJobState(
              jobList: allData,
              singleJob: singleJob,
              helpContactEmail: email,
              helpContactNumber: contactNumber,
            );
          } catch (e) {
            print('Error parsing help contact data: $e');
          }
        },
      );
    } catch (e) {
      print('Error in fetchHelpContact: $e');
    }
  }

  void refreshJobData() {
    fetchJobData(statusFilter: _currentStatusFilter);
  }
}

// Extension to add copyWith method to JobModel
extension JobModelCopyWith on JobModel {
  JobModel copyWith({
    int? id,
    String? jobId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? createdAt,
    String? updatedAt,
    String? scheduledDate,
    String? assignedTo,
    String? assignedBy,
    String? serviceType,
    String? planType,
    double? price,
    String? imageUrl,
    String? address,
    String? mobileNumber,
    String? customerName,
    List<JobTracking>? jobTracking,
    bool? isAccepted,
    bool? isRejected,
    String? rejectionReason,
    String? completionNotes,
    User? user,
    ServiceSection? serviceSection,
    Plan? plan,
  }) {
    return JobModel(
      id: id ?? id,
      jobId: jobId ?? this.jobId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      serviceType: serviceType ?? this.serviceType,
      planType: planType ?? this.planType,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      orderAddress: orderAddress ?? this.orderAddress,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      customerName: customerName ?? this.customerName,
      jobTracking: jobTracking ?? this.jobTracking,
      isAccepted: isAccepted ?? this.isAccepted,
      isRejected: isRejected ?? this.isRejected,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      completionNotes: completionNotes ?? this.completionNotes,
      user: user ?? this.user,
      serviceSection: serviceSection ?? this.serviceSection,
      plan: plan ?? this.plan,
    );
  }
}
