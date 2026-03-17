// admin_order_detail_model.dart

class AdminOrderDetailResponse {
  final int? count;
  final String? next;
  final String? previous;
  final List<AdminOrderDetailModel>? results;

  AdminOrderDetailResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AdminOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return AdminOrderDetailResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((e) => AdminOrderDetailModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

class AdminOrderDetailModel {
  final int? id;
  final UserModel? user;
  final List<AddOnModel>? addOns;
  final double? tax;
  final String? paymentOrderId;
  final String? createdAt;
  final String? address;
  final String? scheduledDatetime;
  final String? status;
  final PlanModel? plan;
  final ServiceSectionModel? serviceSection;
  final double? totalAmount;
  final List<RequestedPanditModel>? requestedPandits;


  AdminOrderDetailModel({
    this.id,
    this.user,
    this.addOns,
    
    this.tax,
    this.paymentOrderId,
    this.createdAt,
    this.address,
    this.scheduledDatetime,
    this.status,
    this.plan,
    this.serviceSection,
    this.totalAmount,
    this.requestedPandits,

  });

  factory AdminOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderDetailModel(
      id: json['id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      addOns: json['add_ons'] != null
          ? (json['add_ons'] as List)
              .map((e) => AddOnModel.fromJson(e))
              .toList()
          : null,
      tax: json['tax']?.toDouble(),
 
      paymentOrderId: json['payment_order_id'],
      createdAt: json['created_at'],
      address: json['address'],
      scheduledDatetime: json['scheduled_datetime'],
      status: json['status'],
      plan: json['plan'] != null ? PlanModel.fromJson(json['plan']) : null,
      serviceSection: json['service_section'] != null
          ? ServiceSectionModel.fromJson(json['service_section'])
          : null,
      totalAmount: json['total_amount']?.toDouble(),
      requestedPandits: json['requested_pandits'] != null
          ? (json['requested_pandits'] as List)
              .map((e) => RequestedPanditModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'add_ons': addOns?.map((e) => e.toJson()).toList(),
      'tax': tax,
      'payment_order_id': paymentOrderId,
      'created_at': createdAt,
      'address': address,
      'scheduled_datetime': scheduledDatetime,
      'status': status,
      'plan': plan?.toJson(),
      'service_section': serviceSection?.toJson(),
      'total_amount': totalAmount,
      'requested_pandits': requestedPandits?.map((e) => e.toJson()).toList(),
   
    };
  }
}

class UserModel {
  final int? id;
  final String? dp;
  final String? name;
  final String? phone;
  final String? city;
  final String? state;
  final int? totalFollowers;
  final int? totalPosts;

  UserModel({
    this.id,
    this.dp,
    this.name,
    this.phone,
    this.city,
    this.state,
    this.totalFollowers,
    this.totalPosts,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      dp: json['dp'],
      name: json['name'],
      phone: json['phone'],
      city: json['city'],
      state: json['state'],
      totalFollowers: json['total_followers'],
      totalPosts: json['total_posts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dp': dp,
      'name': name,
      'phone': phone,
      'city': city,
      'state': state,
      'total_followers': totalFollowers,
      'total_posts': totalPosts,
    };
  }
}

class AddOnModel {
  final int? id;
  final String? name;
  final double? price;

  AddOnModel({
    this.id,
    this.name,
    this.price,
  });

  factory AddOnModel.fromJson(Map<String, dynamic> json) {
    return AddOnModel(
      id: json['id'],
      name: json['name'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}

class PlanModel {
  final int? id;
  final String? type;
  final double? price;

  PlanModel({
    this.id,
    this.type,
    this.price,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      type: json['type'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'price': price,
    };
  }
}

class ServiceSectionModel {
  final int? id;
  final String? name;
  final List<ServiceModel>? service;
  final String? images;

  ServiceSectionModel({
    this.id,
    this.name,
    this.service,
    this.images,
  });

  factory ServiceSectionModel.fromJson(Map<String, dynamic> json) {
    return ServiceSectionModel(
      id: json['id'],
      name: json['name'],
      service: json['service'] != null
          ? (json['service'] as List)
              .map((e) => ServiceModel.fromJson(e))
              .toList()
          : null,
      images: json['images'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service': service?.map((e) => e.toJson()).toList(),
      'images': images,
    };
  }
}

class ServiceModel {
  final int? id;
  final String? type;

  ServiceModel({
    this.id,
    this.type,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}

class RequestedPanditModel {
  final int? jobId;
  final int? panditId;
  final String? name;
  final String? phone;
  final String? city;
  final String? state;
  final String? status;
  final String? paditDp;
  final List<JobTimelineModel>? jobTimeline;

  RequestedPanditModel({
    this.jobId,
    this.panditId,
    this.name,
    this.phone,
    this.city,
    this.state,
    this.status,
    this.paditDp,
    this.jobTimeline,
  });

  factory RequestedPanditModel.fromJson(Map<String, dynamic> json) {
    return RequestedPanditModel(
      jobId: json['job_id'],
      panditId: json['pandit_id'],
      name: json['name'],
      phone: json['phone'],
      city: json['city'],
      state: json['state'],
      status: json['status'],
      paditDp: json['padit_dp'],
      jobTimeline: json['job_timeline'] != null
          ? (json['job_timeline'] as List)
              .map((e) => JobTimelineModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'pandit_id': panditId,
      'name': name,
      'phone': phone,
      'city': city,
      'state': state,
      'status': status,
      'padit_dp': paditDp,
      'job_timeline': jobTimeline?.map((e) => e.toJson()).toList(),
    };
  }
}

class JobTimelineModel {
  final String? status;
  final String? date;
  final String? time;

  JobTimelineModel({
    this.status,
    this.date,
    this.time,
  });

  factory JobTimelineModel.fromJson(Map<String, dynamic> json) {
    return JobTimelineModel(
      status: json['status'],
      date: json['date'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'date': date,
      'time': time,
    };
  }
}