
import 'dart:convert';

SkillResponseModel skillResponseModelFromJson(String str) => 
    SkillResponseModel.fromJson(json.decode(str));

String skillResponseModelToJson(SkillResponseModel data) => 
    json.encode(data.toJson());

class SkillResponseModel {
  int? id;
  Pandit? pandit;
  List<dynamic>? workImages;
  SkillsDetail? skillsDetail;  // NEW: nested skills detail
  int? role;
  int? category;
  int? expertise;
  int? experience;
  int? travelPreference;  // Changed to int (ID)
  String? createdAt;
  String? updatedAt;
  dynamic razorpayVendorId;
  dynamic razorpayBankId;
  dynamic address;
  dynamic alternateMobile;
  String? abouts;
  bool? isAvailableForOnline;
  bool? availableForOnlineServices;
  dynamic idProof;
  dynamic remarks;
  String? status;
  List<dynamic>? workImage;

  SkillResponseModel({
    this.id,
    this.pandit,
    this.workImages,
    this.skillsDetail,
    this.role,
    this.category,
    this.expertise,
    this.experience,
    this.travelPreference,
    this.createdAt,
    this.updatedAt,
    this.razorpayVendorId,
    this.razorpayBankId,
    this.address,
    this.alternateMobile,
    this.abouts,
    this.isAvailableForOnline,
    this.availableForOnlineServices,
    this.idProof,
    this.remarks,
    this.status,
    this.workImage,
  });

  factory SkillResponseModel.fromJson(Map<String, dynamic> json) => SkillResponseModel(
    id: json["id"],
    pandit: json["pandit"] == null ? null : Pandit.fromJson(json["pandit"]),
    workImages: json["work_images"] != null 
        ? List<dynamic>.from(json["work_images"].map((x) => x))
        : [],
    skillsDetail: json["skills_detail"] == null 
        ? null 
        : SkillsDetail.fromJson(json["skills_detail"]),
    role: json["role"],
    category: json["category"],
    expertise: json["expertise"],
    experience: json["experience"],
    // Backend usually sends an integer pk, but on validation errors it may send a list.
    travelPreference: json["travel_preference"] is int
        ? json["travel_preference"] as int
        : null,
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    razorpayVendorId: json["razorpay_vendor_id"],
    razorpayBankId: json["razorpay_bank_id"],
    address: json["address"],
    alternateMobile: json["alternate_mobile"],
    abouts: json["abouts"],
    isAvailableForOnline: json["is_available_for_online"],
    availableForOnlineServices: json["available_for_online_services"],
    idProof: json["id_proof"],
    remarks: json["remarks"],
    status: json["status"],
    workImage: json["work_image"] != null 
        ? List<dynamic>.from(json["work_image"].map((x) => x))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pandit": pandit?.toJson(),
    "work_images": workImages == null 
        ? [] 
        : List<dynamic>.from(workImages!.map((x) => x)),
    "skills_detail": skillsDetail?.toJson(),
    "role": role,
    "category": category,
    "expertise": expertise,
    "experience": experience,
    "travel_preference": travelPreference,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "razorpay_vendor_id": razorpayVendorId,
    "razorpay_bank_id": razorpayBankId,
    "address": address,
    "alternate_mobile": alternateMobile,
    "abouts": abouts,
    "is_available_for_online": isAvailableForOnline,
    "available_for_online_services": availableForOnlineServices,
    "id_proof": idProof,
    "remarks": remarks,
    "status": status,
    "work_image": workImage == null 
        ? [] 
        : List<dynamic>.from(workImage!.map((x) => x)),
  };
}

// NEW: Skills Detail Model
class SkillsDetail {
  String? role;
  String? category;
  String? expertise;
  String? experience;
  String? travelPreference;

  SkillsDetail({
    this.role,
    this.category,
    this.expertise,
    this.experience,
    this.travelPreference,
  });

  factory SkillsDetail.fromJson(Map<String, dynamic> json) => SkillsDetail(
    role: json["role"],
    category: json["category"],
    expertise: json["expertise"],
    experience: json["experience"],
    travelPreference: json["travel_preference"],
  );

  Map<String, dynamic> toJson() => {
    "role": role,
    "category": category,
    "expertise": expertise,
    "experience": experience,
    "travel_preference": travelPreference,
  };
}

class Pandit {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? phone;
  String? dp;
  String? backgroundImage;
  String? name;
  String? email;
  String? biography;
  String? tableName;

  Pandit({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.phone,
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
    backgroundImage: json["background_image"],
    name: json["name"] ?? 
        (json["first_name"] != null && json["last_name"] != null 
            ? "${json["first_name"]} ${json["last_name"]}".trim() 
            : json["first_name"] ?? json["username"]),
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
