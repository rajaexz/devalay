import 'package:flutter/material.dart';

class AssignModel {
  int? id;
  String? jobId;
  String? title;
  String? description;
  String? status;
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
  String? address;
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

  AssignModel({
    this.id,
    this.jobId,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.createdAt,
    this.updatedAt,
    this.scheduledDate,
    this.assignedTo,
    this.assignedBy,
    this.serviceType,
    this.planType,
    this.price,
    this.imageUrl,
    this.address,
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
  });

  factory AssignModel.fromJson(Map<String, dynamic> json) => AssignModel(
        id: json["id"],
        jobId: json["job_id"] ?? json["jobId"],
        title: json["title"],
        description: json["description"],
        status: json["status"],
        priority: json["priority"],
        createdAt: json["created_at"] ?? json["createdAt"],
        updatedAt: json["updated_at"] ?? json["updatedAt"],
        scheduledDate: json["scheduled_date"] ?? json["scheduledDate"],
        assignedTo: json["assigned_to"] ?? json["assignedTo"],
        assignedBy: json["assigned_by"] ?? json["assignedBy"],
        serviceType: json["service_type"] ?? json["serviceType"],
        planType: json["plan_type"] ?? json["planType"],
        price: (json["price"] as num?)?.toDouble(),
        imageUrl: json["image_url"] ?? json["imageUrl"],
        address: json["address"],
        mobileNumber: json["mobile_number"] ?? json["mobileNumber"],
        customerName: json["customer_name"] ?? json["customerName"],
        jobTracking: json["job_tracking"] == null
            ? []
            : List<JobTracking>.from(
                json["job_tracking"]!.map((x) => JobTracking.fromJson(x))),
        isAccepted: json["is_accepted"] ?? json["isAccepted"],
        isRejected: json["is_rejected"] ?? json["isRejected"],
        rejectionReason: json["rejection_reason"] ?? json["rejectionReason"],
        completionNotes: json["completion_notes"] ?? json["completionNotes"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        serviceSection: json["service_section"] == null
            ? null
            : ServiceSection.fromJson(json["service_section"]),
        plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "job_id": jobId,
        "title": title,
        "description": description,
        "status": status,
        "priority": priority,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "scheduled_date": scheduledDate,
        "assigned_to": assignedTo,
        "assigned_by": assignedBy,
        "service_type": serviceType,
        "plan_type": planType,
        "price": price,
        "image_url": imageUrl,
        "address": address,
        "mobile_number": mobileNumber,
        "customer_name": customerName,
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
      };
}

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

  User({
    this.id,
    this.name,
    this.email,
    this.mobileNumber,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobileNumber: json["mobile_number"] ?? json["mobileNumber"],
        profileImage: json["profile_image"] ?? json["profileImage"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile_number": mobileNumber,
        "profile_image": profileImage,
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

// UI Helper extension for JobModel
extension AssignModelUIHelpers on AssignModel {
  String get displayJobId => jobId ?? 'JOB${id ?? 'N/A'}';
  String get displayTitle => title ?? serviceSection?.name ?? 'Service Job';
  String get displaySubtitle => planType ?? plan?.type ?? 'Standard';
  String get displayImageUrl => imageUrl ?? serviceSection?.images ?? '';
  String get displayPrice => '₹${price?.toStringAsFixed(0) ?? '0'}';

  static const Map<String, String> statusLabels = {
    'Pending': 'Pending',
    'Assigned': 'Assigned',
    'Accepted': 'Accepted',
    'In Progress': 'In Progress',
    'Completed': 'Completed',
    'Rejected': 'Rejected',
    'Cancelled': 'Cancelled',
  };

  static const Map<String, String> priorityLabels = {
    'Low': 'Low',
    'Medium': 'Medium',
    'High': 'High',
    'Urgent': 'Urgent',
  };

  String get statusLabel => statusLabels[status] ?? status ?? 'Unknown';
  String get priorityLabel => priorityLabels[priority] ?? priority ?? 'Medium';

  bool get canAccept => status == 'Assigned' || status == 'Pending';
  bool get canReject => status == 'Assigned' || status == 'Pending';
  bool get canComplete => status == 'Accepted' || status == 'In Progress';
  bool get canAssign => status == 'Pending';

  Color get statusColor {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'in progress':
        return Colors.purple;
      case 'completed':
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
