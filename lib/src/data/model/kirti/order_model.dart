import 'package:intl/intl.dart';



class OrderModel {
  int? id;
  User? user;
  List<AddOn>? addOns;
  double? tax;
  bool? isFeedback;
  String? transactionId;
  String? createdAt;
  String? updatedAt;
  String? name;
  String? address;
  String? status;
  bool? paymentStatus;
  String? mobileNumber;
  String? scheduledDatetime;
  dynamic otp1;
  dynamic otp2;
  bool? otp1Verified;
  bool? otp2Verified;
  bool? isJobFeedback;
  String? jobStatus;
  ServiceSection? serviceSection;
  dynamic pandit;
  Plan? plan;
  dynamic job;
  dynamic orderFeedback;
  dynamic jobFeedback;
  List<OrderTracking>? orderTracking;
  dynamic feedback;

  OrderModel({
    this.id,
    this.user,
    this.addOns,
    this.tax,
    this.isFeedback,
    this.transactionId,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.address,
    this.status,
    this.paymentStatus,
    this.mobileNumber,
    this.scheduledDatetime,
    this.otp1,
    this.otp2,
    this.otp1Verified,
    this.otp2Verified,
    this.isJobFeedback,
    this.jobStatus,
    this.serviceSection,
    this.pandit,
    this.plan,
    this.job,
    this.orderFeedback,
    this.jobFeedback,
    this.orderTracking,
    this.feedback,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json["id"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        addOns: json["add_ons"] == null
            ? []
            : List<AddOn>.from(json["add_ons"]!.map((x) => AddOn.fromJson(x))),
        tax: (json["tax"] as num?)?.toDouble(),
        isFeedback: json["is_feedback"],
        transactionId: json["transaction_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        name: json["name"],
        address: json["address"],
        status: json["status"],
        paymentStatus: json["payment_status"],
        mobileNumber: json["mobile_number"],
        scheduledDatetime: json["scheduled_datetime"],
        otp1: json["otp1"],
        otp2: json["otp2"],
        otp1Verified: json["otp1_verified"],
        otp2Verified: json["otp2_verified"],
        isJobFeedback: json["is_job_feedback"],
        jobStatus: json["job_status"],
        serviceSection: json["service_section"] == null
            ? null
            : ServiceSection.fromJson(json["service_section"]),
        pandit: json["pandit"],
        plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
        job: json["job"],
        orderFeedback: json["order_feedback"],
        jobFeedback: json["job_feedback"],
        orderTracking: json["order_tracking"] == null
            ? []
            : List<OrderTracking>.from(
                json["order_tracking"]!.map((x) => OrderTracking.fromJson(x))),
        feedback: json["feedback"],
      );
}

class AddOn {
  int? id;
  String? title;
  double? price;
  String? quantity;

  AddOn({this.id, this.title, this.price, this.quantity});

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
        id: json["id"],
        title: json["title"],
        price: (json["price"] as num?)?.toDouble(),
        quantity: json["quantity"],
      );
}

class OrderTracking {
  String? createdAt;
  String? orderStatus;

  OrderTracking({this.createdAt, this.orderStatus});

  factory OrderTracking.fromJson(Map<String, dynamic> json) => OrderTracking(
        createdAt: json["created_at"],
        orderStatus: json["order_status"],
      );
}

class Plan {
  int? id;
  String? type;
  double? price;
  Description? description;
  int? pooja;

  Plan({
    this.id,
    this.type,
    this.price,
    this.description,
    this.pooja,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"],
        type: json["type"],
        price: (json["price"] as num?)?.toDouble(),
        description: json["description"] == null
            ? null
            : Description.fromJson(json["description"]),
        pooja: json["pooja"],
      );
}

class Description {
  String? delta;
  String? html;

  Description({
    this.delta,
    this.html,
  });

  factory Description.fromJson(Map<String, dynamic> json) => Description(
        delta: json["delta"],
        html: json["html"],
      );
}

class ServiceSection {
  int? id;
  List<Service>? service;
  String? name;
  Description? benefits;
  Description? steps;
  String? metaDescription;
  Description? description;
  String? duration;
  String? images;
  int? star;

  ServiceSection({
    this.id,
    this.service,
    this.name,
    this.benefits,
    this.steps,
    this.metaDescription,
    this.description,
    this.duration,
    this.images,
    this.star,
  });

  factory ServiceSection.fromJson(Map<String, dynamic> json) => ServiceSection(
        id: json["id"],
        service: json["service"] == null
            ? []
            : List<Service>.from(json["service"]!.map((x) => Service.fromJson(x))),
        name: json["name"],
        benefits: json["benefits"] == null
            ? null
            : Description.fromJson(json["benefits"]),
        steps: json["steps"] == null
            ? null
            : Description.fromJson(json["steps"]),
        metaDescription: json["meta_description"],
        description: json["description"] == null
            ? null
            : Description.fromJson(json["description"]),
        duration: json["duration"],
        images: json["images"],
        star: json["star"],
      );
}

class Service {
  int? id;
  String? type;

  Service({
    this.id,
    this.type,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        type: json["type"],
      );
}

class User {
  int? id;
  String? dp;
  String? backgroundImage;
  String? name;
  String? email;
  dynamic biography;
  dynamic phone;
  String? tableName;

  User({
    this.id,
    this.dp,
    this.backgroundImage,
    this.name,
    this.email,
    this.biography,
    this.phone,
    this.tableName,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        dp: json["dp"],
        backgroundImage: json["background_image"],
        name: json["name"],
        email: json["email"],
        biography: json["biography"],
        phone: json["phone"],
        tableName: json["table_name"],
      );
}

// UI Helper extension for OrderModel
extension OrderModelUIHelpers on OrderModel {
  String get orderId => id?.toString() ?? '-';
  String get title => serviceSection?.name ?? '-';
  String get subtitle => plan?.type ?? '-';
  String get imageUrl => serviceSection?.images ?? '';

  static const Map<String, String> statusLabels = {
    'Pending': 'Pending',
    'Order Placed': 'Order Placed',
    'Order Confirmed': 'Order Confirmed',
    'Prepration Completed': 'Preparation Completed',
    'Order in Execution': 'Order in Execution',
    'Order Completed': 'Order Completed',
  };

  int get currentStep {
    if (orderTracking?.isEmpty ?? true) return -1;
    final currentStatus = orderTracking!.last.orderStatus;
    return statusLabels.keys.toList().indexOf(currentStatus ?? '');
  }

  List<Map<String, String>> get statusSteps {
    return statusLabels.entries.map((entry) {
      final statusKey = entry.key;
      final statusLabel = entry.value;

      final trackingEntry = orderTracking?.firstWhere(
        (track) => track.orderStatus == statusKey,
        orElse: () => OrderTracking(),
      );

      final date = trackingEntry?.createdAt != null
          ? DateFormat('MMM d, yyyy - h:mm a').format(DateTime.parse(trackingEntry!.createdAt!))
          : '';

      return {
        'label': statusLabel,
        'date': date,
      };
    }).toList();
  }

  bool get showFeedback => status == 'Order Completed';
  
  String? get infoNote {
    if (status == 'Order Placed') {
      return 'Order cancellation is not allowed after confirmation.';
    }
    return null;
  }

  bool get canCancel => 
      status != 'Order Completed' && 
    
      status != 'Order Confirmed' ;

  // Helper methods for pandit feedback
  // Check both in job object and root level (in case entire response is in job field)
  bool? get hasPanditFeedback {
    if (job != null && job is Map<String, dynamic>) {
      final jobData = job as Map<String, dynamic>;
      // Check if pandit_feedback exists directly in job object
      // This handles the case where the entire API response (with pandit_feedback at root) is stored in job field
      if (jobData.containsKey('pandit_feedback')) {
        final feedback = jobData['pandit_feedback'];
        if (feedback is bool) {
          return feedback;
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? get panditFeedbackDetails {
    if (job != null && job is Map<String, dynamic>) {
      final jobData = job as Map<String, dynamic>;
      // Check for pandit_feedback_details directly in job object
      // This handles the case where the entire API response is stored in job field
      if (jobData.containsKey('pandit_feedback_details')) {
        final feedbackDetails = jobData['pandit_feedback_details'];
        if (feedbackDetails != null && feedbackDetails is Map<String, dynamic>) {
          return Map<String, dynamic>.from(feedbackDetails);
        }
      }
    }
    return null;
  }

  int? get panditFeedbackRating {
    final details = panditFeedbackDetails;
    if (details != null && details['rating'] != null) {
      return (details['rating'] as num?)?.toInt();
    }
    return null;
  }

  String? get panditFeedbackComments {
    final details = panditFeedbackDetails;
    return details?['comments'] as String?;
  }

  String? get panditFeedbackBy {
    final details = panditFeedbackDetails;
    return details?['feedback_by'] as String?;
  }

  List<Map<String, dynamic>> get summaryRows {
    final double planPrice = plan?.price ?? 0.0;
    final double addOnsTotal = addOns?.fold(0.0, (sum, item) => (sum ??0 + (item.price ?? 0.0))) ?? 0.0;
    final double total = planPrice + addOnsTotal;

    return [
      {'label': 'Plan (${plan?.type ?? 'N/A'})', 'value': '₹${planPrice.toStringAsFixed(2)}'},
      ...addOns?.map((addon) => {'label': 'Add-on (${addon.title ?? 'N/A'})', 'value': '₹${(addon.price ?? 0.0).toStringAsFixed(2)}'}).toList() ?? [],
      {'label': 'Total', 'value': '₹${total.toStringAsFixed(2)}', 'isBold': true},
    ];
  }
}