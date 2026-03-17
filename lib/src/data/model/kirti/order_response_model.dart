// To parse this JSON data, do
//
//     final orderResponseModel = orderResponseModelFromJson(jsonString);

import 'dart:convert';

OrderResponseModel orderResponseModelFromJson(String str) => OrderResponseModel.fromJson(json.decode(str));

String orderResponseModelToJson(OrderResponseModel data) => json.encode(data.toJson());

class OrderResponseModel {
  int? id;
  User? user;
   int? totalAmount;
  List<dynamic>? addOns;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? name;
  String? address;
  String? status;
  bool? paymentStatus;
  String? mobileNumber;
  DateTime? scheduledDatetime;
  dynamic otp1;
  dynamic otp2;
  bool? otp1Verified;
  bool? otp2Verified;
  ServiceSection? serviceSection;
  dynamic pandit;
  Plan? plan;
  String? feedback;

  OrderResponseModel({
    this.id,
    this.user,
    this.addOns,
    this.totalAmount,
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
    this.serviceSection,
    this.pandit,
    this.plan,
    this.feedback,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) => OrderResponseModel(
    id: json["id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    addOns: json["add_ons"] == null ? [] : List<dynamic>.from(json["add_ons"]!.map((x) => x)),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    name: json["name"],

    totalAmount: json["total_amount"],
    address: json["address"],
    status: json["status"],
    paymentStatus: json["payment_status"],
    mobileNumber: json["mobile_number"],
    scheduledDatetime: json["scheduled_datetime"] == null ? null : DateTime.parse(json["scheduled_datetime"]),
    otp1: json["otp1"],
    otp2: json["otp2"],
    otp1Verified: json["otp1_verified"],
    otp2Verified: json["otp2_verified"],
    serviceSection: json["service_section"] == null ? null : ServiceSection.fromJson(json["service_section"]),
    pandit: json["pandit"],
    plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
    feedback: json["feedback"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user?.toJson(),
    "add_ons": addOns == null ? [] : List<dynamic>.from(addOns!.map((x) => x)),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "name": name,
    "address": address,
    "status": status,
    "payment_status": paymentStatus,
    "mobile_number": mobileNumber,
    "scheduled_datetime": scheduledDatetime?.toIso8601String(),
    "otp1": otp1,
    "otp2": otp2,
    "otp1_verified": otp1Verified,
    "otp2_verified": otp2Verified,
    "service_section": serviceSection?.toJson(),
    "pandit": pandit,
    "plan": plan?.toJson(),
    "feedback": feedback,
  };
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
    price: json["price"],
    description: json["description"] == null ? null : Description.fromJson(json["description"]),
    pooja: json["pooja"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "price": price,
    "description": description?.toJson(),
    "pooja": pooja,
  };
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

  Map<String, dynamic> toJson() => {
    "delta": delta,
    "html": html,
  };
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
    service: json["service"] == null ? [] : List<Service>.from(json["service"]!.map((x) => Service.fromJson(x))),
    name: json["name"],
    benefits: json["benefits"] == null ? null : Description.fromJson(json["benefits"]),
    steps: json["steps"] == null ? null : Description.fromJson(json["steps"]),
    metaDescription: json["meta_description"],
    description: json["description"] == null ? null : Description.fromJson(json["description"]),
    duration: json["duration"],
    images: json["images"],
    star: json["star"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "service": service == null ? [] : List<dynamic>.from(service!.map((x) => x.toJson())),
    "name": name,
    "benefits": benefits?.toJson(),
    "steps": steps?.toJson(),
    "meta_description": metaDescription,
    "description": description?.toJson(),
    "duration": duration,
    "images": images,
    "star": star,
  };
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

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
  };
}

class User {
  int? id;
  String? dp;
  dynamic backgroundImage;
  String? name;
  String? email;
  String? biography;
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

  Map<String, dynamic> toJson() => {
    "id": id,
    "dp": dp,
    "background_image": backgroundImage,
    "name": name,
    "email": email,
    "biography": biography,
    "phone": phone,
    "table_name": tableName,
  };
}
