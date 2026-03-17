import 'package:flutter/material.dart';

class JobModel {
  int? id;
  String? jobId;
  int? orderId;
  String? title;
  String? description;
  String? status;
  String? orderImages;
  String? priority;
  String? createdAt;
  String? updatedAt;
  String? scheduledDate;
  String? assignedTo;
  String? assignedBy;
  String? serviceType;
  String? planType;
  double? price;
  String? imageUrl;
  String? orderAddress;
  String? mobileNumber;
  String? customerName;
  List<JobTracking>? jobTracking;
  bool? isAccepted;
  bool? isRejected;
  String? rejectionReason;
  String? completionNotes;
  User? user;
  ServiceSection? serviceSection;
  Plan? plan;
  
  // New fields from API
  double? totalOrderAmount;
  double? panditSalary;
  double? platformFee;
  List<JobTimeline>? jobTimeline;
  bool? isFeedback;
  int? feedback; // Rating from feedback (1-5)
  String? feedbackComments; // Comments from feedback
  String? paymentOrderId;
  List<AddOn>? addOns;

  JobModel({
    this.id,
    this.jobId,
    this.orderId,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.orderImages,
    this.createdAt,
    this.updatedAt,
    this.scheduledDate,
    this.assignedTo,
    this.assignedBy,
    this.serviceType,
    this.planType,
    this.price,
    this.imageUrl,
    this.orderAddress,
    this.mobileNumber,
    this.customerName,
    this.jobTracking,
    this.isAccepted,
    this.isRejected,
    this.rejectionReason,
    this.completionNotes,
    this.user,
    this.serviceSection,
    this.plan,
    this.totalOrderAmount,
    this.panditSalary,
    this.platformFee,
    this.jobTimeline,
    this.isFeedback,
    this.feedback,
    this.feedbackComments,
    this.paymentOrderId,
    this.addOns,
  });

  /// Safely convert any JSON value to String?
  static String? _safeStringFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    return value.toString();
  }

  /// Safely convert any JSON value to bool?
  static bool? _safeBoolFromJson(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    if (value is num) return value != 0;
    return null;
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Handle new nested structure
    final orderDetails = json["order_details"] as Map<String, dynamic>?;
    final jobSummary = json["Job_Summary"] as Map<String, dynamic>?;
    final userDetails = json["user_details"] as Map<String, dynamic>?;
    
    // Extract data from nested structure or fallback to flat structure
    final jobId = jobSummary?["job_id"] ?? json["job_id"] ?? json["id"];
    final orderId = orderDetails?["order_id"] ?? json["order_id"] ?? json["orderId"];
    final orderName = orderDetails?["order_name"] ?? json["order_name"] ?? json["title"] ?? '';
    final orderImages = orderDetails?["order_images"] ?? json["order_images"] ?? json["orderImages"];
    final status = jobSummary?["status"] ?? json["status"];
    final paymentOrderId = orderDetails?["payment_order_id"] ?? json["payment_order_id"];
    
    // Plan from order_details
    final planJson = orderDetails?["plan"] ?? json["plan"];
    final plan = planJson != null ? Plan.fromJson(planJson as Map<String, dynamic>) : null;
    
    // Job Summary fields
    final totalOrderAmount = (jobSummary?["total_order_amount"] ?? json["total_order_amount"]) as num?;
    final panditSalary = (jobSummary?["pandit_salary"] ?? json["pandit_salary"]) as num?;
    final platformFee = (jobSummary?["platform_fee_30_percent"] ?? json["platform_fee_30_percent"]) as num?;
    
    // Add-ons from Job_Summary
    final addOnsJson = jobSummary?["add_ons"] ?? json["add_ons"];
    final addOns = addOnsJson != null
        ? List<AddOn>.from((addOnsJson as List).map((x) => AddOn.fromJson(x as Map<String, dynamic>)))
        : null;
    
    // User details
    final userJson = userDetails ?? json["user"];
    final user = userJson != null ? User.fromJson(userJson as Map<String, dynamic>) : null;
    
    // Scheduled datetime from user_details
    final scheduledDatetime = userDetails?["scheduled_datetime"] ?? json["scheduled_datetime"] ?? json["scheduled_date"] ?? json["scheduledDate"];
    final orderAddress = userDetails?["order_address"] ?? json["order_address"];
    
    // Job timeline
    final jobTimelineJson = json["job_timeline"] ?? json["job_tracking"];
    final jobTimeline = jobTimelineJson != null
        ? List<JobTimeline>.from((jobTimelineJson as List).map((x) => JobTimeline.fromJson(x as Map<String, dynamic>)))
        : null;
    
    // User image from user_details
    final userDp = userDetails?["user_dp"] ?? json["user_dp"] ?? json["user_image"] ?? json["image_url"] ?? json["imageUrl"];
    
    return JobModel(
        id: jobId,
        jobId: jobId?.toString(),
        orderId: orderId,
        title: orderName,
        description: json["description"],
        status: status,
        orderImages: orderImages,
        priority: json["priority"],
        createdAt: json["created_at"] ?? json["createdAt"],
        updatedAt: json["updated_at"] ?? json["updatedAt"],
        scheduledDate: scheduledDatetime,
        assignedTo: json["assigned_to"] ?? json["assignedTo"],
        assignedBy: json["admin_name"] ?? json["assigned_by"] ?? json["assignedBy"],
        serviceType: json["service_type"] ?? json["serviceType"],
        planType: plan?.type ?? json["plan_type"] ?? json["planType"],
        price: (plan?.price ?? json["price"] as num?)?.toDouble(),
        orderAddress: orderAddress,
        mobileNumber: user?.mobileNumber ?? userDetails?["phone"] ?? json["user_phone"] ?? json["mobile_number"] ?? json["mobileNumber"],
        customerName: user?.name ?? userDetails?["name"] ?? json["user_name"] ?? json["customer_name"] ?? json["customerName"],
        
        // New fields mapping
        totalOrderAmount: totalOrderAmount?.toDouble(),
        panditSalary: panditSalary?.toDouble(),
        platformFee: platformFee?.toDouble(),
        
        // Job Timeline mapping
        jobTimeline: jobTimeline,
        
        // Old job tracking (keep for backward compatibility)
        jobTracking: json["job_tracking"] == null
            ? null
            : List<JobTracking>.from(
                (json["job_tracking"] as List).map((x) => JobTracking.fromJson(x as Map<String, dynamic>))),
        
        isAccepted: _safeBoolFromJson(json["is_accepted"] ?? json["isAccepted"]),
        isRejected: _safeBoolFromJson(json["is_rejected"] ?? json["isRejected"]),
        rejectionReason: _safeStringFromJson(json["rejection_reason"] ?? json["rejectionReason"]),
        completionNotes: _safeStringFromJson(
          json["pandit_feedback_details"]?["comments"] ?? json["pandit_feedback"]
        ),
        
        user: user,
        imageUrl: userDp,
        serviceSection: json["service_section"] == null
            ? null
            : ServiceSection.fromJson(json["service_section"] as Map<String, dynamic>),
        plan: plan,
        isFeedback: _safeBoolFromJson(json["is_feedback"] ?? json["isFeedback"]),
        feedback: json["feedback"] != null ? (json["feedback"] as num?)?.toInt() : null,
        feedbackComments: _safeStringFromJson(json["comments"]),
        paymentOrderId: paymentOrderId,
        addOns: addOns,
      );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "job_id": jobId,
        "order_id": orderId,
        "order_name": title,
        "title": title,
        "description": description,
        "status": status,
        "priority": priority,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "scheduled_datetime": scheduledDate,
        "scheduled_date": scheduledDate,
        "assigned_to": assignedTo,
        "assigned_by": assignedBy,
        "service_type": serviceType,
        "plan_type": planType,
        "price": price,
        "image_url": imageUrl,
        "order_address": orderAddress,
        "mobile_number": mobileNumber,
        "user_phone": mobileNumber,
        "customer_name": customerName,
        "user_name": customerName,
        "total_order_amount": totalOrderAmount,
        "pandit_salary": panditSalary,
        "platform_fee_30_percent": platformFee,
        "job_timeline": jobTimeline == null
            ? []
            : List<dynamic>.from(jobTimeline!.map((x) => x.toJson())),
        "job_tracking": jobTracking == null
            ? []
            : List<dynamic>.from(jobTracking!.map((x) => x.toJson())),
        "is_accepted": isAccepted,
        "is_rejected": isRejected,
        "rejection_reason": rejectionReason,
        "completion_notes": completionNotes,
        "user": user?.toJson(),
        "service_section": serviceSection?.toJson(),
        "plan": plan?.toJson(),
        "is_feedback": isFeedback,
        "feedback": feedback,
        "comments": feedbackComments,
        "payment_order_id": paymentOrderId,
        "add_ons": addOns == null
            ? []
            : List<dynamic>.from(addOns!.map((x) => x.toJson())),
      };
}

// New JobTimeline class for the timeline feature
class JobTimeline {
  String? status;
  String? remarks;
  String? date;
  String? time;

  JobTimeline({
    this.status,
    this.remarks,
    this.date,
    this.time,
  });

  factory JobTimeline.fromJson(Map<String, dynamic> json) => JobTimeline(
        status: json["status"],
        remarks: json["remarks"],
        date: json["date"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "remarks": remarks,
        "date": date,
        "time": time,
      };

  // Helper getter for full datetime display
  String get fullDateTime => '${date ?? ''} ${time ?? ''}'.trim();
  
  // Check if remarks exist
  bool get hasRemarks => remarks != null && remarks!.isNotEmpty;
}

// Old JobTracking class (keep for backward compatibility)
class JobTracking {
  String? createdAt;
  String? jobStatus;
  String? notes;

  JobTracking({this.createdAt, this.jobStatus, this.notes});

  factory JobTracking.fromJson(Map<String, dynamic> json) => JobTracking(
        createdAt: json["created_at"],
        jobStatus: json["job_status"],
        notes: json["notes"],
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt,
        "job_status": jobStatus,
        "notes": notes,
      };
}

class User {
  int? id;
  String? name;
  String? email;
  String? mobileNumber;
  String? profileImage;
  String? city;
  String? state;
  String? scheduledDatetime;
  String? orderAddress;
  int? userFollowersCount;
  int? userPostsCount;

  User({
    this.id,
    this.name,
    this.email,
    this.mobileNumber,
    this.profileImage,
    this.city,
    this.state,
    this.scheduledDatetime,
    this.orderAddress,
    this.userFollowersCount,
    this.userPostsCount,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobileNumber: json["phone"] ?? json["mobile_number"] ?? json["mobileNumber"],
        profileImage: json["user_dp"] ?? json["profile_image"] ?? json["profileImage"],
        city: json["city"],
        state: json["state"],
        scheduledDatetime: json["scheduled_datetime"],
        orderAddress: json["order_address"],
        userFollowersCount: json["user_followers_count"],
        userPostsCount: json["user_posts_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": mobileNumber,
        "mobile_number": mobileNumber,
        "user_dp": profileImage,
        "profile_image": profileImage,
        "city": city,
        "state": state,
        "scheduled_datetime": scheduledDatetime,
        "order_address": orderAddress,
        "user_followers_count": userFollowersCount,
        "user_posts_count": userPostsCount,
      };
}

class AddOn {
  int? id;
  String? name;
  double? price;

  AddOn({
    this.id,
    this.name,
    this.price,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
        id: json["id"],
        name: json["name"],
        price: (json["price"] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
      };
}

class ServiceSection {
  int? id;
  String? name;
  String? images;
  String? description;

  ServiceSection({
    this.id,
    this.name,
    this.images,
    this.description,
  });

  factory ServiceSection.fromJson(Map<String, dynamic> json) => ServiceSection(
        id: json["id"],
        name: json["name"],
        images: json["images"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "images": images,
        "description": description,
      };
}

class Plan {
  int? id;
  String? type;
  double? price;

  Plan({this.id, this.type, this.price});

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"],
        type: json["type"],
        price: (json["price"] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "price": price,
      };
}

// Response wrapper class for API list response
class JobListResponse {
  int? count;
  List<JobModel>? results;

  JobListResponse({this.count, this.results});

  factory JobListResponse.fromJson(Map<String, dynamic> json) => JobListResponse(
        count: json["count"],
        results: json["results"] == null
            ? []
            : List<JobModel>.from(
                json["results"]!.map((x) => JobModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
      };
}

// UI Helper extension for JobModel
extension JobModelUIHelpers on JobModel {
  String get displayJobId => jobId ?? 'JOB${id ?? 'N/A'}';
  String get displayOrderId => orderId?.toString() ?? 'N/A';
  String get displayTitle => title ?? serviceSection?.name ?? 'Service Job';
  String get displaySubtitle => planType ?? plan?.type ?? 'Standard';
  String get displayImageUrl => imageUrl ?? serviceSection?.images ?? '';
  String get displayPrice => '₹${price?.toStringAsFixed(0) ?? totalOrderAmount?.toStringAsFixed(0) ?? '0'}';
  String get displayTotalAmount => '₹${totalOrderAmount?.toStringAsFixed(0) ?? '0'}';
  String get displayPanditSalary => '₹${panditSalary?.toStringAsFixed(0) ?? '0'}';
  String get displayPlatformFee => '₹${platformFee?.toStringAsFixed(0) ?? '0'}';

  // Customer display helpers
  String get displayCustomerName => customerName ?? user?.name ?? 'Unknown Customer';
  String get displayCustomerPhone => mobileNumber ?? user?.mobileNumber ?? 'N/A';
  
  // Timeline helpers
  bool get hasTimeline => jobTimeline != null && jobTimeline!.isNotEmpty;
  int get timelineCount => jobTimeline?.length ?? 0;
  JobTimeline? get latestTimelineEntry => hasTimeline ? jobTimeline!.last : null;

  static const Map<String, String> statusLabels = {
    'Pending': 'Pending',
    'Requested': 'Requested',
    'Assigned': 'Assigned',
    'Accepted': 'Accepted',
    'In Progress': 'In Progress',
    'Completed': 'Completed',
    'Rejected': 'Rejected',
    'Cancelled': 'Cancelled',
    'Job Assigned': 'Job Assigned',
    'Job Placed': 'Job Placed',
    'Job Confirmed': 'Job Confirmed',
  };

  static const Map<String, String> priorityLabels = {
    'Low': 'Low',
    'Medium': 'Medium',
    'High': 'High',
    'Urgent': 'Urgent',
  };

  String get statusLabel => statusLabels[status] ?? status ?? 'Unknown';
  String get priorityLabel => priorityLabels[priority] ?? priority ?? 'Medium';

  bool get canAccept => status == 'Assigned' || status == 'Pending' || status == 'Requested' || status == 'Job Assigned';
  bool get canReject => status == 'Assigned' || status == 'Pending' || status == 'Requested' || status == 'Job Assigned';
  bool get canComplete => status == 'Accepted' || status == 'In Progress' || status == 'Job Confirmed';
  bool get canAssign => status == 'Pending' || status == 'Requested';

  Color get statusColor {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'requested':
        return Colors.orange;
      case 'assigned':
      case 'job assigned':
        return Colors.blue;
      case 'accepted':
      case 'job placed':
        return Colors.green;
      case 'in progress':
        return Colors.purple;
      case 'completed':
      case 'job confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color get priorityColor {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Extension for formatting dates from the API
extension DateTimeFormatting on String {
  String formatScheduledDate() {
    try {
      final dateTime = DateTime.parse(this);
      return '${dateTime.day}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return this;
    }
  }
}