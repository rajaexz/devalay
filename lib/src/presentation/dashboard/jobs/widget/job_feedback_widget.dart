import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// Job Feedback Widget - Figma Design
/// Star rating + review text field + submit button
class JobFeedbackWidget extends StatefulWidget {
  final int? initialRating;
  final String? initialReview;
  final bool isReadOnly;
  final Function(int rating, String review)? onSubmit;

  const JobFeedbackWidget({
    super.key,
    this.initialRating,
    this.initialReview,
    this.isReadOnly = false,
    this.onSubmit,
  });

  @override
  State<JobFeedbackWidget> createState() => _JobFeedbackWidgetState();
}

class _JobFeedbackWidgetState extends State<JobFeedbackWidget> {
  late int _rating;
  late TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _reviewController = TextEditingController(text: widget.initialReview ?? '');
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title - Figma: 18sp, letter spacing 1
        Text(
          'Feedback',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        Gap(22.h),
        
        if (widget.isReadOnly) ...[
          // Read-only mode - show rating and review (when is_feedback is true)
          if (widget.initialRating != null && widget.initialRating! > 0) ...[
            _buildStarRating(readOnly: true),
            Gap(15.h),
          ],
          if (widget.initialReview != null && widget.initialReview!.isNotEmpty)
            Text(
              widget.initialReview!,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF555151),
                height: 1.4,
              ),
            ),
        ] else ...[
          // Editable mode - show feedback form (when is_feedback is false)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rate your experience section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate your experience',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF555151),
                      height: 1.4,
                    ),
                  ),
                  Gap(10.h),
                  _buildStarRating(readOnly: false),
                ],
              ),
              Gap(15.h),
              
              // Write your review section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write your review',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF555151),
                      height: 1.4,
                    ),
                  ),
                  Gap(10.h),
                  Container(
                    height: 82.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12.w),
                        hintText: '',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(22.h),
              
              // Submit button - Figma: height 35, border radius 4, orange background
              SizedBox(
                width: double.infinity,
                height: 35.h,
                child: ElevatedButton(
                  onPressed: _rating > 0
                      ? () {
                          if (widget.onSubmit != null) {
                            widget.onSubmit!(_rating, _reviewController.text.trim());
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9500).withOpacity(0.75),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStarRating({required bool readOnly}) {
    return Row(
      children: List.generate(5, (index) {
        final isActive = index < _rating;
        return GestureDetector(
          onTap: readOnly
              ? null
              : () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
          child: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Icon(
              isActive ? Icons.star : Icons.star_border,
              color: isActive ? const Color(0xFFFFC107) : Colors.grey.shade400,
              size: 24.sp,
            ),
          ),
        );
      }),
    );
  }
}

/// Warning Message Box - Figma Design
/// Red/orange box with warning text
class JobWarningMessage extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? textColor;

  const JobWarningMessage({
    super.key,
    required this.message,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFFDF2EE),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12.sp,
          color: textColor ?? Colors.red,
          height: 1.4,
        ),
      ),
    );
  }
}

