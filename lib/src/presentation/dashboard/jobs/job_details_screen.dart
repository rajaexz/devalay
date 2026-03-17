import 'package:devalay_app/src/application/job/job_cubit.dart';
import 'package:devalay_app/src/application/job/job_state.dart';
import 'package:devalay_app/src/data/model/job/job_model.dart';
import 'package:devalay_app/src/presentation/core/helper/helper_class.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/core/widget/custom_cache_image.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/job_dialogs.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/job_feedback_widget.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/job_stepper.dart';
import 'package:devalay_app/src/presentation/dashboard/jobs/widget/job_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final GlobalKey<_JobDetailsContentState> _contentKey = GlobalKey<_JobDetailsContentState>();
  bool _showContactCard = false;

  void _onContactCardToggle(bool show) {
    setState(() {
      _showContactCard = show;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<JobCubit>().fetchSingleJobData(jobId: widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: BlocBuilder<JobCubit, JobState>(
        builder: (context, state) {
          if (state is JobLoadingState && state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JobLoadingState && state.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Error: ${state.errorMessage}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ),
            );
          }

          if (state is JobLoadingState && state.singleJob != null) {
            return _JobDetailsContent(
              key: _contentKey,
              job: state.singleJob!,
              onContactCardToggle: _onContactCardToggle,
            );
          }

          return const Center(child: Text('No job found'));
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Job Details',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          icon: Icon(
            _showContactCard ? Icons.close : Icons.info_outline,
            color: Colors.black,
            size: 22.sp,
          ),
          onPressed: () {
            _contentKey.currentState?._toggleContactCard();
          },
        ),
      ],
    );
  }
}

class _JobDetailsContent extends StatefulWidget {
  final JobModel job;
  final Function(bool) onContactCardToggle;

  const _JobDetailsContent({
    super.key,
    required this.job,
    required this.onContactCardToggle,
  });

  @override
  State<_JobDetailsContent> createState() => _JobDetailsContentState();
}

class _JobDetailsContentState extends State<_JobDetailsContent> {
  bool _showContactCard = false;

  @override
  void initState() {
    super.initState();
    // Fetch help contact information when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobCubit>().fetchHelpContact();
    });
  }

  void _toggleContactCard() {
    setState(() {
      _showContactCard = !_showContactCard;
    });
    widget.onContactCardToggle(_showContactCard);
  }

  JobModel get job => widget.job;

  // Determine job status
  bool get isNewJob =>
      job.status?.toLowerCase() == 'pending' ||
      job.status?.toLowerCase() == 'new' ||
      job.status?.toLowerCase() == 'requested' ||
      (job.canAccept && job.canReject);

  bool get isProcessing =>
      job.status?.toLowerCase() == 'processing' ||
      job.status?.toLowerCase() == 'in progress' ||
      job.status?.toLowerCase() == 'confirmed' ||
      job.status?.toLowerCase() == 'accepted' ||
      job.status?.toLowerCase() == 'job confirmed' ||
      job.status?.toLowerCase() == 'job placed';

  bool get isCompleted {
    final status = job.status?.toLowerCase() ?? '';
      return status == 'completed' || 
            status == 'delivered' ||
           status == 'job completed' ||
           status == 'job delivered';
  }

  bool get isJobPlaced => true; // Always true once created

  bool get isJobConfirmed {
    // Check status directly
    final statusLower = job.status?.toLowerCase() ?? '';
    if (job.isAccepted == true ||
        statusLower == 'confirmed' ||
        statusLower == 'job confirmed' ||
        statusLower == 'accepted') {
      return true;
    }
    
    // Check timeline for "Job Confirmed" entry
    if (job.jobTimeline != null && job.jobTimeline!.isNotEmpty) {
      return job.jobTimeline!.any((timeline) {
        final timelineStatus = timeline.status?.toLowerCase() ?? '';
        return timelineStatus.contains('confirmed') || timelineStatus.contains('accepted');
      });
    }
    
    return false;
  }




  bool get isJobCompleted => 
      job.status?.toLowerCase() == 'job completed' ||
      job.status?.toLowerCase() == 'delivered';

  // Format scheduled datetime for display
  String _formatScheduledDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.tryParse(dateTimeStr);
      if (dateTime != null) {
        final day = dateTime.day;
        final month = _getMonthName(dateTime.month);
        final year = dateTime.year;
        final hour = dateTime.hour;
        final minute = dateTime.minute;
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final displayMinute = minute.toString().padLeft(2, '0');
        
        return '${day}th $month $year & $displayHour:$displayMinute $period';
      }
    } catch (e) {
      // Fallback to original format
    }
    return HelperClass.formatDate2(DateTime.tryParse(dateTimeStr) ?? DateTime.now());
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Get timeline dates from jobTimeline if available
  String? get _jobPlacedDate {
    if (job.jobTimeline != null && job.jobTimeline!.isNotEmpty) {
      final placedEntry = job.jobTimeline!.firstWhere(
        (e) => e.status?.toLowerCase() == 'placed' || e.status?.toLowerCase() == 'created',
        orElse: () => job.jobTimeline!.first,
      );
      return placedEntry.fullDateTime.isNotEmpty ? placedEntry.fullDateTime : null;
    }
    return job.createdAt != null
        ? HelperClass.formatDate2(DateTime.tryParse(job.createdAt!) ?? DateTime.now())
        : null;
  }

  String? get _jobConfirmedDate {
    if (!isJobConfirmed) return null;
    if (job.jobTimeline != null && job.jobTimeline!.isNotEmpty) {
      final confirmedEntry = job.jobTimeline!.firstWhere(
        (e) => e.status?.toLowerCase() == 'confirmed' || e.status?.toLowerCase() == 'accepted',
        orElse: () => JobTimeline(),
      );
      return confirmedEntry.fullDateTime.isNotEmpty ? confirmedEntry.fullDateTime : null;
    }
    return null;
  }

  String? get _jobCompletedDate {
    if (!isJobCompleted) return null;
    if (job.jobTimeline != null && job.jobTimeline!.isNotEmpty) {
      final completedEntry = job.jobTimeline!.firstWhere(
        (e) => e.status?.toLowerCase() == 'job completed',
        orElse: () => JobTimeline(),
      );
      return completedEntry.fullDateTime.isNotEmpty ? completedEntry.fullDateTime : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card (Order ID, Puja Name, Image)
                _buildHeaderCard(context),
                Gap(20.h),

                // Order Status (for Processing/Completed jobs)
                if (isProcessing || isCompleted) ...[
                  _buildOrderStatus(context),
                  Gap(24.h),
                ],

                // Warning message for processing jobs (Job Confirmed/Accepted status)
                if (isProcessing && (isJobConfirmed || job.status?.toLowerCase() == 'accepted' || job.status?.toLowerCase() == 'job confirmed')) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2EE),
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(
                        color: const Color(0xFFFFE0D4),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '*After finishing the pooja, request the user to press the Complete button.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red,
                        height: 1.4,
                      ),
                    ),
                  ),





                  
                  Gap(20.h),
                ],

                    // Order Summary
                _buildOrderSummary(context),
                Gap(20.h),

                // User Info Section (for Processing/Completed)
                if (isProcessing || isCompleted) ...[
                  _buildUserSection(context),
                  Gap(20.h),
                ] else ...[
                  // Simple user info for new jobs
                  _buildSimpleUserInfo(context),
                  Gap(20.h),
                ],

                // Feedback Section (for Completed jobs only)
                // Show feedback form if is_feedback is false, show submitted feedback if is_feedback is true
                if (isCompleted) ...[
                  _buildFeedbackSection(context),
                  Gap(20.h),
                ],

                // Cancel order info (for Processing state before confirmation)
                if (isProcessing && !isJobConfirmed) ...[
                  _buildCancelInfo(context),
                  Gap(20.h),
                ],
              ],
            ),
          ),
        ),

        // Bottom Action Buttons
        _buildBottomButtons(context),
          ],
        ),
        
        // Floating Contact Info Card - Show when icon is clicked
        if (_showContactCard)
          Positioned(
            top: 60.h, // Below AppBar
            right: 15.w,
            child: _buildContactInfoCard(context),
          ),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order ID
        Text(
          'Order ID ORD${job.orderId ?? job.id ?? 'N/A'}',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF555151).withOpacity(0.85),
          ),
        ),
        Gap(8.h),

        // Puja name and Image row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.displayTitle,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF14191E),
                      letterSpacing: 1,
                    ),
                  ),
                  Gap(6.h),
                  Text(
                    job.planType ?? job.plan?.type ?? 'Premium',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF555151).withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.w),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: CustomCacheImage(
                imageUrl: job.orderImages ?? job.displayImageUrl,
                width: 103.714.w,
                height: 78.h,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderStatus(BuildContext context) {
    return JobStepper(
      timelineEntries: job.jobTimeline, // Pass all timeline entries from API
      isPlaced: isJobPlaced,
      isConfirmed: isJobConfirmed,
      isCompleted: isJobCompleted,
      jobPlacedDate: _jobPlacedDate,
      jobConfirmedDate: _jobConfirmedDate,
      jobCompletedDate: _jobCompletedDate,
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final planPrice = job.plan?.price ?? job.price ?? 0.0;
    final addOns = job.addOns ?? [];
      final platformFee = job.platformFee ?? 0.0;
    final addOnsTotal = addOns.fold<double>(0.0, (sum, addOn) => sum + (addOn.price ?? 0.0));
    // Use totalOrderAmount from API if available, otherwise calculate
    final totalPrice = job.panditSalary ?? (planPrice + addOnsTotal);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order summary',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        Gap(15.h),

        // Plan row
        _buildSummaryRow(
          '${job.plan?.type ?? 'Premium'} plan', 
          '₹${planPrice.toStringAsFixed(0)}'
        ),

        // Add-ons section (only show if add-ons exist)
        if (addOns.isNotEmpty) ...[
        Gap(12.h),
        Text(
          'Add on',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Gap(8.h),

          // Dynamic add-ons from API
          ...addOns.map((addOn) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: _buildSummaryRow(
              addOn.name ?? 'Add-on',
              '₹${(addOn.price ?? 0.0).toStringAsFixed(0)}',
            ),
          )),
        ],

        // Platform fee section
        if (platformFee > 0) ...[
          Gap(12.h),
          _buildSummaryRow('Platform fee', '₹-${platformFee.toStringAsFixed(0)}', isBold: true),
        ],
        
        Gap(14.h),
        _buildSummaryRow('Total', '₹${totalPrice.toStringAsFixed(0)}', isBold: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleUserInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: JobUserInfoSection(
        userName: job.customerName ?? job.user?.name ?? 'User Name',
        address: job.orderAddress ?? 'Location not specified',
        dateTime: job.scheduledDate != null
            ? HelperClass.formatDate2(
                DateTime.tryParse(job.scheduledDate!) ?? DateTime.now())
            : '28th Dec 2025 & 11:00 am',
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    // Show user ID card for Processing/Completed
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User ID',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black.withOpacity(0.9),
          ),
        ),
        Gap(12.h),
        JobUserCard(
          userName: job.customerName ?? job.user?.name ?? 'User Name',
          userLocation: (job.user?.city != null || job.user?.state != null)
              ? '${job.user?.city ?? ''}${job.user?.city != null && job.user?.state != null ? ', ' : ''}${job.user?.state ?? ''}'.trim()
              : null,
          userAvatar: job.user?.profileImage,
          followersCount: job.user?.userFollowersCount != null
              ? '${job.user!.userFollowersCount}'
              : null,
          postsCount: job.user?.userPostsCount != null
              ? '${job.user!.userPostsCount}'
              : null,
          phoneNumber: job.mobileNumber ?? job.user?.mobileNumber,
          address: job.orderAddress ?? 'Location not specified',
          dateTime: job.scheduledDate != null
              ? _formatScheduledDateTime(job.scheduledDate!)
              : null,
          showPhoneNumber: isJobConfirmed || isCompleted || isProcessing,
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    // Check is_feedback parameter from model
    // If is_feedback is false, show feedback form (editable)
    // If is_feedback is true, show submitted feedback (read-only)
    if (job.isFeedback == true) {
      // Read-only feedback (already submitted - is_feedback is true)
      // Use actual feedback rating from API
      final rating = job.feedback ?? 0;
      // Use feedbackComments if available
      final review = job.feedbackComments ?? '';
      
      return JobFeedbackWidget(
        initialRating: rating > 0 ? rating : null,
        initialReview: review.isNotEmpty ? review : null,
        isReadOnly: true,
      );
    } else {
      // Editable feedback form (is_feedback is false)
      return JobFeedbackWidget(
        isReadOnly: false,
        onSubmit: (rating, review) {
          // Submit feedback and complete job
          context.read<JobCubit>().completeJob(
                job.jobId ?? job.id.toString(),
                review,
                rating: rating,
              );
        },
      );
    }
  }

  Widget _buildCancelInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 18.sp,
          color: Colors.grey.shade500,
        ),
        Gap(8.w),
        Expanded(
          child: Text(
            "Job cancellation is not allowed after confirmation. and Once's you confirm your order you will receive user number",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    // New job - Accept/Reject buttons
    if (isNewJob) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Accept button
            Expanded(
              child: SizedBox(
                height: 45.h,
                child: ElevatedButton(
                  onPressed: () => _handleAccept(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12B76A), // Green
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Gap(12.w),
            // Reject button
            Expanded(
              child: SizedBox(
                height: 45.h,
                child: OutlinedButton(
                  onPressed: () => _handleReject(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF04438)), // Red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF04438),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Processing (before confirmation) - Cancel Order button
    if (isProcessing && !isJobConfirmed) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 45.h,
          child: ElevatedButton(
            onPressed: () => _handleCancelOrder(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.orangeColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Cancel order',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // No buttons for other states
    return const SizedBox.shrink();
  }

  void _handleAccept(BuildContext context) async {
    // Show accept confirmation
    final result = await showOrderAcceptedDialog(context);
    if (result == true) {
      // Accept the job
      context.read<JobCubit>().acceptJob(job.jobId ?? job.id.toString());
      // Go back to job list
      Navigator.of(context).pop();
    }
  }

  void _handleReject(BuildContext context) async {
    // Show reject confirmation
    final result = await showOrderRejectedDialog(context);
    if (result == true) {
      // Reject the job
      context.read<JobCubit>().rejectJob(job.jobId ?? job.id.toString());
      // Go back to job list
      Navigator.of(context).pop();
    }
  }

  void _handleCancelOrder(BuildContext context) async {
    await showCancelOrderDialog(context);
    // Cancel is not allowed after confirmation, so just show info
  }

  Widget _buildContactInfoCard(BuildContext context) {
    // Floating card positioned as per Figma design
    return BlocBuilder<JobCubit, JobState>(
      builder: (context, state) {
        String email = 'N/A';
        String contactNumber = 'N/A';
        
        if (state is JobLoadingState) {
          email = state.helpContactEmail ?? 'N/A';
          contactNumber = state.helpContactNumber ?? 'N/A';
        }
        
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.all(21.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xFFD9D9D9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email ID
            _buildContactRow(
              icon: Icons.person_outline,
              label: 'Email Id',
                  value: email,
            ),
            Gap(10.h),
            // Contact Number
            _buildContactRow(
              icon: Icons.phone_outlined,
              label: 'Contact Number',
                  value: contactNumber,
            ),
          ],
        ),
      ),
        );
      },
    );
  }
  
  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: Colors.black.withOpacity(0.9),
            ),
            Gap(8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
          ],
        ),
        Gap(4.h),
        Padding(
          padding: EdgeInsets.only(left: 28.w),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
