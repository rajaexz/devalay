// To parse this JSON data, do
//
//     final fetchSkillModel = fetchSkillModelFromJson(jsonString);

import 'dart:convert';

FetchSkillModel fetchSkillModelFromJson(String str) => FetchSkillModel.fromJson(json.decode(str));

String fetchSkillModelToJson(FetchSkillModel data) => json.encode(data.toJson());

class FetchSkillModel {
  int? id;
  Pandit? pandit;
  List<dynamic>? workImages;
  SkillsDetail? skillsDetail;
  dynamic razorpayVendorId;
  dynamic razorpayBankId;
  String? address;
  dynamic alternateMobile;
  int? experience;
  dynamic travelPreference;
  dynamic abouts;
  bool? isAvailableForOnline;
  bool? availableForOnlineServices;
  dynamic accountNumber;
  dynamic ifscCode;
  dynamic bankName;
  dynamic upiId;
  dynamic idProof;
  dynamic remarks;
  String? status;
  int? role;
  int? category;
  int? expertise;
  String? createdAt;
  String? updatedAt;
  int? skills;
  List<dynamic>? workImage;

  FetchSkillModel({
    this.id,
    this.pandit,
    this.workImages,
    this.skillsDetail,
    this.razorpayVendorId,
    this.razorpayBankId,
    this.address,
    this.alternateMobile,
    this.experience,
    this.travelPreference,
    this.abouts,
    this.isAvailableForOnline,
    this.availableForOnlineServices,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.upiId,
    this.idProof,
    this.remarks,
    this.status,
    this.role,
    this.category,
    this.expertise,
    this.createdAt,
    this.updatedAt,
    this.skills,
    this.workImage,
  });

  factory FetchSkillModel.fromJson(Map<String, dynamic> json) => FetchSkillModel(
    id: json["id"],
    pandit: json["pandit"] == null ? null : Pandit.fromJson(json["pandit"]),
    workImages: json["work_images"] == null ? [] : List<dynamic>.from(json["work_images"]!.map((x) => x)),
    skillsDetail: json["skills_detail"] == null ? null : SkillsDetail.fromJson(json["skills_detail"]),
    razorpayVendorId: json["razorpay_vendor_id"],
    razorpayBankId: json["razorpay_bank_id"],
    address: json["address"],
    alternateMobile: json["alternate_mobile"],
    experience: json["experience"],
    travelPreference: json["travel_preference"],
    abouts: json["abouts"],
    isAvailableForOnline: json["is_available_for_online"],
    availableForOnlineServices: json["available_for_online_services"],
    accountNumber: json["account_number"],
    ifscCode: json["ifsc_code"],
    bankName: json["bank_name"],
    upiId: json["upi_id"],
    idProof: json["id_proof"],
    remarks: json["remarks"],
    status: json["status"],
    role: json["role"],
    category: json["category"],
    expertise: json["expertise"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    skills: json["skills"],
    workImage: json["work_image"] == null ? [] : List<dynamic>.from(json["work_image"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pandit": pandit?.toJson(),
    "work_images": workImages == null ? [] : List<dynamic>.from(workImages!.map((x) => x)),
    "skills_detail": skillsDetail?.toJson(),
    "razorpay_vendor_id": razorpayVendorId,
    "razorpay_bank_id": razorpayBankId,
    "address": address,
    "alternate_mobile": alternateMobile,
    "experience": experience,
    "travel_preference": travelPreference,
    "abouts": abouts,
    "is_available_for_online": isAvailableForOnline,
    "available_for_online_services": availableForOnlineServices,
    "account_number": accountNumber,
    "ifsc_code": ifscCode,
    "bank_name": bankName,
    "upi_id": upiId,
    "id_proof": idProof,
    "remarks": remarks,
    "status": status,
    "role": role,
    "category": category,
    "expertise": expertise,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "skills": skills,
    "work_image": workImage == null ? [] : List<dynamic>.from(workImage!.map((x) => x)),
  };
}

class Pandit {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? phone;
  String? requestStatus;
  String? dp;
  int?  rating;
  dynamic backgroundImage;
  String? name;
  String? email;
  String? biography;
  String? tableName;
    int? jobsCompleted;
  Pandit({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.rating,
    this.requestStatus,
    this.jobsCompleted,
    this.dp,
    this.backgroundImage,
    this.name,
    this.email,
    this.biography,
    this.tableName,
  });

  factory Pandit.fromJson(Map<String, dynamic> json) => Pandit(
    id: json["id"],
    username: json["username"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    phone: json["phone"],
    dp: json["dp"],
    requestStatus: json["request_status"] ?? "",
    jobsCompleted:  json["total_jobs"]?? 0,
    rating: json["total_rating"] ?? 0,
    backgroundImage: json["background_image"],
    name: json["name"] ??
        _buildDisplayName(json["first_name"], json["last_name"], json["username"]),
    email: json["email"],
    biography: json["biography"],
    tableName: json["table_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "dp": dp,
    "background_image": backgroundImage,
    "name": name,
    "email": email,
    "biography": biography,
    "table_name": tableName,
  };
}

String? _buildDisplayName(dynamic firstName, dynamic lastName, dynamic username) {
  final buffer = StringBuffer();
  if (firstName is String && firstName.isNotEmpty) {
    buffer.write(firstName);
  }
  if (lastName is String && lastName.isNotEmpty) {
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(lastName);
  }
  if (buffer.isNotEmpty) {
    return buffer.toString();
  }
  if (username is String && username.isNotEmpty) {
    return username;
  }
  return null;
}

class SkillsDetail {
  int? id;
  String? expertise;
  String? category;
  String? role;
  String? experience;
  String? travelPreference;

  SkillsDetail({
    this.id,
    this.expertise,
    this.category,
    this.role,
    this.experience,
    this.travelPreference,
  });

  factory SkillsDetail.fromJson(Map<String, dynamic> json) => SkillsDetail(
    id: json["id"],
    expertise: json["expertise"],
    category: json["category"],
    role: json["role"],
    experience: json["experience"],
    travelPreference: json["travel_preference"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "expertise": expertise,
    "category": category,
    "role": role,
    "experience": experience,
    "travel_preference": travelPreference,
  };
}
